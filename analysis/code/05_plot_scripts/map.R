library(ggplot2)
library(sf)
library(cowplot)
library(magrittr)

load("analysis/data/tmp_data/land_outline.RData")
load("analysis/data/tmp_data/rivers.RData")
load("analysis/data/tmp_data/lakes.RData")
load("analysis/data/tmp_data/countries.RData")
research_area <- sf::st_read("analysis/data/input_data/research_area_shapefile/research_area.shp")
load("analysis/data/tmp_data/regions.RData")
load("analysis/data/tmp_data/bronze1.RData")
load("analysis/data/tmp_data/region_order.RData")
load("analysis/data/tmp_data/region_colors.RData")
load("analysis/data/tmp_data/distance_matrix_spatial_long.RData")

bronze1_sf <- bronze1 %>% sf::st_as_sf(
  coords = c("lon", "lat"),
  crs = 4326
)

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
  geom_sf(
    data = research_area,
    fill = NA, colour = "red", size = 0.8
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
    legend.title = element_text(size = 30, face = "bold"),
    axis.title = element_blank(),
    axis.text = element_blank(),
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

map_A %>%
  ggsave(
    "analysis/figures/map_graves.jpeg",
    plot = .,
    device = "jpeg",
    scale = 1,
    dpi = 300,
    width = 330, height = 420, units = "mm",
    limitsize = F
  )


#### map_B ####

region_centers <- regions %>%
  sf::st_centroid()

sfc_as_cols <- function(x, names = c("x","y")) {
  stopifnot(inherits(x,"sf") && inherits(sf::st_geometry(x),"sfc_POINT"))
  ret <- do.call(rbind,sf::st_geometry(x))
  ret <- tibble::as_tibble(ret)
  stopifnot(length(names) == ncol(ret))
  ret <- setNames(ret,names)
  dplyr::bind_cols(x,ret)
}

region_centers %>%
  sfc_as_cols() %>%
  dplyr::select(
    NAME, x, y
  )

region_labels <- as.data.frame(sf::st_coordinates(region_centers))
region_labels$NAME <- region_centers$NAME

ex <- raster::extent(regions)

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
      colour = NAME,
      fill = NAME
    ),
    alpha = 0.3, size = 2.5
  ) +
  geom_sf(
    data = research_area,
    fill = NA, colour = "red", size = 0.8
  ) +
  shadowtext::geom_shadowtext(
    data = region_labels,
    mapping = aes(X, Y, label = NAME),
    colour = "black",
    bg.colour = "white",
    size = 9,
    angle = 45
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
  scale_fill_manual(
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
    size = FALSE,
    fill = FALSE
  )

#### map_C ####

distance_lines <- distance_matrix_spatial_long %>%
  dplyr::left_join(
    region_centers,
    by = c("regionA" = "NAME")
  ) %>%
  dplyr::left_join(
    region_centers,
    by = c("regionB" = "NAME"),
    suffix = c("_regionA", "_regionB")
  ) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(
    x_a = st_coordinates(geometry_regionA)[,1],
    y_a = st_coordinates(geometry_regionA)[,2],
    x_b = st_coordinates(geometry_regionB)[,1],
    y_b = st_coordinates(geometry_regionB)[,2]
  ) %>%
  dplyr::ungroup() %>%
  dplyr::select(
    regionA, regionB, distance, x_a, y_a, x_b, y_b
  ) %>%
  dplyr::filter(
    regionA != regionB
  )

mn <- pmin(distance_lines$regionA, distance_lines$regionB)
mx <- pmax(distance_lines$regionA, distance_lines$regionB)
int <- as.numeric(interaction(mn, mx))
distance_lines <- distance_lines[match(unique(int), int),]

xlimit <- c(ex[1], ex[2])
ylimit <- c(ex[3], ex[4])

map_C <- ggplot() +
  geom_sf(
    data = land_outline,
    fill = "white", colour = "black", size = 0.7
  ) +
  geom_sf(
    data = countries,
    fill = NA, colour = "black", size = 0.2
  ) +
  geom_curve(
    data = distance_lines,
    mapping = aes(
      x = x_a, y = y_a, xend = x_b, yend = y_b,
      size = distance
    ),
    alpha = 0.5,
    curvature = 0.2,
    colour = "black"
  ) +
  scale_size_continuous(
    range = c(5, 0.5)
  ) +
  geom_sf(
    data = region_centers,
    mapping = aes(
      colour = NAME
    ),
    fill = NA, size = 16
  ) +
  geom_sf(
    data = research_area,
    fill = NA, colour = "red", size = 0.8
  ) +
  theme_bw() +
  coord_sf(
    xlim = xlimit, ylim = ylimit,
    crs = st_crs("+proj=aea +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10 +x_0=0 +y_0=0 +ellps=intl +units=m +no_defs")
  ) +
  theme(
    legend.position = "bottom",
    legend.box = "vertical",
    legend.title = element_text(size = 30, face = "bold"),
    legend.text = element_text(size = 15),
    axis.title = element_blank(),
    axis.text = element_blank(),
    panel.grid.major = element_line(colour = "black", size = 0.3),
    axis.ticks = element_blank(),
    panel.border = element_rect(colour = "black", size = 2)
  ) +
  guides(
    # color = guide_legend(title = "Regions", override.aes = list(shape = 1, size = 10), nrow = 4, byrow = TRUE),
    # size = guide_legend(title = "Spatial closeness", nrow = 1, byrow = TRUE),
    color = FALSE,
    size = FALSE,
    shape = FALSE
  ) +
  scale_color_manual(
    values = region_colors,
    breaks = region_order,
    labels = region_order
  )

#### combine maps ####

combined_map <- plot_grid(
  map_B,
  map_C,
  labels = c("A", "B"),
  rel_heights = c(1, 1),
  nrow = 2,
  align = "h",
  axis = "lr",
  label_size = 35
)

combined_map %>%
  ggsave(
    "analysis/figures/map_regions.jpeg",
    plot = .,
    device = "jpeg",
    scale = 1,
    dpi = 300,
    width = 330, height = 440, units = "mm",
    limitsize = F
  )
