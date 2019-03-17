load("analysis/data/tmp_data/dates_probability_per_year_and_region_list.RData")

#### calculate per year, per region distribution of ideas ####

# helper function
fncols <- function(data, cname) {
  add <- cname[!cname %in% names(data)]
  if (length(add) != 0) {data[add] <- NA_real_}
  return(data)
}

# main loop
proportion_per_region <- dates_probability_per_year_and_region_list %>%
  # apply per region data.frame
  pbapply::pblapply(function(x) {

    # in case of empty regions or regions with only unknown graves: NULL
    if (nrow(x) == 0 |
        (all(x$burial_type == "unknown") &
         all(x$burial_construction == "unknown")))
    {

      res <- NULL

      # in case of unempty regions
    } else {

      #### burial_type: cremation vs. inhumation ####

      bt_basic <- x %>%
        dplyr::filter(
          burial_type != "unknown"
        )

      if (nrow(bt_basic) == 0) {
        bt <- tibble::tibble(
          region_name = character(),
          age = integer(),
          cremation = double(),
          inhumation = double()
        )
      } else {
        bt <- bt_basic %>%
          dplyr::group_by(age, burial_type) %>%
          dplyr::summarise(
            count = dplyr::n(), region_name = .$region_name[1]
          ) %>%
          tidyr::spread(
            key = burial_type, value = count
          ) %>%
          fncols(c("cremation", "inhumation")) %>%
          dplyr::mutate_all(dplyr::funs(replace(., is.na(.), 0))) %>%
          dplyr::mutate(
            cremation = cremation/(cremation + inhumation)
          ) %>%
          dplyr::mutate(
            inhumation = 1 - cremation
          ) %>%
          dplyr::ungroup()
      }

      #### burial_type: mound vs. flat ####

      bc_basic <- x %>%
        dplyr::filter(
          burial_construction != "unknown"
        )

      if (nrow(bc_basic) == 0) {
        bc <- tibble::tibble(
          region_name = character(),
          age = integer(),
          mound = double(),
          flat = double()
        )
      } else {
        bc <- bc_basic %>%
          dplyr::group_by(age, burial_construction) %>%
          dplyr::summarise(
            count = dplyr::n(), region_name = .$region_name[1]
          ) %>%
          tidyr::spread(
            key = burial_construction, value = count
          ) %>%
          fncols(c("mound", "flat")) %>%
          dplyr::mutate_all(dplyr::funs(replace(., is.na(.), 0))) %>%
          dplyr::mutate(
            mound = mound/(mound + flat)
          ) %>%
          dplyr::mutate(
            flat = 1 - mound
          ) %>%
          dplyr::ungroup()
      }

      # combine final result

      res <- dplyr::full_join(
        bt, bc, by = c("age", "region_name")
      ) %>%
        dplyr::mutate_all(dplyr::funs(replace(., is.na(.), 0)))

    }

    # complete result with 0 for years without information
    if (nrow(res) < 1401) {
      missing_ages <- c(-2200:-800)[!(c(-2200:-800) %in% res$age)]
      res <- rbind(
        res,
        tibble::tibble(
          region_name = res$region_name[1],
          age = missing_ages,
          cremation = 0,
          inhumation = 0,
          mound = 0,
          flat = 0
        )
      )
    }

    return(res)
  })

# merge per region information and transform to tall data.frame
proportion_per_region_df <- proportion_per_region %>%
  do.call(rbind, .) %>%
  dplyr::rename(
    "timestep" = "age"
  ) %>%
  tidyr::gather(
    idea, proportion, -timestep, -region_name
  ) %>%
  dplyr::select(
    region_name, timestep, idea, proportion
  )

proportion_development_burial_type <- proportion_per_region_df %>%
  dplyr::filter(idea %in% c("cremation", "inhumation"))

save(
  proportion_development_burial_type,
  file = "analysis/data/tmp_data/development_proportions_burial_type.RData"
)

proportion_development_burial_construction <- proportion_per_region_df %>%
  dplyr::filter(idea %in% c("flat", "mound"))

save(
  proportion_development_burial_construction,
  file = "analysis/data/tmp_data/development_proportions_burial_construction.RData"
)

