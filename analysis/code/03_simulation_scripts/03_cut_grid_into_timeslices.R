load("analysis/data/tmp_data/sed_simulation_regions_grid.RData")

##### cut sed regions grid into timeslices ####

modelid_time_regions_grid <- regions_grid %>% dplyr::mutate(
  time = base::cut(
    time,
    seq(-2200, -800, 200), labels = paste(seq(-2200, -1000, 200), seq(-2000, -800, 200), sep = " - "),
    include.lowest = TRUE,
    right = FALSE)
) %>%
  dplyr::group_by(
    model_group, model_id, time, regionA, regionB
  ) %>%
  dplyr::summarise(
    mean_sed = mean(sed, na.rm = TRUE)
  ) %>%
  dplyr::ungroup() %>%
  # that's dangerous...
  dplyr::mutate(
    mean_sed = tidyr::replace_na(mean_sed, 0)
  )

#### create list of matrizes from timesliced regions grid ####

distance_matrizes_sed <- lapply(
  base::split(modelid_time_regions_grid, modelid_time_regions_grid$model_id), function(time_regions_grid) {
    lapply(
      base::split(time_regions_grid, time_regions_grid$time), function(x){
        x %>%
          dplyr::select(
            -model_group, -model_id, -time
          ) %>%
          tidyr::spread(regionA, mean_sed) %>%
          dplyr::select(
            -regionB
          ) %>%
          as.matrix()
      }
    )
  }
)

save(distance_matrizes_sed, file = "analysis/data/tmp_data/sed_simulation_regions_timeslices_matrizes.RData")
