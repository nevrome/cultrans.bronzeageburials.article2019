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

#### map_A ####

xlimit <- c(-1600000, 1300000)
ylimit <- c(800000, 3800000)

map_A <- ggplot() +
  geom_sf(
    data = land_outline,
    fill = "white", colour = "black", size = 0.4
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
    xlim = xlimit, ylim = ylimit,
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
      "flat" = 10,
      "mound" = 10,
      "unknown" = 5
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
    plot.title = element_text(size = 30, face = "bold"),
    legend.position = "bottom",
    legend.title = element_text(size = 20, face = "bold"),
    axis.title = element_blank(),
    axis.text = element_text(size = 15),
    legend.text = element_text(size = 20),
    panel.grid.major = element_line(colour = "black", size = 0.3)
  ) +
  guides(
    color = guide_legend(title = "Burial type", override.aes = list(size = 10), nrow = 2, byrow = TRUE),
    shape = guide_legend(title = "Burial construction", override.aes = list(size = 10), nrow = 2, byrow = TRUE),
    size = FALSE
  )

map_A %>%
  ggsave(
    "analysis/figures/map_A.jpeg",
    plot = .,
    device = "jpeg",
    scale = 1,
    dpi = 300,
    width = 350, height = 360, units = "mm",
    limitsize = F
  )

#### map_B ####

map_B <- ggplot() +
  geom_sf(
    data = land_outline,
    fill = "white", colour = "black", size = 0.4
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
    xlim = xlimit, ylim = ylimit,
    crs = st_crs("+proj=aea +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10 +x_0=0 +y_0=0 +ellps=intl +units=m +no_defs")
  ) +
  scale_color_manual(
    values = region_colors,
    breaks = region_order,
    labels = region_order
  ) +
  theme(
    plot.title = element_text(size = 30, face = "bold"),
    legend.position = "bottom",
    legend.title = element_text(size = 20, face = "bold"),
    axis.title = element_blank(),
    axis.text = element_blank(),
    legend.text = element_text(size = 17),
    panel.grid.major = element_line(colour = "black", size = 0.3)
  ) +
  guides(
    color = FALSE,
    shape = FALSE,
    size = FALSE
  )

map_B %>%
  ggsave(
    "analysis/figures/map_B",
    plot = .,
    device = "jpeg",
    scale = 1,
    dpi = 300,
    width = 350, height = 320, units = "mm",
    limitsize = F
  )

