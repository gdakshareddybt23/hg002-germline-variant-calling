#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(ggplot2))
args <- commandArgs(trailingOnly = TRUE)
root <- normalizePath(if (length(args)) args[[1]] else ".")
file <- file.path(root, "results", "stats", "variant_counts.csv")
if (!file.exists(file)) stop("Run: python scripts/variant_summary.py")
d <- read.csv(file)
d <- subset(d, type %in% c("SNP", "INDEL"))
p <- ggplot(d, aes(x = caller, y = count, fill = type)) +
  geom_col(position = "dodge", width = 0.6) +
  labs(title = "HG002 chr20 subset: called SNPs and indels",
       subtitle = "Normalized calls (counts, NOT benchmarked accuracy)",
       x = "Variant caller", y = "Variant allele records", fill = "Type") +
  theme_minimal(base_size = 12)
dir.create(file.path(root, "figures"), showWarnings = FALSE, recursive = TRUE)
ggsave(file.path(root, "figures", "variant_type_counts.png"), p,
       width = 8, height = 5, dpi = 200)
message("Saved: figures/variant_type_counts.png")
