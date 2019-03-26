#### load data ####

load("analysis/data/tmp_data/regions.RData")
load("analysis/data/tmp_data/region_order.RData")



#### establish distance information in tall format ####

# find region centers
region_centers <- regions %>%
  sf::st_centroid()

distance_matrix_spatial_long <- region_centers %>%
  # calculate distance matrix
  sf::st_distance() %>%
  # normalize distance matrix
  magrittr::divide_by(min(.[. != min(.)])) %>%
  as.matrix() %>%
  tibble::as_tibble() %>%
  # set correct names
  magrittr::set_colnames(region_centers$NAME) %>%
  dplyr::mutate(regionA = region_centers$NAME) %>%
  # wide matrix to tall data.frame
  tidyr::gather(key = regionB, value = distance, -regionA) %>%
  dplyr::mutate(
    regionB = factor(regionB, levels = region_order),
    distance = as.double(distance)
  ) %>%
  # creation of distance classes
  dplyr::mutate(
    distance = base::cut(
      distance,
      seq(0, 4, 0.4), paste(seq(0, 3.6, 0.4), seq(0.4, 4.0, 0.4), sep = "-"),
      include.lowest = TRUE,
      right = FALSE)
  ) %>%
  # rename actually relevant classes
  dplyr::mutate(
    distance = dplyr::case_when(
      distance == "0-0.4" ~ 0,
      distance == "0.8-1.2" ~ 1,
      distance == "1.2-1.6" ~ 2,
      distance == "2-2.4" ~ 3,
      distance == "2.8-3.2" ~ 4
    )
  )

save(distance_matrix_spatial_long, file = "analysis/data/tmp_data/distance_matrix_spatial_long.RData")



#### remove duplicates from distance matrix ####

mn <- pmin(as.character(distance_matrix_spatial_long$regionA), as.character(distance_matrix_spatial_long$regionB))
mx <- pmax(as.character(distance_matrix_spatial_long$regionA), as.character(distance_matrix_spatial_long$regionB))
int <- as.numeric(interaction(mn, mx))
distance_matrix_spatial_long_half <- distance_matrix_spatial_long[match(unique(int), int),]

save(distance_matrix_spatial_long_half, file = "analysis/data/tmp_data/distance_matrix_spatial_long_half.RData")



#### transform distance information to wide format ####

distance_matrix_spatial <- distance_matrix_spatial_long %>%
  tidyr::spread(regionA, distance) %>%
  dplyr::select(
    -regionB
  ) %>%
  as.matrix()

save(distance_matrix_spatial, file = "analysis/data/tmp_data/distance_matrix_spatial.RData")
