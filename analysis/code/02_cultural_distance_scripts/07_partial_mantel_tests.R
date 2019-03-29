#### load data ####

load("analysis/data/tmp_data/distance_matrizes_sed_burial_type.RData")
dms_burial_type <- distance_matrizes_sed
load("analysis/data/tmp_data/distance_matrizes_sed_burial_construction.RData")
dms_burial_construction <- distance_matrizes_sed
load("analysis/data/tmp_data/distance_matrix_spatial.RData")
dms_spatial <- distance_matrix_spatial

mantel_test_results <- lapply(
  1:length(dms_burial_type), function(i, x, y, z, a) {
    xi <- x[[i]] %>% as.dist()
    yi <- y[[i]] %>% as.dist()
    mantel_result <- ecodist::mantel(yi ~ xi + z, nperm = 999, mrank = T)
    data.frame(
      time = a[[i]],
      statistic = mantel_result[["mantelr"]],
      signif = mantel_result[["pval1"]]
    )
  },
  x = dms_burial_type,
  y = dms_burial_construction,
  z = dms_spatial %>% as.dist(),
  a = names(dms_burial_type)
) %>%
  do.call(rbind, .)

save(
  mantel_test_results,
  file = "analysis/data/tmp_data/mantel_sed_burial_type_burial_construction_spatial.RData"
)
