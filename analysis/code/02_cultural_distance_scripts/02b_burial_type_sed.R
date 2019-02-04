load("analysis/data/tmp_data/sed_function.RData")
load("analysis/data/tmp_data/development_proportions_burial_type.RData")

prop <- proportion_development_burial_type

# proportion_development_burial_type %>%
#   tidyr::complete(
#     region_name, timestep, idea,
#     fill = list(proportion = as.integer(0))
#   )

long_prop <- prop %>%
  tidyr::spread(
    idea, proportion
  )

regions <- prop$region_name %>% unique()
timesteps <- prop$timestep %>% unique()

regions_grid <-
  expand.grid(
    regionA = regions, regionB = regions, time = timesteps,
    stringsAsFactors = FALSE
  ) %>%
  tibble::as.tibble() %>%
  dplyr::left_join(
    long_prop,
    by = c("regionA" = "region_name", "time" = "timestep")
  ) %>%
  dplyr::left_join(
    long_prop,
    by = c("regionB" = "region_name", "time" = "timestep"),
    suffix = c("_regionA", "_regionB")
  )

regions_grid <- regions_grid %>%
  dplyr::rowwise() %>%
  dplyr::mutate(
    sed = sed(c(cremation_regionA, inhumation_regionA), c(cremation_regionB, inhumation_regionB))
  ) %>%
  dplyr::ungroup() %>%
  dplyr::select(
    regionA, regionB, time, sed
  )

save(regions_grid, file = "analysis/data/tmp_data/squared_euclidian_distance_over_time_burial_type.RData")
