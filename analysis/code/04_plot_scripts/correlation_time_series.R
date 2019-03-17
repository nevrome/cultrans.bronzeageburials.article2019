library(magrittr)

load("analysis/data/tmp_data/mantel_sed_spatial_burial_type.RData")
mantel_burial_type <- mantel_test_results
load("analysis/data/tmp_data/mantel_sed_spatial_burial_construction.RData")
mantel_burial_construction <- mantel_test_results

mantel_burial_type %<>%
  dplyr::mutate(
    context = "burial_type"
  )

mantel_burial_construction %<>%
  dplyr::mutate(
    context = "burial_construction"
  )

mantel <- rbind(mantel_burial_type, mantel_burial_construction)

library(ggplot2)

p <- ggplot() +
  geom_hline(
    yintercept = 0,
    colour = "red",
    size = 2
  ) +
  geom_point(
    data = mantel,
    mapping = aes(
      x = time,
      y = statistic,
      colour = context
    ),
    size = 7
  ) +
  geom_line(
    data = mantel,
    mapping = aes(
      x = time,
      y = statistic,
      colour = context,
      group = context,
      linetype = context
    ),
    size = 2
  ) +
  guides(
    fill = guide_legend(override.aes = list(size = 15))
  ) +
  scale_colour_manual(
    name = "Burial customs",
    values = c(
      "burial_type" = "#0072B2",
      "burial_construction" = "#009E73"
    )
  ) +
  scale_linetype_manual(
    name = "Burial customs",
    values = c(
      "burial_type" = "solid",
      "burial_construction" = "dashed"
    )
  ) +
  theme_bw() +
  theme(
    legend.position = "bottom",
    axis.text = element_text(size = 25),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title = element_text(size = 25),
    legend.title = element_text(size = 25, face = "bold"),
    legend.text = element_text(size = 25),
    plot.title = element_text(size = 25, face = "bold"),
    panel.border = element_rect(colour = "black", size = 2),
    plot.margin = unit(c(1,1,1,2), "lines")
  ) +
  ylab("Correlation coefficient") +
  xlab("Time steps in years calBC")

ggsave(
  "analysis/figures/correlation_time_series.jpeg",
  plot = p,
  device = "jpeg",
  scale = 1,
  dpi = 300,
  width = 300, height = 200, units = "mm",
  limitsize = F
)


