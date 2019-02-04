load("analysis/data/tmp_data/squared_euclidian_distance_over_time_burial_construction.RData")
load("analysis/data/tmp_data/distance_matrix_spatial_long.RData")
load("analysis/data/tmp_data/region_order.RData")

test <- regions_grid %>%
  dplyr::mutate(
    regionA = as.character(regionA),
    regionB = as.character(regionB)
  )

distance_matrix_spatial_long %<>%
  dplyr::mutate(
    regionA = as.character(regionA),
    regionB = as.character(regionB)
  )

test <- lapply(
  split(test, f = test$time),
  function(x) {
    mn <- pmin(x$regionA, x$regionB)
    mx <- pmax(x$regionA, x$regionB)
    int <- as.numeric(interaction(mn, mx))
    x <- x[match(unique(int), int),]
    return(x)
  }
) %>%
  do.call(rbind, .)

sed_spatial_distance <- test %>% dplyr::left_join(
  distance_matrix_spatial_long, by = c("regionA", "regionB")
) %>%
  dplyr::filter(
    distance != 0
  ) %>%
  dplyr::mutate(
    relation = paste(regionA, "+", regionB),
    time = base::cut(
      time,
      seq(-2200, -800, 200), labels = paste(seq(-2200, -1000, 200), seq(-2000, -800, 200), sep = " - "),
      include.lowest = TRUE,
      right = FALSE)
  ) %>%
  dplyr::group_by(
    time, regionA, regionB, distance
  ) %>%
  dplyr::summarise(
    mean_sed = mean(sed, na.rm = TRUE)
  ) %>%
  dplyr::ungroup() %>%
  dplyr::filter(
    !is.na(mean_sed)
  )

regions_factorA <- as.factor(sed_spatial_distance$regionA)
sed_spatial_distance$regionA <- factor(regions_factorA, levels = region_order)

regions_factorB <- as.factor(sed_spatial_distance$regionB)
sed_spatial_distance$regionB <- factor(regions_factorB, levels = region_order)

save(sed_spatial_distance, file = "analysis/data/tmp_data/squared_euclidian_distance_over_timeblocks_burial_construction.RData")
