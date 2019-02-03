#### calculate

load("analysis/data/tmp_data/dates_probability_per_year_and_region_df.RData")

amount_development_burial_type_without_zero <- dates_probability_per_year_and_region_df %>%
  dplyr::group_by(region_name, age, burial_type) %>%
  dplyr::rename(
    timestep = age,
    idea = burial_type
  ) %>%
  dplyr::tally()

amount_development_burial_type <- amount_development_burial_type_without_zero %>%
  dplyr::right_join(
    expand.grid(
      region_name = unique(amount_development_burial_type_without_zero$region_name),
      idea = unique(amount_development_burial_type_without_zero$idea),
      timestep = -2200:-800,
      stringsAsFactors = FALSE
    ),
    by = c("region_name", "timestep", "idea")
  ) %>%
  dplyr::mutate(
    n = replace(n, is.na(n), 0)
  )

save(
  amount_development_burial_type,
  file = "analysis/data/tmp_data/development_amount_burial_type.RData"
)

amount_development_burial_construction_without_zero <- dates_probability_per_year_and_region_df %>%
  dplyr::group_by(region_name, age, burial_construction) %>%
  dplyr::rename(
    timestep = age,
    idea = burial_construction
  ) %>%
  dplyr::tally()

amount_development_burial_construction  <- amount_development_burial_construction_without_zero%>%
  dplyr::right_join(
    expand.grid(
      region_name = unique(amount_development_burial_construction_without_zero$region_name),
      idea = unique(amount_development_burial_construction_without_zero$idea),
      timestep = -2200:-800,
      stringsAsFactors = FALSE
    ),
    by = c("region_name", "timestep", "idea")
  ) %>%
  dplyr::mutate(
    n = replace(n, is.na(n), 0)
  )

save(
  amount_development_burial_construction,
  file = "analysis/data/tmp_data/development_amount_burial_construction.RData"
)

