#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
THREADS="${THREADS:-4}"
REF=data/reference/chr20_slice.fasta
R1=data/trimmed/HG002_R1.trimmed.fastq.gz
R2=data/trimmed/HG002_R2.trimmed.fastq.gz
bash scripts/00_preprocess.sh
for f in "$REF" "$R1" "$R2"; do [[ -s "$f" ]] || { echo "Missing $f; run scripts/01_download_inputs.sh" >&2; exit 1; }; done
mkdir -p results/qc/fastqc results/qc/multiqc results/bam results/vcf results/stats

echo '[1/8] FASTQ QC: FastQC'
fastqc --threads "$THREADS" --outdir results/qc/fastqc "$R1" "$R2"
echo '[2/8] Prepare reference indices and GATK dictionary'
[[ -s "$REF.fai" ]] || samtools faidx "$REF"
[[ -s data/reference/chr20_slice.fasta.bwt ]] || bwa index "$REF"
[[ -s data/reference/chr20_slice.dict ]] || gatk CreateSequenceDictionary -R "$REF" -O data/reference/chr20_slice.dict

echo '[3/8] Map paired reads and sort BAM'
# BWA expands literal backslash-t characters in read-group string.
bwa mem -t "$THREADS" -R '@RG\tID:HG002_subset\tSM:HG002\tLB:lib1\tPL:ILLUMINA' \
  "$REF" "$R1" "$R2" | samtools sort -@ "$THREADS" -o results/bam/HG002.sorted.bam -
samtools index results/bam/HG002.sorted.bam
samtools flagstat results/bam/HG002.sorted.bam > results/stats/HG002.before_markdup.flagstat.txt

echo '[4/8] Mark duplicates (do not remove reads)'
gatk --java-options '-Xmx3g' MarkDuplicates \
  -I results/bam/HG002.sorted.bam \
  -O results/bam/HG002.markdup.bam \
  -M results/stats/HG002.markdup.metrics.txt \
  --CREATE_INDEX true
samtools quickcheck -v results/bam/HG002.markdup.bam
samtools flagstat results/bam/HG002.markdup.bam > results/stats/HG002.markdup.flagstat.txt
samtools coverage results/bam/HG002.markdup.bam > results/stats/HG002.coverage.tsv

echo '[5/8] Call single-sample germline variants using GATK HaplotypeCaller'
gatk --java-options '-Xmx3g' HaplotypeCaller \
  -R "$REF" -I results/bam/HG002.markdup.bam \
  -O results/vcf/HG002.gatk.raw.vcf.gz \
  --sample-ploidy 2 \
  --native-pair-hmm-threads 2
bcftools index -t -f results/vcf/HG002.gatk.raw.vcf.gz

echo '[6/8] Call variants using FreeBayes'
freebayes -f "$REF" -p 2 results/bam/HG002.markdup.bam \
  | bgzip -c > results/vcf/HG002.freebayes.raw.vcf.gz
bcftools index -t -f results/vcf/HG002.freebayes.raw.vcf.gz

echo '[7/8] Combined QC report'
multiqc results/qc/fastqc results/stats --outdir results/qc/multiqc --force

echo '[8/8] Capture tool versions'
{
  echo '=== BWA ==='; bwa 2>&1 | head -n 3 || true
  echo '=== SAMtools ==='; samtools --version | head -n 1
  echo '=== BCFtools ==='; bcftools --version | head -n 1
  echo '=== GATK ==='; gatk --version
  echo '=== FreeBayes ==='; freebayes --version | head -n 2
} > results/stats/versions.txt

echo 'Completed: ready for scripts/03_compare_callers.sh'
