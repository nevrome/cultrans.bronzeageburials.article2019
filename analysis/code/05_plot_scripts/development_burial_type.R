#### dependencies ####
library(ggplot2)
library(magrittr)
source("analysis/code/helper_functions/geom_grob.R")
library(cowplot)

##### load data ####
load("analysis/data/tmp_data/development_amount_burial_type.RData")
load("analysis/data/tmp_data/region_order.RData")
load("analysis/data/tmp_data/development_proportions_burial_type.RData")

#### prepare data ####
amount_devel <- amount_development_burial_type
regions_factor <- as.factor(amount_devel$region_name)
amount_devel$region_name <- factor(regions_factor, levels = region_order)
idea_factor <- as.factor(amount_devel$idea)
amount_devel$idea <- factor(idea_factor, levels = rev(levels(idea_factor)))

prop <- proportion_development_burial_type
prop$idea <- as.factor(prop$idea)
prop$idea <- factor(prop$idea , levels = rev(levels(prop$idea )))

region_file_list <- unique(amount_devel$region_name) %>% gsub(" ", "_", ., fixed = TRUE)
gl <- lapply(region_file_list, function(x) {
  img <- png::readPNG(paste0("analysis/data/tmp_data/", x, ".png"))
  g <- grid::rasterGrob(
    img, interpolate = TRUE,
    width = 0.14, height = 1.2
  )
})
dummy <- tibble::tibble(region_name = unique(amount_devel$region_name), grob = gl )

#### development_burial_type_A ####
development_burial_type_A <- ggplot() +
  geom_area(
    data = amount_devel,
    aes(x = timestep, y = n, fill = idea),
    position = 'stack',
    linetype = "blank",
    alpha = 0.8
  ) +
  facet_wrap(~region_name, nrow = 8) +
  xlab("Time in years calBC") +
  ylab("Amount of graves") +
  labs(fill = "Burial customs") +
  theme_bw() +
  theme(
    legend.position = "bottom",
    panel.grid.major.x = element_line(colour = "black", size = 0.3),
    axis.text = element_text(size = 25),
    axis.title = element_text(size = 25),
    axis.text.x = element_text(angle = 45, hjust = 1),
    strip.text.x = element_text(size = 25),
    legend.title = element_text(size = 30, face = "bold"),
    legend.text = element_text(size = 30),
    panel.border = element_rect(colour = "black", size = 2)
  ) +
  scale_fill_manual(
    values = c(
      "cremation" = "#D55E00",
      "inhumation" = "#0072B2",
      "mound" = "#CC79A7",
      "flat" = "#009E73",
      "unknown" = "grey85"
    )
  ) +
  coord_cartesian(
    ylim = c(0, 80)
  ) +
  scale_x_continuous(
    breaks = seq(-2200, -800, 200),
    limits = c(-2500, -800)
  ) +
  # guides(
  #   fill = FALSE
  # ) +
  NULL

development_burial_type_A <- development_burial_type_A +
  geom_custom(
    data = dummy,
    aes(grob = grob),
    inherit.aes = FALSE,
    x = 0.1, y = 0.5
  )

#### development_burial_type_B ####

development_burial_type_B <- ggplot() +
  geom_area(
    data = prop,
    mapping = aes(x = timestep, y = proportion, fill = idea),
    position = 'stack',
    linetype = "blank",
    alpha = 0.8
  ) +
  scale_alpha_continuous(range = c(0.0, 0.7)) +
  facet_wrap(~region_name, nrow = 8) +
  xlab("Time in years calBC") +
  ylab("Proportion of burial customs") +
  labs(fill = "Burial customs") +
  theme_bw() +
  theme(
    legend.position = "bottom",
    panel.grid.major.x = element_line(colour = "black", size = 0.3),
    axis.text = element_text(size = 25),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title = element_text(size = 25),
    strip.text.x = element_text(size = 25),
    legend.title = element_text(size = 30, face = "bold"),
    legend.text = element_text(size = 30),
    panel.border = element_rect(colour = "black", size = 2)
  ) +
  scale_fill_manual(
    values = c(
      "cremation" = "#D55E00",
      "inhumation" = "#0072B2",
      "mound" = "#CC79A7",
      "flat" = "#009E73"
    )
  ) +
  scale_y_continuous(
    breaks = c(0, 0.5, 1),
    labels = c("0%", "50%", "100%")
  ) +
  scale_x_continuous(
    breaks = seq(-2200, -800, 200),
    limits = c(-2500, -800)
  )

development_burial_type_B <- development_burial_type_B +
  geom_custom(
    data = dummy,
    aes(grob = grob),
    inherit.aes = FALSE,
    x = 0.1, y = 0.5
  )

#### combine plots ####

combined_plot <- plot_grid(
  development_burial_type_A,
  development_burial_type_B,
  labels = c("A", "B"),
  nrow = 2,
  align = "v",
  label_size = 35,
  vjust = 1.0,
  hjust = 0
)

combined_plot %>%
  ggsave(
    "analysis/figures/development_burial_type.jpeg",
    plot = .,
    device = "jpeg",
    scale = 1,
    dpi = 300,
    width = 330, height = 930, units = "mm",
    limitsize = F
  )

