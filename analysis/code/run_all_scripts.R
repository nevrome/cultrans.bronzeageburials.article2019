library(magrittr)

purrr::walk(
  c(
    "analysis/code/01_data_preparation_scripts",
    "analysis/code/02_cultural_distance_scripts",
    "analysis/code/03_dataset_description_scripts",
    "analysis/code/04_plot_scripts"
  ),
  function(x) {
    purrr::walk(
      list.files(x, full.names = TRUE),
      function(y) {
        message("\n###### ", y, " ######\n")
        source(y)
        rm(list = ls())
      }
    )
  }
)
