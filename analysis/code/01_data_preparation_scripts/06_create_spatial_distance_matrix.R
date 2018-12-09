#### load regions data ####

load("analysis/data/tmp_data/regions.RData")

#### create distance information in tall format ####

# find region centers
region_centers <- regions %>%
  sf::st_centroid()

distance_matrix_spatial_long <- region_centers %>%
  # calculate distance matrix
  sf::st_distance() %>%
  # normalize distance matrix
  magrittr::divide_by(min(.[. != min(.)])) %>%
  tibble::as.tibble() %>%
  # set correct names
  magrittr::set_colnames(region_centers$NAME) %>%
  dplyr::mutate(regionA = region_centers$NAME) %>%
  # wide matrix to tall data.frame
  tidyr::gather(key = regionB, value = distance, -regionA) %>%
  dplyr::mutate(
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

# remove duplicates
mn <- pmin(as.character(distance_matrix_spatial_long$regionA), as.character(distance_matrix_spatial_long$regionB))
mx <- pmax(as.character(distance_matrix_spatial_long$regionA), as.character(distance_matrix_spatial_long$regionB))
int <- as.numeric(interaction(mn, mx))
distance_matrix_spatial_long_half <- distance_matrix_spatial_long[match(unique(int), int),]

#### define factor order ####

load("analysis/data/tmp_data/region_order.RData")

regions_factorA <- as.factor(distance_matrix_spatial_long$regionA)
distance_matrix_spatial_long$regionA <- factor(regions_factorA, levels = region_order)
regions_factorB <- as.factor(distance_matrix_spatial_long$regionB)
distance_matrix_spatial_long$regionB <- factor(regions_factorB, levels = region_order)

regions_factorA <- as.factor(distance_matrix_spatial_long_half$regionA)
distance_matrix_spatial_long_half$regionA <- factor(regions_factorA, levels = region_order)
regions_factorB <- as.factor(distance_matrix_spatial_long_half$regionB)
distance_matrix_spatial_long_half$regionB <- factor(regions_factorB, levels = region_order)

#### transform distance information to wide format ####

distance_matrix_spatial <- distance_matrix_spatial_long %>%
  tidyr::spread(regionA, distance) %>%
  dplyr::select(
    -regionB
  ) %>%
  as.matrix()

#### writing files to file system ####

save(distance_matrix_spatial_long_half, file = "analysis/data/tmp_data/distance_matrix_spatial_long_half.RData")
save(distance_matrix_spatial_long, file = "analysis/data/tmp_data/distance_matrix_spatial_long.RData")
save(distance_matrix_spatial, file = "analysis/data/tmp_data/distance_matrix_spatial.RData")
