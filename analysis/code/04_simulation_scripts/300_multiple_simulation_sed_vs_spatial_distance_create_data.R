load("data_analysis/region_order.RData")
load("data_simulation/sed_simulation_regions_grid.RData")
load("data_analysis/distance_matrix_spatial_long.RData")

#### half regions_grid -- removal of double entries ####

regions_grid$regionA <- as.character(regions_grid$regionA)
regions_grid$regionB <- as.character(regions_grid$regionB)

regions_grid_half <- pbapply::pblapply(
  base::split(regions_grid, f = regions_grid$model_group), function(z) { 
    lapply(
      base::split(z, f = regions_grid$model_id), function(y) { 
        lapply(
          base::split(y, f = y$time), function(x) {
            mn <- pmin(x$regionA, x$regionB)
            mx <- pmax(x$regionA, x$regionB)
            int <- as.numeric(interaction(mn, mx))
            x <- x[match(unique(int), int),]
            return(x)
          }) %>%
          do.call(rbind, .)
      }) %>%
      do.call(rbind, .)    
  }) %>%
  do.call(rbind, .)

regions_grid_half$regionA <- factor(regions_grid_half$regionA, levels = region_order)
regions_grid_half$regionB <- factor(regions_grid_half$regionB, levels = region_order)

#### combine spatial and cultural distance into one data.frame ####

sed_spatial_distance <- regions_grid_half %>% dplyr::left_join(
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
    model_id, model_group, time, regionA, regionB, distance
  ) %>%
  dplyr::summarise(
    mean_sed = mean(sed, na.rm = TRUE)
  ) %>%
  dplyr::ungroup() %>%
  dplyr::filter(
    !is.na(mean_sed)
  )

save(
  sed_spatial_distance, 
  file = "data_simulation/sed_simulation_regions_timeslices_spatial_distance.RData"
)
