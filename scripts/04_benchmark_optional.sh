#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
REF=data/reference/chr20_slice.fasta
TRUTH=data/truth/HG002.benchmark.vcf.gz
BED_ORIG=data/truth/HG002_GRCh38_v4.2.1_highconfidence.bed
BED_LOCAL=data/truth/HG002.highconfidence.slice.bed
mkdir -p data/truth results/benchmark

cat <<'EOF'
IMPORTANT benchmark prerequisite:
  Verify from data/truth/FIXTURE_README.md that the fixture benchmark VCF
  was derived from the same GIAB HG002 GRCh38 truth release as the
  v4.2.1 high-confidence BED fetched below. If not, DO NOT report the scores
  as independently verified benchmark performance until versions are reconciled.
  The truth set should NEVER be used to tune filters then benchmark on it.
EOF

GIAB_URL="https://giab.s3.amazonaws.com/release/AshkenazimTrio/HG002_NA24385_son/NISTv4.2.1/GRCh38/HG002_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed"
if [[ ! -s "$BED_ORIG" ]]; then
  curl -fL --retry 3 "$GIAB_URL" -o "$BED_ORIG"
fi

# Original BED is 0-based, half-open; the local FASTA has 1-based position 1
# corresponding to GRCh38 chr20 position 10,000,000. Thus subtract 9,999,999.
awk 'BEGIN{OFS="\t"; shift=9999999; n=500001}
  $1=="chr20" || $1=="20" {
    x=$2-shift; y=$3-shift
    if (x<0) x=0
    if (y>n) y=n
    if (y>x) print "chr20_10.0-10.5Mb",x,y
  }' "$BED_ORIG" | sort -k1,1 -k2,2n > "$BED_LOCAL"
[[ -s "$BED_LOCAL" ]] || { echo 'No BED intervals were mapped. Verify the downloaded BED.' >&2; exit 1; }
[[ -s "$TRUTH" ]] || { echo 'Truth VCF missing. Run scripts/01_download_inputs.sh first.' >&2; exit 1; }

[[ -d results/benchmark/reference.sdf ]] || rtg format -o results/benchmark/reference.sdf "$REF"
for caller in gatk freebayes; do
  calls="results/vcf/HG002.${caller}.norm.vcf.gz"
  out="results/benchmark/${caller}_vcfeval"
  [[ -s "$calls" ]] || { echo "Missing $calls" >&2; exit 1; }
  if [[ -d "$out" ]]; then
    echo "Already have $out; delete it to re-evaluate"
    continue
  fi
  rtg vcfeval \
    -b "$TRUTH" \
    -c "$calls" \
    -t results/benchmark/reference.sdf \
    -e "$BED_LOCAL" \
    --sample HG002 \
    -o "$out"
done
echo 'See results/benchmark/*/summary.txt and inspect TP/FP/FN VCFs before reporting.'
