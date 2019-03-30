library(magrittr)
library(ggplot2)

#### load and prepare data ###

load("analysis/data/tmp_data/mantel_sed_spatial_burial_type.RData")
mantel_burial_type_spatial <- mantel_test_results
load("analysis/data/tmp_data/mantel_sed_spatial_burial_construction.RData")
mantel_burial_construction_spatial <- mantel_test_results
load("analysis/data/tmp_data/mantel_sed_burial_type_burial_construction.RData")
mantel_burial_construction_burial_type <- mantel_test_results
load("analysis/data/tmp_data/mantel_sed_burial_type_burial_construction_spatial.RData")
mantel_burial_type_burial_construction_spatial <- mantel_test_results

mantel_burial_type_spatial %<>%
  dplyr::mutate(
    context = "burial type & spatial distance"
  )
mantel_burial_construction_spatial %<>%
  dplyr::mutate(
    context = "burial construction & spatial distance"
  )
mantel_burial_construction_burial_type %<>%
  dplyr::mutate(
    context = "burial type & burial_construction"
  )
mantel_burial_type_burial_construction_spatial %<>%
  dplyr::mutate(
    context = "burial type & burial_construction + spatial distance"
  )

mantel <- rbind(
  mantel_burial_type_spatial,
  mantel_burial_construction_spatial,
  mantel_burial_construction_burial_type,
  mantel_burial_type_burial_construction_spatial
)

# hacky class manipulation: time without sign of years
mantel$time <- factor(
  gsub("-(?=[0-9])", "", mantel$time, perl = TRUE),
  levels = gsub("-(?=[0-9])", "", levels(mantel$time), perl = TRUE)
)



#### plot ####
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
    size = 5,
    show.legend = FALSE
  ) +
  geom_line(
    data = mantel,
    mapping = aes(
      x = time,
      y = statistic,
      colour = context,
      group = context,
      linetype = context,
      size = context
    )
  ) +
  guides(
    fill = guide_legend(override.aes = list(size = 15))
  ) +
  scale_colour_manual(
    name = "Distance correlations",
    values = c(
      "burial type & spatial distance" = "#0072B2",
      "burial construction & spatial distance" = "#009E73",
      "burial type & burial_construction" = "black",
      "burial type & burial_construction + spatial distance" = "black"
    )
  ) +
  scale_linetype_manual(
    name = "Distance correlations",
    values = c(
      "burial type & spatial distance" = "solid",
      "burial construction & spatial distance" = "dashed",
      "burial type & burial_construction" = "dotted",
      "burial type & burial_construction + spatial distance" = "dotted"
    )
  ) +
  scale_size_manual(
    name = "Distance correlations",
    values = c(
      "burial type & spatial distance" = 2,
      "burial construction & spatial distance" = 2,
      "burial type & burial_construction" = 2,
      "burial type & burial_construction + spatial distance" = 1
    )
  ) +
  theme_bw() +
  theme(
    legend.position = "bottom",
    legend.direction = "vertical",
    legend.key.width = unit(5, "line"),
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
  width = 300, height = 280, units = "mm",
  limitsize = F
)
