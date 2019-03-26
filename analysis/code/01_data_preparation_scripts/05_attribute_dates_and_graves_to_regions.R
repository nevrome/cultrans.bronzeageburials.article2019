#### load data ####

load("analysis/data/tmp_data/regions.RData")
load("analysis/data/tmp_data/dates_prepared.RData")
load("analysis/data/tmp_data/graves_prepared.RData")



#### attribute dates to regions ####

dates_prepared %<>% sf::st_as_sf(coords = c("lon", "lat"))
sf::st_crs(dates_prepared) <- 4326
dates_prepared %<>% sf::st_transform("+proj=aea +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10 +x_0=0 +y_0=0 +ellps=intl +units=m +no_defs")

inter_regions_dates <- sf::st_intersection(dates_prepared, regions)

dates_per_region <- inter_regions_dates %>% sf::st_set_geometry(NULL) %>%
  dplyr::mutate(
    region = NAME
  ) %>%
  dplyr::select(
    -id, -ID, -NAME
  )

save(
  dates_per_region,
  file = "analysis/data/tmp_data/dates_per_region.RData"
)



#### attribute graves to regions ####

graves_prepared %<>% sf::st_as_sf(coords = c("lon", "lat"))
sf::st_crs(graves_prepared) <- 4326
graves_prepared %<>% sf::st_transform("+proj=aea +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10 +x_0=0 +y_0=0 +ellps=intl +units=m +no_defs")

inter_regions_graves <- sf::st_intersection(graves_prepared, regions)

graves_per_region <- inter_regions_graves %>% sf::st_set_geometry(NULL) %>%
  dplyr::mutate(
    region = NAME
  ) %>%
  dplyr::select(
    -id, -ID, -NAME
  )

save(
  graves_per_region,
  file = "analysis/data/tmp_data/graves_per_region.RData"
)
