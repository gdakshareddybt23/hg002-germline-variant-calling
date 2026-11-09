# Variant-calling interview Q&A preparation

1. **FASTQ vs SAM vs BAM vs VCF:** FASTQ = sequence and per-base quality; SAM = text alignment format; BAM = compressed binary alignment; VCF = variant and genotype records.
2. **Why FastQC/MultiQC?** Detect base-quality profiles, duplicates, adapters and GC anomalies before mapping; MultiQC aggregates runs.
3. **Why reference FASTA matters?** Coordinates, alleles and annotation depend on build and contig names; no mixing hg19, GRCh38 or slice-local coordinates.
4. **Why BWA-MEM?** Maps short paired-end DNA reads to a reference. Contrast mapping quality vs base quality.
5. **Why sort and index BAM?** Sort by genomic coordinate, allowing random genomic access and IGV visualization.
6. **Why add read group?** GATK links reads with sample/platform/library metadata, used for variant genotyping and QC.
7. **Why MarkDuplicates?** Label likely duplicate read fragments to avoid counting non-independent evidence repeatedly.
8. **What does HaplotypeCaller do?** Local assembly of active regions to resolve SNPs/indels; appropriate for germline calls, not tumor-normal somatic pair.
9. **What does FreeBayes do?** Haplotype-based Bayesian variant calling independent from GATK; same BAM, distinct assumptions.
10. **What is genotype `0/1` or `1/1`?** Heterozygous reference/alternate vs homozygous alternate in diploid sample.
11. **VCF columns:** CHROM, POS, ID, REF, ALT, QUAL, FILTER, INFO, optionally FORMAT and sample columns. Example genotype tags GT, DP, AD, GQ, PL.
12. **What is a benchmark?** GIAB truth VCF plus high-confidence BED; precision=TP/(TP+FP), recall=TP/(TP+FN); compare variants using representation-aware evaluator.
13. **Why not precision from caller overlap?** Both callers may share false positives or miss true variants; overlap only shows consistency, not accuracy.
14. **Why use custom IGV genome?** This dataset renames and shifts chr20 coordinate system; built-in full GRCh38 would misplace evidence.
15. **Why no BQSR in starter pipeline?** No independent, properly configured slice-specific known-sites resource; truth set must not leak into evaluation.
16. **How did you automate?** Bash scripts with `set -euo pipefail`, repository paths, data download checks, checked reference indexes, generated reports and versions.
17. **What if a step fails?** Investigate logs and inputs, rerun with consistent environment, verify reference/contig/read groups/indexes; no manual changing results.
18. **How do you scale?** Multi-sample manifest, workflow manager (Snakemake/Nextflow), parallelization, provenance, joint genotyping when appropriate.

**Practice a 60-90s project explanation:** Problem -> dataset -> QC -> alignment -> GATK/FreeBayes -> normalization -> validation -> findings -> limitations. Replace placeholders with your own actual observed findings.
