# HG002 Germline Variant Calling — Results

## 1. Dataset
- Sample: GIAB HG002
- Reference: GRCh38 chromosome 20 custom 500,001-bp slice
- Sequencing: Paired-end Illumina reads
- Analysis: Germline SNP and indel detection

## 2. Sequencing Quality Control
Tools: FastQC, MultiQC and fastp

| Metric | Before | After |
|---|---:|---:|
| Q30 bases | 91.28% | 98.66% |
| Total reads | 91,148 | 82,458 |
| GC content | 39.40% | 39.12% |

Quality trimming improved the retained-base quality
distribution while reducing read count and length.

## 3. Alignment
Tools: BWA-MEM and SAMtools

- Reference breadth covered: 99.922%
- Mean depth: 36.20x
- Mean base quality: Q38.6
- Mean mapping quality: 60
- Duplicate fraction: 1.70%

## 4. Variant Calling
Tools: GATK HaplotypeCaller and FreeBayes

Normalized allele-record counts:

| Type | GATK | FreeBayes |
|---|---:|---:|
| SNP | 842 | 829 |
| Indel | 195 | 171 |
| Other | 5 | 18 |
| Total | 1042 | 1018 |

## 5. Caller Comparison
Tool: BCFtools

- Shared alleles: 950
- GATK-only alleles: 92
- FreeBayes-only alleles: 68
- Allele-level Jaccard agreement: 85.59%

## 6. Preliminary Benchmark Comparison
- Normalized benchmark alleles: 976
- GATK exact allele matches: 958
- FreeBayes exact allele matches: 908
- Benchmark alleles not matched by GATK: 18
- Benchmark alleles not matched by FreeBayes: 68

These are exact allele comparisons, NOT formal
precision, recall, sensitivity or F1 measurements.

## 7. IGV Case Investigation
Position: chromosome 20 slice, 14155
Benchmark: T>TAA, genotype 1/1

- Local depth: 7
- Seven reference-matching observations
- No insertion signal observed at the anchor
- Repetitive nearby sequence
- No corresponding nearby GATK or FreeBayes call

Interpretation: Unresolved benchmark/caller discordance.
Insufficient evidence to establish its cause.

## 8. Ensembl VEP Annotation
- Selected input alleles: 30
- VEP output annotation rows: 30
- Gene observed: ANKEF1
- intron_variant: 30 annotation rows
- non_coding_transcript_variant: 30 annotation rows

Consequence categories overlap. The selected variants
are not representative of the entire call set.

## 9. Study Limitations
- Small chromosome-20 subset, not whole-genome analysis
- No formal genotype-aware benchmarking yet
- Compatible GIAB high-confidence BED not yet verified
- Exact allele matching can miss equivalent representations
- Limited annotation subset
- Preprocessing impact on variant recall not yet evaluated

## 10. Conclusion
The workflow demonstrated FASTQ quality assessment,
trimming, read alignment, duplicate marking, germline
variant calling, variant normalization, allele comparison,
IGV inspection, Python/R visualization and VEP annotation.

GATK matched more benchmark alleles than FreeBayes
under this preliminary exact-allele comparison.
Formal accuracy superiority has not been established.
