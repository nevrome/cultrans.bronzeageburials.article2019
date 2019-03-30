#### load data ####

load("analysis/data/tmp_data/distance_matrix_spatial.RData")
load("analysis/data/tmp_data/distance_matrizes_sed_burial_construction.RData")



#### mantel test sed vs. spatial distance in 200-years time slots ####

mantel_test_results <- lapply(
  1:length(distance_matrizes_sed), function(i, x, y, a) {
    xi <- x[[i]] %>% as.dist()
    mantel_result <- ecodist::mantel(xi ~ y, nperm = 999, mrank = T)
    data.frame(
      time = a[[i]],
      statistic = mantel_result[["mantelr"]],
      signif = mantel_result[["pval1"]]
    )
  },
  x = distance_matrizes_sed,
  y = distance_matrix_spatial %>% as.dist(),
  a = names(distance_matrizes_sed)
) %>%
  do.call(rbind, .)

save(
  mantel_test_results,
  file = "analysis/data/tmp_data/mantel_sed_spatial_burial_construction.RData"
)


