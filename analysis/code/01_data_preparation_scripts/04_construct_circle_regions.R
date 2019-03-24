#### load data ####

load("analysis/data/tmp_data/research_area.RData")
load("analysis/data/tmp_data/area.RData")
load("analysis/data/tmp_data/region_order.RData")



#### construct region circles ####

region_circles <- tibble::tibble(
  geometry = sf::st_make_grid(area, 400000, what = "centers", offset = c(-900000,-130000)),
  ID = 1:length(geometry)
  ) %>% sf::st_as_sf()
region_circles <- sf::st_intersection(region_circles, research_area)
region_circles %<>% sf::st_buffer(dist = 240000)



#### select regions with enough graves ####

load("analysis/data/tmp_data/graves_prepared.RData")
graves_prepared %<>% sf::st_as_sf(coords = c("lon", "lat"))
sf::st_crs(graves_prepared) <- 4326
graves_prepared %<>% sf::st_transform("+proj=aea +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10 +x_0=0 +y_0=0 +ellps=intl +units=m +no_defs")

inter_area <- sf::st_intersection(graves_prepared, research_area) %>% dplyr::select(-id)
inter_regions <- sf::st_intersection(inter_area, region_circles) %>% dplyr::select(-id)

number_of_graves_per_circle <- inter_regions %>%
  dplyr::group_by(ID) %>%
  dplyr::summarise(
    n = dplyr::n()
  )

regions_with_enough_graves <- number_of_graves_per_circle %>%
  dplyr::filter(
    n >= 60
  ) %$%
  ID



#### define resulting regions with name ####

regions <- region_circles %>%
  dplyr::mutate(
    number_of_graves = number_of_graves_per_circle$n
  ) %>%
  dplyr::filter(ID %in% regions_with_enough_graves)

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
regions$NAME <- factor(regions$NAME, levels = region_order)

save(regions, file = "analysis/data/tmp_data/regions.RData")
