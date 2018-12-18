load("data_analysis/region_order.RData")

##### read simulation output data #####

models <- pbapply::pblapply(
  list.files("../simulationdata/sed_simulation", full.names = TRUE),
  function(y) {
    read.csv(y) %>% tibble::as.tibble()
  }
)

prop <- do.call(rbind, models)

#### load sed function ####

load("data_analysis/sed_function.RData")

#### data preparation ####

long_prop <- prop %>%
  tidyr::spread(
    idea, proportion
  )

regions_grid <- 
  expand.grid(
    regionA = prop$region %>% unique(), 
    regionB = prop$region %>% unique(), 
    time = prop$timestep %>% unique(), 
    model_id =  prop$model_id %>% unique(),
    stringsAsFactors = FALSE
  ) %>%
  tibble::as.tibble() %>%
  dplyr::left_join(
    long_prop,
    by = c(
      "regionA" = "region", 
      "time" = "timestep", 
      "model_id" = "model_id"
    )
  ) %>%
  dplyr::left_join(
    subset(long_prop, select=-c(model_group)),
    by = c(
      "regionB" = "region", 
      "time" = "timestep", 
      "model_id" = "model_id"
    ),
    suffix = c("_regionA", "_regionB")
  )

region_A <- mapply(c, regions_grid$idea_1_regionA, regions_grid$idea_2_regionA, SIMPLIFY = FALSE)
region_B <- mapply(c, regions_grid$idea_1_regionB, regions_grid$idea_2_regionB, SIMPLIFY = FALSE)
region_A_region_B <- mapply(list, region_A, region_B, SIMPLIFY = FALSE)

regions_grid$sed <- unlist(pbapply::pblapply(
  region_A_region_B, function(x) {
    sed(x[[1]], x[[2]])
  }
))

regions_grid %<>% dplyr::select(
    regionA, regionB, time, sed, model_id, model_group
  )

regions_grid$regionA <- factor(regions_grid$regionA, levels = region_order)
regions_grid$regionB <- factor(regions_grid$regionB, levels = region_order)

save(regions_grid, file = "data_simulation/sed_simulation_regions_grid.RData")
