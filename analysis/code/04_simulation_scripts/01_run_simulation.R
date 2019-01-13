source("analysis/code/helper_functions/neiman_simulation.R")

load("analysis/data/tmp_data/region_order.RData")
load("analysis/data/tmp_data/distance_matrix_spatial.RData")
interaction_matrix_spatial <- (1/distance_matrix_spatial)^2
diag(interaction_matrix_spatial) <- 0

#### setup settings grid ####

models_grid <- expand.grid(
  k = 2,
  N_g = 100,
  t_start = -2200,
  t_end = -800,
  t_steps = 20,
  mu = 0,
  g = 8,
  I = list(NA, interaction_matrix_spatial),
  mi = c(0, 0.05, 0.5)
) %>%
  tibble::as.tibble() %>%
  dplyr::mutate(
    model_group = 1:nrow(.)
  ) %>%
  tidyr::uncount(50) %>%
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
      models_grid$t_start[i],
      models_grid$t_end[i],
      models_grid$t_steps[i],
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
  cl = 2
)

#### store results in file system ####

save(models, file = "analysis/data/tmp_data/simulation_models.RData")

