#!/usr/bin/env bash
set -euo pipefail

mkdir -p data/trimmed results/fastp

R1=data/trimmed/HG002_R1.trimmed.fastq.gz
R2=data/trimmed/HG002_R2.trimmed.fastq.gz

if [[ -s "$R1" && -s "$R2" ]]; then
  echo "Trimmed FASTQ files already exist."
  exit 0
fi

fastp \
  -i data/reads/HG002_R1.fastq.gz \
  -I data/reads/HG002_R2.fastq.gz \
  -o "$R1" \
  -O "$R2" \
  --detect_adapter_for_pe \
  --cut_right \
  --cut_right_window_size 4 \
  --cut_right_mean_quality 25 \
  --length_required 50 \
  --thread 2 \
  --html results/fastp/fastp_report.html \
  --json results/fastp/fastp_report.json
