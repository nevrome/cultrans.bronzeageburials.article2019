library(magrittr)

load("analysis/data/tmp_data/sed_simulation_mantel_sed_spatial.RData")
mantel_simulations <- mantel_test_results %>% dplyr::mutate(model_id = as.integer(model_id))
load("analysis/data/tmp_data/sed_simulation_model_grid.RData")
mantel_simulations %<>% dplyr::left_join(models_grid[, c("model_id", "model_group")], by = "model_id")
load("analysis/data/tmp_data/mantel_sed_spatial_burial_type.RData")
mantel_burial_type <- mantel_test_results
load("analysis/data/tmp_data/mantel_sed_spatial_burial_type_burial_construction.RData")
mantel_burial_construction <- mantel_test_results

mantel_burial_type %<>%
  dplyr::mutate(
    context = "burial_type"
  )

mantel_burial_construction %<>%
  dplyr::mutate(
    context = "burial_construction"
  )

mantel_real_world <- rbind(mantel_burial_type, mantel_burial_construction)

library(ggplot2)

plot_mantel <- function(title, mantel_simulations, mantel_real_world) {
  ju <- ggplot() +
    geom_hline(
      yintercept = 0,
      colour = "red",
      size = 2
    ) +
    geom_line(
      data = mantel_simulations,
      mapping = aes(
        x = time,
        y = statistic,
        group = model_id
      ),
      position = position_nudge(x = -0.25),
      size = 0.4,
      alpha = 0.2
    ) +
    geom_point(
      data = mantel_simulations,
      mapping = aes(
        x = time,
        y = statistic
      ),
      position = position_nudge(x = -0.25),
      size = 1
    ) +
    geom_point(
      data = mantel_real_world,
      mapping = aes(
        x = time,
        y = statistic,
        colour = context
      ),
      position = position_nudge(x = -0.25),
      size = 7
    ) +
    geom_line(
      data = mantel_real_world,
      mapping = aes(
        x = time,
        y = statistic,
        colour = context,
        group = context
      ),
      position = position_nudge(x = -0.25),
      size = 1
    ) +
    geom_boxplot(
      data = mantel_simulations,
      mapping = aes(
        x = time,
        y = statistic
      ),
      width = 0.3
    ) +
    geom_dotplot(
      data = mantel_simulations,
      mapping = aes(
        x = time,
        y = statistic,
        fill = base::cut(
          signif,
          breaks = c(0, 0.01, 0.05, 0.1, seq(0.2, 1, 0.1)),
          labels = c("< 0.01", "< 0.05", "< 0.1", rep("> 0.1", 9))
        )
      ),
      binaxis = "y",
      stackdir = "down",
      position = position_nudge(x = -0.4),
      dotsize = 1,
      binpositions = "all",
      method = "histodot",
      binwidth = 0.025
    ) +
    scale_fill_manual(
      name = "Mantel test significance level of simulation runs",
      values = c(
        "< 0.01" = "#800026",
        "< 0.05" = "#e31a1c",
        "< 0.1" = "#fd8d3c",
        "> 0.1" = "white"
      )
    ) +
    scale_colour_manual(
      name = "Real world context",
      values = c(
        "burial_type" = "#0072B2",
        "burial_construction" = "#009E73"
      )
    ) +
    theme_bw() +
    theme(
      legend.position = "bottom",
      axis.text = element_text(size = 25),
      axis.text.x = element_text(angle = 45, hjust = 1),
      axis.title = element_text(size = 25),
      strip.text.x = element_text(size = 25),
      legend.title = element_text(size = 30, face = "bold"),
      legend.text = element_text(size = 30),
      panel.border = element_rect(colour = "black", size = 2),
      legend.box = "vertical",
      legend.text.align = 0,
      plot.margin = unit(c(1,1,1,2), "lines")
    ) +
    ylab("correlation coefficient") +
    xlab("Time steps in years calBC") +
    ylim(c(-0.5, 0.7))

  ju

}

variants <- 1:8 %>% lapply(
  function(variant) {
    plot_mantel(
      variant,
      mantel_simulations %>% dplyr::filter(model_group == variant),
      mantel_real_world
    )
  }
)

top <- cowplot::plot_grid(
  plotlist = lapply(variants, function(x){ x + theme(legend.position = "none") }),
  labels = LETTERS[1:8],
  rel_heights = c(1, 1, 1, 1),
  nrow = 4,
  ncol = 2,
  align = "h",
  axis = "lr",
  label_size = 35,
  vjust = 1,
  hjust = 0
)

total <- cowplot::plot_grid(
  top,
  cowplot::get_legend(variants[[1]]),
  labels = c('', ''),
  ncol = 1,
  rel_heights = c(1, 0.1)
)

total %>%
  ggsave(
    paste0("analysis/figures/simulation.jpeg"),
    plot = .,
    device = "jpeg",
    scale = 1,
    dpi = 300,
    width = 660, height = 930, units = "mm",
    limitsize = F
  )


