library(ggplot2)

df <- read.csv("results/stats/benchmark_comparison.csv")

plot <- ggplot(df, aes(x = caller, y = matched, fill = caller)) +
  geom_col(width = 0.55) +
  geom_text(aes(label = matched), vjust = -0.5, size = 5) +
  scale_fill_manual(values = c("GATK" = "#27A69A",
                               "FreeBayes" = "#F07B72")) +
  coord_cartesian(ylim = c(0, 1050)) +
  labs(
    title = "HG002: GATK vs FreeBayes",
    subtitle = "Exact allele matches with benchmark (not formal accuracy)",
    x = "Variant caller",
    y = "Matching benchmark alleles"
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "none")

ggsave(
  "figures/benchmark_comparison.png",
  plot,
  width = 9,
  height = 6,
  dpi = 300
)
