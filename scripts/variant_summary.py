#!/usr/bin/env python3
"""Summarize normalized VCF sites without requiring an extra Python VCF library."""
import csv
import gzip
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "results" / "stats"
OUT.mkdir(parents=True, exist_ok=True)
FILES = {
    "GATK": ROOT / "results/vcf/HG002.gatk.norm.vcf.gz",
    "FreeBayes": ROOT / "results/vcf/HG002.freebayes.norm.vcf.gz",
}

summary = []
rows = []
for caller, path in FILES.items():
    if not path.exists():
        raise SystemExit(f"Missing {path}. Run bash scripts/03_compare_callers.sh")
    n = Counter()
    with gzip.open(path, "rt", encoding="utf-8") as handle:
        for line in handle:
            if line.startswith("#"):
                continue
            parts = line.rstrip("\n").split("\t")
            chrom, pos, ref, alt = parts[0], int(parts[1]), parts[3], parts[4]
            qual = parts[5]
            if alt == "*" or alt.startswith("<") or "[" in alt or "]" in alt:
                kind = "OTHER"
            elif len(ref) == 1 and len(alt) == 1:
                kind = "SNP"
            elif len(ref) != len(alt):
                kind = "INDEL"
            else:
                kind = "OTHER"
            fmt = dict(zip(parts[8].split(":"), parts[9].split(":"))) if len(parts) > 9 else {}
            dp = fmt.get("DP", ".")
            gt = fmt.get("GT", ".")
            n[kind] += 1
            rows.append({"caller": caller, "type": kind, "chrom": chrom, "pos": pos,
                         "ref": ref, "alt": alt, "qual": qual, "dp": dp, "gt": gt})
    for kind in ("SNP", "INDEL", "OTHER"):
        summary.append({"caller": caller, "type": kind, "count": n[kind]})
    print(f"{caller}: {sum(n.values())} normalized records; SNP {n['SNP']}, "
          f"INDEL {n['INDEL']}, OTHER {n['OTHER']}")

for name, values, columns in [
    ("variant_counts.csv", summary, ("caller", "type", "count")),
    ("variant_records.csv", rows, ("caller", "type", "chrom", "pos", "ref", "alt", "qual", "dp", "gt")),
]:
    with (OUT / name).open("w", newline="", encoding="utf-8") as h:
        writer = csv.DictWriter(h, fieldnames=columns)
        writer.writeheader()
        writer.writerows(values)
print(f"Saved CSV files to {OUT}")
