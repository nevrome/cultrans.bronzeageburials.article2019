library(magrittr)
library(ggplot2)
library(cowplot)

#### load and prepare grave amount time series data ###

load("analysis/data/tmp_data/development_amount_burial_construction.RData")
load("analysis/data/tmp_data/development_amount_burial_type.RData")

data_amount_range_burial_construction <- amount_development_burial_construction %>%
  dplyr::ungroup() %>%
  dplyr::filter(
    idea != "unknown"
  ) %>%
  dplyr::group_by(region, timestep) %>%
  dplyr::summarise(
    sum_n = sum(n)
  ) %>%
  dplyr::ungroup() %>%
  dplyr::group_by(timestep) %>%
  dplyr::summarise(
    min_n = min(sum_n),
    max_n = max(sum_n),
    median_n = median(sum_n),
    first_quartile_n = quantile(sum_n)[2],
    third_quartile_n = quantile(sum_n)[4]
  )

data_amount_range_burial_type <- amount_development_burial_type %>%
  dplyr::ungroup() %>%
  dplyr::filter(
    idea != "unknown"
  ) %>%
  dplyr::group_by(region, timestep) %>%
  dplyr::summarise(
    sum_n = sum(n)
  ) %>%
  dplyr::ungroup() %>%
  dplyr::group_by(timestep) %>%
  dplyr::summarise(
    min_n = min(sum_n),
    max_n = max(sum_n),
    median_n = median(sum_n),
    first_quartile_n = quantile(sum_n)[2],
    third_quartile_n = quantile(sum_n)[4]
  )

#### prepare mean grave amounts for the correlation plot ####

mean_median_burial_construction <- data_amount_range_burial_construction %>%
  dplyr::mutate(
    time = cut(
      timestep,
      breaks = seq(-2200, -800, 200),
      labels = paste(seq(2200, 1000, -200), "-", seq(2000, 800, -200)),
      right = FALSE,
      include.lowest = TRUE
    )
  ) %>%
  dplyr::group_by(time) %>%
  dplyr::summarise(
    mean_median_n = mean(median_n)
  )

mean_median_burial_type <- data_amount_range_burial_type %>%
  dplyr::mutate(
    time = cut(
      timestep,
      breaks = seq(-2200, -800, 200),
      labels = paste(seq(2200, 1000, -200), "-", seq(2000, 800, -200)),
      right = FALSE,
      include.lowest = TRUE
    )
  ) %>%
  dplyr::group_by(time) %>%
  dplyr::summarise(
    mean_median_n = mean(median_n)
  )

mean_median_both <- rbind(mean_median_burial_construction, mean_median_burial_type) %>%
  dplyr::group_by(time) %>%
  dplyr::summarise(
    mean_median_n = mean(mean_median_n)
  )



#### remove negative sign ####

data_amount_range_burial_construction %<>% dplyr::mutate(timestep = -timestep)
data_amount_range_burial_type %<>% dplyr::mutate(timestep = -timestep)


#### data amount plot ####

data_amount_plot <- ggplot() +
  geom_ribbon(
    data = data_amount_range_burial_type,
    mapping = aes(
      x = timestep,
      ymin = first_quartile_n,
      ymax = third_quartile_n
    ),
    fill = "#0072B2",
    alpha = 0.25
  ) +
  geom_ribbon(
    data = data_amount_range_burial_construction,
    mapping = aes(
      x = timestep,
      ymin = first_quartile_n,
      ymax = third_quartile_n
    ),
    fill = "#009E73",
    alpha = 0.25
  ) +
  geom_line(
    data = data_amount_range_burial_type,
    mapping = aes(
      x = timestep,
      y = median_n
    ),
    colour = "#0072B2",
    size = 1.5
  ) +
  geom_line(
    data = data_amount_range_burial_construction,
    mapping = aes(
      x = timestep,
      y = median_n
    ),
    linetype = "dashed",
    colour = "#009E73",
    size = 1.5
  ) +
  theme_bw() +
  ylab("Graves per region") +
  xlab("") +
  scale_x_reverse(
    limits = c(2200, 800), expand = c(0, 0),
    position = "top",
    breaks = seq(2000, 1000, -200),
    minor_breaks = NULL
  )  +
  theme(
    axis.text = element_text(size = 25),
    axis.text.x = element_text(angle = 45, hjust = 0),
    axis.title = element_text(size = 25),
    plot.title = element_text(size = 25, face = "bold"),
    panel.border = element_rect(colour = "black", size = 2),
    plot.margin = unit(c(1,1,1,2), "lines")
  )



#### load and prepare correlation data ###

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
    context = "A: type & spatial distance"
  )
mantel_burial_construction_spatial %<>%
  dplyr::mutate(
    context = "B: construction & spatial distance"
  )
mantel_burial_construction_burial_type %<>%
  dplyr::mutate(
    context = "C: type & construction distance"
  )
