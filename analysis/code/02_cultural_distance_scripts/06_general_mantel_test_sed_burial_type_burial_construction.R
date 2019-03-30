#### load data ####

load("analysis/data/tmp_data/distance_matrizes_sed_burial_type.RData")
dms_burial_type <- distance_matrizes_sed
load("analysis/data/tmp_data/distance_matrizes_sed_burial_construction.RData")
dms_burial_construction <- distance_matrizes_sed



#### mantel test sed vs. sed in 200-years time slots ####

mantel_test_results <- lapply(
  1:length(dms_burial_type), function(i, x, y, a) {
    xi <- x[[i]] %>% as.dist()
    yi <- y[[i]] %>% as.dist()
    mantel_result <- ecodist::mantel(xi ~ yi , nperm = 999, mrank = F)
    data.frame(
      time = a[[i]],
      statistic = mantel_result[["mantelr"]],
      signif = mantel_result[["pval1"]]
    )
  },
  x = dms_burial_type,
  y = dms_burial_construction,
  a = names(dms_burial_type)
) %>%
  do.call(rbind, .)

save(
  mantel_test_results,
  file = "analysis/data/tmp_data/mantel_sed_burial_type_burial_construction.RData"
)
