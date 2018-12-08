library(magrittr)

lapply(
  c(
    "analysis/code/01_data_preparation_scripts",
    "analysis/code/02_analysis_scripts",
    "analysis/code/03_simulation_scripts",
    "analysis/code/04_plot_scripts"
  ),
  function(x) {
    pbapply::pblapply(
      list.files(x, full.names = TRUE),
      function(y) {
        message("\n###### ", y, " ######\n")
        source(y)
        rm(list = ls())
      }
    )
  }
)
