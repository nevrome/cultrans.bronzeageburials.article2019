#### load data ####

load("analysis/data/tmp_data/sed_function.RData")
load("analysis/data/tmp_data/development_proportions_burial_construction.RData")



#### calculate yearwise region-region sed ####

# preparation of proportion data
prop <- proportion_development_burial_construction
long_prop <- prop %>%
  tidyr::spread(
    idea, proportion
  )
regions <- prop$region %>% unique()
timesteps <- prop$timestep %>% unique()

# regionA distribution vs. regionB distribution
regions_grid <-
  expand.grid(
    regionA = regions, regionB = regions, time = timesteps,
    stringsAsFactors = FALSE
  ) %>%
  tibble::as_tibble() %>%
  dplyr::left_join(
    long_prop,
    by = c("regionA" = "region", "time" = "timestep")
  ) %>%
  dplyr::left_join(
    long_prop,
    by = c("regionB" = "region", "time" = "timestep"),
    suffix = c("_regionA", "_regionB")
  )

# calculate distance
regions_grid <- regions_grid %>%
  dplyr::rowwise() %>%
  dplyr::mutate(
    sed = sed(c(flat_regionA, mound_regionA), c(flat_regionB, mound_regionB))
  ) %>%
  dplyr::ungroup() %>%
  dplyr::select(
    regionA, regionB, time, sed
  )

save(regions_grid, file = "analysis/data/tmp_data/squared_euclidian_distance_over_time_burial_construction.RData")
