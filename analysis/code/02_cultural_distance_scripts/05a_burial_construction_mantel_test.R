load("analysis/data/tmp_data/distance_matrix_spatial.RData")
load("analysis/data/tmp_data/distance_matrizes_sed_burial_construction.RData")

mantel_test_results <- lapply(
  1:length(distance_matrizes_sed), function(i, x, y, z) {
    mantel_result <- vegan::mantel(x[[i]], y, method = "spear", permutations=999)
    data.frame(
      time = z[[i]],
      statistic = mantel_result$statistic,
      signif = mantel_result$signif
    )
  },
  x = distance_matrizes_sed,
  y = distance_matrix_spatial,
  z = names(distance_matrizes_sed)
) %>%
  do.call(rbind, .)

save(
  mantel_test_results,
  file = "analysis/data/tmp_data/mantel_sed_spatial_burial_construction.RData"
)


