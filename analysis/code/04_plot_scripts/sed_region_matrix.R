library(ggplot2)
library(magrittr)
library(GGally)

#### load data ####

load("analysis/data/tmp_data/squared_euclidian_distance_over_time_burial_construction.RData")
regions_grid_burial_construction <- regions_grid
regions_grid_burial_construction$variable <- "burial_construction"
load("analysis/data/tmp_data/squared_euclidian_distance_over_time_burial_type.RData")
regions_grid_burial_type <- regions_grid
regions_grid_burial_type$variable <- "burial_type"
load("analysis/data/tmp_data/region_colors.RData")
load("analysis/data/tmp_data/region_order.RData")

regions_grid <- rbind(regions_grid_burial_construction, regions_grid_burial_type)

# only for plot: time without sign of years
regions_grid <- regions_grid %>%
  dplyr::mutate(
    time = time * (-1)
  )



#### manual construction of plots for plot matrix ####

plot_list <- list()
combinations <- c()
iter <- 1
for (row_region in region_order) {
  for (col_region in region_order) {

    if (row_region == col_region) {
      plot_list[[iter]] <- ggplot() +
        ylim(0,2) +
        scale_x_reverse(
          breaks = c(2000, 1500, 1000),
          limits = c(2200, 800)
        )
    } else {

      second_run <- paste(row_region, col_region, sep = ".") %in% combinations
      combinations[[iter]] <- paste(col_region, row_region, sep = ".")

      if (!second_run) {
        regions_grid_subset <- regions_grid %>%
          dplyr::filter(
            variable == "burial_construction",
            regionA == col_region,
            regionB == row_region
          )
        plot_starter <- regions_grid_subset %>%
          ggplot() +
          geom_line(
            aes(time, sed, group = variable),
            alpha = 0.3,
            size = 0.5
          ) +
          geom_smooth(
            aes(time, sed, group = variable, linetype = variable, color = variable),
            method = "loess",
            span = 0.3,
            size = 1,
            linetype = "dashed"
          )
      } else {
        regions_grid_subset <- regions_grid %>%
          dplyr::filter(
            variable == "burial_type",
            regionA == col_region,
            regionB == row_region
          )
        plot_starter <- regions_grid_subset %>%
          ggplot()  +
          geom_line(
            aes(time, sed, group = variable),
            alpha = 0.3,
            size = 0.5
          ) +
          geom_smooth(
            aes(time, sed, group = variable, linetype = variable, color = variable),
            method = "loess",
            span = 0.3,
            size = 1
          )
      }

      plot_list[[iter]] <- plot_starter +
        scale_x_reverse(
          breaks = c(2000, 1500, 1000),
          limits = c(2200, 800)
        ) +
        scale_y_continuous(
          limits = c(0, 2)
        ) +
        theme_bw() +
        scale_colour_manual(
          name = "Burial customs",
          values = c(
            "burial_type" = "#0072B2",
            "burial_construction" = "#009E73"
          )
        )

    }

    iter <- iter + 1
  }
}



#### combine plots in plot matrix ####

sed_matrix <- ggmatrix(
  plot_list,
  nrow = 8, ncol = 8,
  xAxisLabels = region_order,
  yAxisLabels = region_order,
  byrow = FALSE,
  switch = "y",
  labeller = label_wrap_gen(),
  ylab ="Squared Euclidian Distance",
  xlab = "Time in years calBC"
) + theme_bw() +
  theme(
    axis.text = element_text(size = 15),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title = element_text(size = 15),
    strip.text = element_text(size = 10),
    legend.position = "bottom",
    panel.border = element_rect(colour = "black", size = 1)
  )


sed_matrix %>%
  ggsave(
    "analysis/figures/sed_region_matrix.jpeg",
    plot = .,
    device = "jpeg",
    scale = 1,
    dpi = 300,
    width = 330, height = 330, units = "mm",
    limitsize = F
  )
