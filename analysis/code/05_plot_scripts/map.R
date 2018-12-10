load("analysis/data/tmp_data/land_outline.RData")
load("analysis/data/tmp_data/rivers.RData")
load("analysis/data/tmp_data/lakes.RData")
load("analysis/data/tmp_data/countries.RData")
research_area <- sf::st_read("analysis/data/input_data/research_area.shp")
load("analysis/data/tmp_data/regions.RData")
load("analysis/data/tmp_data/bronze1.RData")
load("analysis/data/tmp_data/region_order.RData")
load("analysis/data/tmp_data/region_colors.RData")

bronze1_sf <- bronze1 %>% sf::st_as_sf(
  coords = c("lon", "lat"),
  crs = 4326
)

library(ggplot2)
library(sf)
library(cowplot)

#### map_A ####

xlimit_A <- c(-1600000, 1300000)
ylimit_A <- c(300000, 3800000)

map_A <- ggplot() +
  geom_sf(
    data = land_outline,
    fill = "white", colour = "black", size = 0.7
  ) +
  geom_sf(
    data = rivers,
    fill = NA, colour = "black", size = 0.2
  ) +
  geom_sf(
    data = lakes,
    fill = NA, colour = "black", size = 0.2
  ) +
  geom_sf(
    data = bronze1_sf,
    mapping = aes(
      color = burial_type,
      shape = burial_construction,
      size = burial_construction
    ),
    show.legend = "point"
  ) +
  theme_bw() +
  coord_sf(
    xlim = xlimit_A, ylim = ylimit_A,
    crs = st_crs("+proj=aea +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10 +x_0=0 +y_0=0 +ellps=intl +units=m +no_defs")
  ) +
  scale_shape_manual(
    values = c(
      "flat" = "\u268A",
      "mound" = "\u25E0",
      "unknown" = "\u2715"
    )
  ) +
  scale_size_manual(
    values = c(
      "flat" = 12,
      "mound" = 12,
      "unknown" = 6
    )
  ) +
  scale_color_manual(
    values = c(
      "cremation" = "#D55E00",
      "inhumation" = "#0072B2",
      "mound" = "#CC79A7",
      "flat" = "#009E73",
      "unknown" = "darkgrey"
    )
  ) +
  theme(
    legend.position = "bottom",
    legend.title = element_text(size = 25, face = "bold"),
    axis.title = element_blank(),
    axis.text = element_text(size = 30),
    legend.text = element_text(size = 30),
    panel.grid.major = element_line(colour = "black", size = 0.3),
    panel.border = element_rect(colour = "black", size = 2),
    legend.box = "vertical"
  ) +
  guides(
    color = guide_legend(title = "Burial type", override.aes = list(size = 10), nrow = 1, byrow = TRUE),
    shape = guide_legend(title = "Burial construction", override.aes = list(size = 10), nrow = 1, byrow = TRUE),
    size = FALSE
  )

#### map_B ####

ex <- raster::extent(
  research_area %>%
    sf::st_transform(
      sf::st_crs("+proj=aea +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10 +x_0=0 +y_0=0 +ellps=intl +units=m +no_defs")
    )
  )

xlimit_B <- c(ex[1], ex[2])
ylimit_B <- c(ex[3], ex[4])

map_B <- ggplot() +
  geom_sf(
    data = land_outline,
    fill = "white", colour = "black", size = 0.7
  ) +
  geom_sf(
    data = countries,
    fill = NA, colour = "black", size = 0.2
  ) +
  geom_sf(
    data = regions,
    mapping = aes(
      colour = NAME
    ),
    fill = NA, size = 2.5
  ) +
  geom_sf(
    data = research_area,
    fill = NA, colour = "red", size = 0.5
  ) +
  theme_bw() +
  coord_sf(
    xlim = xlimit_B, ylim = ylimit_B,
    crs = st_crs("+proj=aea +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10 +x_0=0 +y_0=0 +ellps=intl +units=m +no_defs")
  ) +
  scale_color_manual(
    values = region_colors,
    breaks = region_order,
    labels = region_order
  ) +
  theme(
    legend.position = "bottom",
    axis.title = element_blank(),
    axis.text = element_blank(),
    panel.grid.major = element_line(colour = "black", size = 0.3),
    axis.ticks = element_blank(),
    panel.border = element_rect(colour = "black", size = 2)
  ) +
  guides(
    color = FALSE,
    shape = FALSE,
    size = FALSE
  )

#### combine map_A and map_B ####

combined_map <- ggdraw() +
  draw_plot(map_A, 0, 0, 1, 1) +
  draw_plot(map_B, 0.55, 0.05, 0.42, 0.42) +
  draw_plot_label(c("A", "B"), c(0.08, 0.56), c(0.99, 0.4), size = 35)

combined_map %>%
  ggsave(
    "analysis/figures/map.jpeg",
    plot = .,
    device = "jpeg",
    scale = 1,
    dpi = 300,
    width = 330, height = 410, units = "mm",
    limitsize = F
  )