mantel_burial_type_burial_construction_spatial %<>%
  dplyr::mutate(
    context = "D: type & construction + spatial distance"
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



#### statistical significance ####

# establish significance classes and create subsets only with significant results
mantel <- mantel %>%
  dplyr::mutate(
    signif_class = cut(
      mantel$signif,
      breaks = c(0, 0.05, 0.1, 1),
      labels = c("p < 0.05", "p < 0.1", "p > 0.1 (not significant)"),
      ordered_result = TRUE
    )
  )

signifs_0.05 <- mantel %>% dplyr::filter(
  signif_class == "p < 0.05"
)

signifs_0.1 <- mantel %>% dplyr::filter(
  signif_class == "p < 0.1"
)

#### add mean median of the grave pr year number to the mantel results ####

mantel_B <- mantel %>% dplyr::filter(
  context == "B: construction & spatial distance"
  ) %>%
  dplyr::left_join(
    mean_median_burial_construction, by = c("time")
  )

mantel_A <- mantel %>% dplyr::filter(
  context == "A: type & spatial distance"
) %>%
  dplyr::left_join(
    mean_median_burial_type, by = c("time")
  )

mantel_C <- mantel %>% dplyr::filter(
  context == "C: type & construction distance"
) %>%
  dplyr::left_join(
    mean_median_both, by = c("time")
  )

mantel_D <- mantel %>% dplyr::filter(
  context == "D: type & construction + spatial distance"
) %>%
  dplyr::left_join(
    mean_median_both, by = c("time")
  )

mantel <- rbind(mantel_A, mantel_B, mantel_C, mantel_D)

#### correlation time series plot ####
correlation_time_series_plot <- ggplot() +
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
      colour = context,
      alpha = mean_median_n
    ),
    size = 8,
    shape = 15
  ) +
  geom_point(
    data = mantel,
    mapping = aes(
      x = time,
      y = statistic,
      colour = context
    ),
    size = 3
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
  geom_point(
    data = signifs_0.05,
    mapping = aes(
      x = time,
      y = statistic
    ),
    shape = 0,
    size = 8,
    stroke = 2,
    colour = "red"
  ) +
  annotate(
    geom = "text",
    x = "1800 - 1600", y = 0.48,
    label = "p < 0.05",
    color = "red",
    size = 8
  ) +
  geom_point(
    data = signifs_0.1,
    mapping = aes(
      x = time,
      y = statistic
    ),
    shape = 0,
    size = 8,
    stroke = 2,
    colour = "orange"
  ) +
  annotate(
    geom = "text",
    x = "1600 - 1400", y = 0.4,
    label = "p < 0.1",
    color = "orange",
    size = 8
  ) +
  guides(
    fill = guide_legend(override.aes = list(size = 15)),
    colour = guide_legend(override.aes = list(shape = NA), order = 1),
    linetype = guide_legend(order = 1),
    size = guide_legend(order = 1),
    alpha = guide_legend(order = 2)
  ) +
  scale_colour_manual(
    name = "Distance correlations",
    values = c(
      "A: type & spatial distance" = "#0072B2",
      "B: construction & spatial distance" = "#009E73",
      "C: type & construction distance" = "black",
      "D: type & construction + spatial distance" = "black"
    )
  ) +
  scale_alpha_continuous(
    name = expression(bold(frac(Graves,Region%*%Year)))
  ) +
  scale_linetype_manual(
    name = "Distance correlations",
    values = c(
      "A: type & spatial distance" = "solid",
      "B: construction & spatial distance" = "dashed",
      "C: type & construction distance" = "dotted",
      "D: type & construction + spatial distance" = "dotted"
    )
  ) +
  scale_size_manual(
    name = "Distance correlations",
    values = c(
      "A: type & spatial distance" = 2,
      "B: construction & spatial distance" = 2,
      "C: type & construction distance" = 2,
      "D: type & construction + spatial distance" = 1
    )
  ) +
  theme_bw() +
  theme(
    legend.title = element_text(size = 25, face = "bold"),
    legend.text = element_text(size = 25),
    legend.position = c(0.45, -0.52),
    legend.direction = "vertical",
    legend.box = "horizontal",
    legend.key.width = unit(5, "line"),
    legend.key.height = unit(2, "line"),
    axis.text = element_text(size = 25),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title = element_text(size = 25),
    plot.title = element_text(size = 25, face = "bold"),
    panel.border = element_rect(colour = "black", size = 2),
    plot.margin = unit(c(1,1,15,2), "lines")
  ) +
  ylab("Correlation coefficient") +
  xlab("Time steps in years calBC")

#### combine plots ####

combined_plot <- plot_grid(
  data_amount_plot,
  correlation_time_series_plot,
  labels = c("A", "B"),
  nrow = 2,
  rel_heights = c(1, 3),
  align = "v",
  label_size = 35,
  vjust = 1.5,
  hjust = 0
)

ggsave(
  "analysis/figures/correlation_time_series.jpeg",
  plot = combined_plot,
  device = "jpeg",
  scale = 1,
  dpi = 300,
  width = 300, height = 400, units = "mm",
  limitsize = F
)
