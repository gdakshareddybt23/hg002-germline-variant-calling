import csv
import gzip
import glob
import re
from collections import defaultdict
from pathlib import Path

files = glob.glob("results/annotation/*.tsv.gz")
if len(files) != 1:
    raise SystemExit("Expected one VEP TSV.gz file.")

with gzip.open(files[0], "rt") as f:
    lines = (line for line in f
             if line.strip() and not line.startswith("##"))
    reader = csv.DictReader(lines, delimiter="\t")
    reader.fieldnames = [
        col.lstrip("#").strip()
        for col in reader.fieldnames
    ]
    if "Consequence" not in reader.fieldnames:
        raise SystemExit("VEP Consequence column not found.")
    rows = list(reader)

consequences = defaultdict(set)
genes = defaultdict(set)
all_variants = set()

for row in rows:
    variant = row.get("Uploaded_variation", "")
    if variant in ("", ".", "-"):
        variant = (
            row.get("Location", "") + "|" +
            row.get("Allele", "")
        )

    all_variants.add(variant)

    for term in re.split(r"[,&]", row.get("Consequence", "")):
        if term and term != "-":
            consequences[term].add(variant)

    gene = row.get("SYMBOL", "")
    if not gene or gene == "-":
        gene = row.get("Gene", "")
    if gene and gene != "-":
        genes[gene].add(variant)

Path("results/stats").mkdir(parents=True, exist_ok=True)

with open("results/stats/vep_consequence_counts.csv", "w") as f:
    writer = csv.writer(f)
    writer.writerow(["consequence", "variant_count"])
    for term, variants in sorted(
        consequences.items(),
        key=lambda x: -len(x[1])
    ):
        writer.writerow([term, len(variants)])

with open("results/stats/vep_gene_counts.csv", "w") as f:
    writer = csv.writer(f)
    writer.writerow(["gene", "variant_count"])
    for gene, variants in sorted(
        genes.items(),
        key=lambda x: -len(x[1])
    ):
        writer.writerow([gene, len(variants)])

print("VEP annotation rows:", len(rows))
print("Distinct annotated variants:", len(all_variants))
print("Consequence categories:", len(consequences))
print("Genes with annotations:", len(genes))
print("Annotation summary CSV files saved.")
