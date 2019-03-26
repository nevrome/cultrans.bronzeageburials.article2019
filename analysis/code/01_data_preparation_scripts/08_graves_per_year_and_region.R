#### load data ####

load("analysis/data/tmp_data/graves_per_region.RData")



#### unnest graves table ####

# unnest calage_density_distribution to have per year information:
# a diachron perspective
graves_per_year_and_region <- graves_per_region %>%
  tidyr::unnest(calage_density_distribution) %>%
  dplyr::filter(
    two_sigma == TRUE
  ) %>%
  dplyr::filter(
    age >= -2200 & age <= -800
  ) %>%
  dplyr::arrange(
    desc(burial_construction)
  )

save(graves_per_year_and_region, file = "analysis/data/tmp_data/graves_per_year_and_region.RData")

graves_per_year_and_region_list <- graves_per_year_and_region %>% base::split(.$region)
save(graves_per_year_and_region_list, file = "analysis/data/tmp_data/graves_per_year_and_region_list.RData")
