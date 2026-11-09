# IGV walkthrough

1. Install IGV Desktop on Windows: https://igv.org/doc/desktop/
2. Copy the files you need from WSL by opening `\\wsl$\Ubuntu\home\<linux-username>\bioinformatics-projects\hg002-germline-variant-calling` in Windows File Explorer. The path also works after copying project to your own Linux home directory; change username/path as needed.
3. In IGV select **Genomes > Load Genome from File** and choose **data/reference/chr20_slice.fasta**. Do NOT choose built-in full GRCh38/hg38 for this fixture, because its chromosome is slice-local.
4. Select **File > Load from File** and open **results/bam/HG002.markdup.bam** and **results/vcf/HG002.gatk.norm.vcf.gz** and **results/vcf/HG002.freebayes.norm.vcf.gz**. Keep `.bai` and `.tbi` indexes beside the files.
5. Navigate to **chr20_10.0-10.5Mb:250527** (known independently documented example). Zoom in and inspect reference/alternative bases, coverage, strand balance, mapping quality, pair orientation and nearby indels. This is an example coordinate, not proof of what your specific run called.
6. Also inspect at least 3 caller-concordant and 3 discordant sites selected from *your own* output, and save clearly labelled screenshots without revealing any personal genomic data.
7. Write observed read depth, alternate-support count, strand balance, whether the reference matches, and whether there are nearby soft-clipped reads or low-mapping-quality reads. Do not equate an IGV screenshot with truth-set benchmarking.
