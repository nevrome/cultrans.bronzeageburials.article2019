sed <- function(pi, pj) {
  pi <- pi / sum(pi)
  pj <- pj / sum(pj)
  sum((pi - pj)^2)
}

save(sed, file = "analysis/data/tmp_data/sed_function.RData")
