load("analysis/data/tmp_data/distance_matrix_spatial.RData")
load("analysis/data/tmp_data/sed_simulation_regions_timeslices_matrizes.RData")

mantel_test_results <- pbapply::pblapply(
  1:length(distance_matrizes_sed), function(i, x, y, model_id) {
      lapply(
        1:length(x[[i]]), function(i, x, y, time, model_id) {
          mantel_result <- vegan::mantel(x[[i]], y, method = "spear", permutations=999)
          data.frame(
            model_id = model_id,
            time = time[[i]],
            statistic = mantel_result$statistic,
            signif = mantel_result$signif
          )
        },
        x = x[[i]],
        y = y,
        time = names(x[[i]]),
        model_id = model_id[[i]]
      ) %>% do.call(rbind, .)
    },
    x = distance_matrizes_sed,
    y = distance_matrix_spatial,
    model_id = names(distance_matrizes_sed)
  ) %>% do.call(rbind, .) %>% tibble::as.tibble()

save(
  mantel_test_results,
  file = "analysis/data/tmp_data/sed_simulation_mantel_sed_spatial.RData"
)
