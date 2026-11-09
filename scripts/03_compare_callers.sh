#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
REF=data/reference/chr20_slice.fasta
mkdir -p results/vcf results/stats
for caller in gatk freebayes; do
  raw="results/vcf/HG002.${caller}.raw.vcf.gz"
  norm="results/vcf/HG002.${caller}.norm.vcf.gz"
  pass="results/vcf/HG002.${caller}.qual30.vcf.gz"
  [[ -s "$raw" ]] || { echo "Missing $raw" >&2; exit 1; }
  echo "Normalizing ${caller} calls and splitting multi-allelic sites"
  if [[ "$caller" == "freebayes" ]]; then
    clean="results/vcf/HG002.freebayes.headerfixed.vcf.gz"
    bcftools reheader -f "$REF.fai" -o "$clean" "$raw"
    raw="$clean"
  fi
  bcftools norm -f "$REF" -m -any -c e "$raw" -Oz -o "$norm"
  bcftools index -t -f "$norm"
  echo "Exploratory QUAL>=30 filter (${caller}; not equally calibrated across callers)"
  bcftools view -i 'QUAL>=30' "$norm" -Oz -o "$pass"
  bcftools index -t -f "$pass"
  bcftools stats "$norm" > "results/stats/${caller}.bcftools.stats.txt"
  printf '%s normalized VCF records: ' "$caller"
  bcftools view -H "$norm" | wc -l
done

echo 'Intersect records by position AND allele (concordance only, not accuracy)'
bcftools isec -c none -n=2 -w1 \
  -Oz -o results/vcf/HG002.shared_alleles.vcf.gz \
  results/vcf/HG002.gatk.norm.vcf.gz \
  results/vcf/HG002.freebayes.norm.vcf.gz
bcftools index -t -f results/vcf/HG002.shared_alleles.vcf.gz
printf 'Shared normalized allele records from GATK: '
bcftools view -H results/vcf/HG002.shared_alleles.vcf.gz | wc -l
echo 'Next: python scripts/variant_summary.py'
