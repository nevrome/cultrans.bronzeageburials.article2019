source("analysis/code/helper_functions/neiman_simulation.R")

load("analysis/data/tmp_data/region_order.RData")

#### setup settings grid ####

models_grid <- expand.grid(
  k = 2,
  N_g = 100,
  t_final = 1400,
  mu = 0,
  g = 8,
  mi = c(0, 0.01, 0.1, 0.5),
  I = list(matrix(1, 8, 8), matrix(runif(64), 8, 8))
) %>%
  tibble::as.tibble() %>%
  dplyr::mutate(
    model_group = 1:nrow(.)
  ) %>%
  tidyr::uncount(10) %>%
  dplyr::mutate(
    model_id = 1:nrow(.)
  )

save(models_grid, file = "analysis/data/tmp_data/sed_simulation_model_grid.RData")


#### run simulation ####

models <- pbapply::pblapply(
  1:nrow(models_grid),
  function(i, models_grid) {
    neiman_simulation(
      models_grid$k[i],
      models_grid$N_g[i],
      models_grid$t_final[i],
      models_grid$mu[i],
      models_grid$g[i],
      models_grid$mi[i],
      models_grid$I[[i]]
    ) %>% standardize_neiman_output(., region_order) %>%
      dplyr::mutate(
        model_id = models_grid$model_id[i],
        model_group = models_grid$model_group[i],
        region_population_size = models_grid$N_g[i],
        degree_interregion_interaction = models_grid$mi[i]
      )
  },
  models_grid,
  cl = 3
)

#### store results in file system ####

save(models, file = "analysis/data/tmp_data/simulation_models.RData")

