load("analysis/data/tmp_data/distance_matrizes_sed_burial_type.RData")
dms_burial_type <- distance_matrizes_sed

load("analysis/data/tmp_data/distance_matrizes_sed_burial_construction.RData")
dms_burial_construction <- distance_matrizes_sed

mantel_test_results <- lapply(
  1:length(dms_burial_type), function(i, x, y, z) {
    mantel_result <- vegan::mantel(x[[i]], y[[i]], method = "pearson", permutations=999)
    data.frame(
      time = z[[i]],
      statistic = mantel_result$statistic,
      signif = mantel_result$signif
    )
  },
  x = dms_burial_type,
  y = dms_burial_construction,
  z = names(dms_burial_type)
) %>%
  do.call(rbind, .)

save(
  mantel_test_results,
  file = "analysis/data/tmp_data/mantel_sed_spatial_burial_type_burial_construction.RData"
)
