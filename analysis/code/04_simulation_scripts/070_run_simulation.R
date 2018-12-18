source("analysis/code/helper_functions/neiman_simulation.R")

#### setup settings grid ####

config_matrix <- expand.grid(
  k = 2,
  N_g = c(50),
  t_final = 1400,
  mu = 0,
  g = 8,
  mi = c(0, 0.01, 0.1),
  I = NA
) %>%
  tibble::as.tibble() %>%
  dplyr::mutate(
    model_group = 1:nrow(.)
  ) %>%
  tidyr::uncount(8) %>%
  dplyr::mutate(
    model_id = 1:nrow(.)
  )



#### run simulation ####

models <- pbapply::pblapply(
  1:nrow(config_matrix),
  function(i, config_matrix) {
    neiman_simulation(
      config_matrix$k[i],
      config_matrix$N_g[i],
      config_matrix$t_final[i],
      config_matrix$mu[i],
      config_matrix$g[i],
      config_matrix$mi[i],
      config_matrix$I[i]
    ) %>% standardize_neiman_output %>%
      dplyr::mutate(
        model_id = config_matrix$model_id[i],
        model_group = config_matrix$model_group[i],
        region_population_size = config_matrix$N_g[i],
        degree_interregion_interaction = config_matrix$mi[i]
      )
  },
  config_matrix,
  cl = 2
)

#### store results in file system ####

save(models, file = "analysis/data/tmp_data/simulation_models.RData")

