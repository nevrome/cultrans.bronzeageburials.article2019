#### load data ####

load("analysis/data/tmp_data/squared_euclidian_distance_over_time_burial_type.RData")



#### calculate region-region sed for 200-years time slots ####

time_regions_grid <- regions_grid %>% dplyr::mutate(
  time = base::cut(
    time,
    seq(-2200, -800, 200), labels = paste(seq(-2200, -1000, 200), seq(-2000, -800, 200), sep = " - "),
    include.lowest = TRUE,
    right = FALSE)
) %>%
  dplyr::group_by(
    time, regionA, regionB
  ) %>%
  dplyr::summarise(
    mean_sed = mean(sed, na.rm = TRUE)
  ) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(
    mean_sed = tidyr::replace_na(mean_sed, 0)
  )

save(time_regions_grid, file = "analysis/data/tmp_data/time_regions_grid_sed_burial_type.RData")



#### create distance matrixes of all regions for 200-years time slots ####

distance_matrizes_sed <- lapply(
  base::split(time_regions_grid, time_regions_grid$time), function(x){
    x %>%
      dplyr::select(
        -time
      ) %>%
      tidyr::spread(regionA, mean_sed) %>%
      dplyr::select(
        -regionB
      ) %>%
      as.matrix()
  }
)

save(distance_matrizes_sed, file = "analysis/data/tmp_data/distance_matrizes_sed_burial_type.RData")
