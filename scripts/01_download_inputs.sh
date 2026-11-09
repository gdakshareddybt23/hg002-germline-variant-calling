#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p data/reads data/reference data/truth
BASE="https://raw.githubusercontent.com/dhoconno/lungfish-genome-explorer/v2026.9.39/docs/user-manual/fixtures/hg002-chr20"
get() {
  local remote="$1" target="$2"
  if [[ -s "$target" ]]; then
    echo "Already have: $target"
  else
    echo "Downloading: $remote"
    curl -fL --retry 3 --retry-delay 2 "$BASE/$remote" -o "$target.tmp"
    mv "$target.tmp" "$target"
  fi
}
get HG002.chr20.10.0-10.5Mb_R1.fastq.gz data/reads/HG002_R1.fastq.gz
get HG002.chr20.10.0-10.5Mb_R2.fastq.gz data/reads/HG002_R2.fastq.gz
get GRCh38.chr20.10.0-10.5Mb.fasta data/reference/chr20_slice.fasta
get HG002.chr20.10.0-10.5Mb.benchmark.vcf.gz data/truth/HG002.benchmark.vcf.gz
# Fetch provenance metadata when it is available; a missing README is not fatal.
curl -fsSL --retry 2 "$BASE/README.md" -o data/truth/FIXTURE_README.md || true
# The downloaded VCF uses a slice-local contig; index it after installation.
echo 'Checking FASTQ gzip integrity...'
gzip -t data/reads/HG002_R1.fastq.gz data/reads/HG002_R2.fastq.gz
bcftools index -t -f data/truth/HG002.benchmark.vcf.gz
printf '\nReference header: '; head -n 1 data/reference/chr20_slice.fasta
printf 'Truth contigs: '; bcftools query -f '%CHROM\n' data/truth/HG002.benchmark.vcf.gz | sort -u | paste -sd ',' -
printf '\nFiles downloaded. Next: bash scripts/02_run_calling.sh\n'
