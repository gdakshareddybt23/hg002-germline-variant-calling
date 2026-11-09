library(ggplot2)

df <- read.csv(
  "results/stats/vep_annotation_row_counts.csv"
)

p <- ggplot(
  df,
  aes(x = consequence, y = annotation_rows,
      fill = consequence)
) +
  geom_col(width = 0.55) +
  geom_text(
    aes(label = annotation_rows),
    vjust = -0.5,
    size = 5
  ) +
  scale_fill_manual(
    values = c("#27A69A", "#F07B72")
  ) +
  scale_y_continuous(
    limits = c(0, 36)
  ) +
  labs(
    title = "HG002 Variant Annotation using Ensembl VEP",
    subtitle = "Predicted molecular consequences (overlapping categories)",
    x = "Molecular consequence",
    y = "VEP annotation rows"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    axis.text.x = element_text(
      angle = 15, hjust = 1
    )
  )

ggsave(
  "figures/vep_consequence_distribution.png",
  plot = p,
  width = 10,
  height = 6,
  dpi = 300
)

print("VEP consequence graph saved successfully!")
