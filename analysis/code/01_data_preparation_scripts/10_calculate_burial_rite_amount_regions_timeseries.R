#### load data ####

load("analysis/data/tmp_data/graves_per_year_and_region.RData")



#### calculate per year, per region appearance of graves ####

# burial type
amount_development_burial_type_without_zero <- graves_per_year_and_region %>%
  dplyr::group_by(region, age, burial_type) %>%
  dplyr::rename(
    timestep = age,
    idea = burial_type
  ) %>%
  dplyr::tally()

amount_development_burial_type <- amount_development_burial_type_without_zero %>%
  dplyr::right_join(
    expand.grid(
      region = unique(amount_development_burial_type_without_zero$region),
      idea = unique(amount_development_burial_type_without_zero$idea),
      timestep = -2200:-800,
      stringsAsFactors = FALSE
    ),
    by = c("region", "timestep", "idea")
  ) %>%
  dplyr::mutate(
    n = replace(n, is.na(n), 0)
  )

save(
  amount_development_burial_type,
  file = "analysis/data/tmp_data/development_amount_burial_type.RData"
)

# burial construction
amount_development_burial_construction_without_zero <- graves_per_year_and_region %>%
  dplyr::group_by(region, age, burial_construction) %>%
  dplyr::rename(
    timestep = age,
    idea = burial_construction
  ) %>%
  dplyr::tally()

amount_development_burial_construction  <- amount_development_burial_construction_without_zero%>%
  dplyr::right_join(
    expand.grid(
      region = unique(amount_development_burial_construction_without_zero$region),
      idea = unique(amount_development_burial_construction_without_zero$idea),
      timestep = -2200:-800,
      stringsAsFactors = FALSE
    ),
    by = c("region", "timestep", "idea")
  ) %>%
  dplyr::mutate(
    n = replace(n, is.na(n), 0)
  )

save(
  amount_development_burial_construction,
  file = "analysis/data/tmp_data/development_amount_burial_construction.RData"
)
