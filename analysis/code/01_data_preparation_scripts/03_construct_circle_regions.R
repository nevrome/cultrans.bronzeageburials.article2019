#### load spatial data ####

load("analysis/data/tmp_data/research_area.RData")
load("analysis/data/tmp_data/area.RData")

#### define region circles ####

region_circles <- tibble::tibble(
  geometry = sf::st_make_grid(area, 400000, what = "centers", offset = c(-900000,-130000)),
  ID = 1:length(geometry)
  ) %>% sf::st_as_sf()
region_circles <- sf::st_intersection(region_circles, research_area)
region_circles %<>% sf::st_buffer(dist = 240000)

load("analysis/data/tmp_data/bronze17.RData")
bronze17 %<>% sf::st_as_sf(coords = c("lon", "lat"))
sf::st_crs(bronze17) <- 4326
bronze17 %<>% sf::st_transform("+proj=aea +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10 +x_0=0 +y_0=0 +ellps=intl +units=m +no_defs")
gu <- sf::st_intersection(bronze17, research_area)

# library(ggplot2)
# ggplot() +
#   geom_sf(data = area) +
#   geom_sf(data = region_circles, fill = NA) +
#   geom_sf(data = gu)

schnu <- sf::st_intersection(gu, region_circles)

# ggplot() +
#   geom_sf(data = area) +
#   geom_sf(data = region_circles, fill = NA) +
#   geom_sf(data = schnu)

number_of_graves_per_circle <- schnu %>%
  dplyr::group_by(ID) %>%
  dplyr::summarise(
    n = n()
  )

regions_with_enough_graves <- number_of_graves_per_circle %>%
  dplyr::filter(
    n >= 60
  ) %$%
  ID

graves_per_region <- schnu %>% dplyr::filter(
  ID %in% regions_with_enough_graves
) %>% sf::st_set_geometry(NULL)

save(
  graves_per_region,
  file = "analysis/data/tmp_data/graves_per_region.RData"
)

regions <- region_circles %>%
  dplyr::mutate(
    number_of_graves = number_of_graves_per_circle$n
  ) %>%
  dplyr::filter(ID %in% regions_with_enough_graves)


# ggplot() +
#   geom_sf(data = area) +
#   geom_sf(data = regions, fill = NA) +
#   geom_sf(data = gu)

# regions %>%
#   dplyr::mutate(
#     x = purrr::map_dbl(geometry, ~sf::st_centroid(.x)[[1]]),
#     y = purrr::map_dbl(geometry, ~sf::st_centroid(.x)[[2]])
#   ) %>%
#   ggplot() +
#     geom_sf(data = area) +
#     geom_sf(fill = NA) +
#     geom_text(aes(x = x, y = y, label = ID))

regions$ID <- 1:nrow(regions)
regions$NAME <- c(
  "Northeastern France",
  "Southern Germany",
  "Southeastern Central Europe",
  "England", "Benelux",
  "Northern Germany",
  "Poland",
  "Southern Scandinavia"
  )

# regions %>%
#   dplyr::mutate(
#     x = purrr::map_dbl(geometry, ~sf::st_centroid(.x)[[1]]),
#     y = purrr::map_dbl(geometry, ~sf::st_centroid(.x)[[2]])
#   ) %>%
#   ggplot() +
#   geom_sf(data = area) +
#   geom_sf(fill = NA) +
#   geom_text(aes(x = x, y = y, label = NAME))

save(regions, file = "analysis/data/tmp_data/regions.RData")

