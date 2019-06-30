library(magrittr)

#### set constants ####

# c14 reference zero
bol <- 1950
# 2sigma range probability threshold
threshold <- (1 - 0.9545) / 2



#### data download ####

# radonb <- c14bazAAR::get_RADONB()
# save(radonb, file = "analysis/data/input_data/radonb_04.02.2019/radonb.RData")
load("analysis/data/input_data/radonb_04.02.2019/radonb.RData")
save(radonb, file = "analysis/data/tmp_data/radonb.RData")



#### 14C calibration ####

load("analysis/data/tmp_data/radonb.RData")

dates <- radonb %>%
  tibble::as_tibble() %>%
  # remove dates without age
  dplyr::filter(!is.na(c14age) & !is.na(c14std)) %>%
  # remove dates outside of theoretical calibration range
  dplyr::filter(!(c14age < 71) & !(c14age > 46401))

dates_calibrated <- dates %>%
  dplyr::mutate(
    # add list column with the age density distribution for every date
    calage_density_distribution = Bchron::BchronCalibrate(
      ages      = dates$c14age,
      ageSds    = dates$c14std,
      calCurves = rep("intcal13", nrow(dates)),
      eps       = 1e-06
    ) %>%
      # transform BchronCalibrate result to a informative tibble
      # this tibble includes the years, the density per year,
      # the normalized density per year and the information,
      # if this year is in the two_sigma range for the current date
      pbapply::pblapply(
        function(x) {
          x$densities %>% cumsum -> a      # cumulated density
          bottom <- x$ageGrid[which(a <= threshold) %>% max]
          top <- x$ageGrid[which(a > 1-threshold) %>% min]
          tibble::tibble(
            age = x$ageGrid,
            dens_dist = x$densities,
            norm_dens = x$densities/max(x$densities),
            two_sigma = x$ageGrid >= bottom & x$ageGrid <= top
          )
      }
    )
  )



#### transform calBP age to calBC ####

dates_calibrated$calage_density_distribution %<>% lapply(
  function(x) {
    x$age = -x$age + bol
    return(x)
  }
)

save(dates_calibrated, file = "analysis/data/tmp_data/dates_calibrated.RData")

# test plot to check the calibration result
# library(ggplot2)
# dates_calibrated$calage_density_distribution[[3]] %>%
#   ggplot() +
#   geom_point(aes(age, norm_dens, color = two_sigma))



#### filter time ####

load("analysis/data/tmp_data/dates_calibrated.RData")

# add artifical date id
dates_calibrated <- dates_calibrated %>%
  dplyr::mutate(
    date_id = 1:nrow(.)
  )

# filter dates to only include dates in time range of interest
dates_time_selection <- dates_calibrated %>%
  dplyr::mutate(
    in_time_of_interest =
      purrr::map(calage_density_distribution, function(x){
        any(
          x$age >= -2200 &
            x$age <= -800 &
            x$two_sigma
        )
      }
    )
  ) %>%
  dplyr::filter(
    in_time_of_interest == TRUE
  ) %>%
  dplyr::select(-in_time_of_interest)

save(dates_time_selection, file = "analysis/data/tmp_data/dates_time_selection.RData")



#### select dates relevant for the research question ####

load("analysis/data/tmp_data/dates_time_selection.RData")

dates_research_selection <- dates_time_selection %>%
  # reduce variable selection to necessary information
  dplyr::select(
    -sourcedb, -c13val, -country, -shortref
  ) %>%
  # filter by relevant sitetypes
  dplyr::filter(
    sitetype %in% c(
      "Grave", "Grave (mound)", "Grave (flat) inhumation",
      "Grave (cremation)", "Grave (inhumation)", "Grave (mound) cremation",
      "Grave (mound) inhumation", "Grave (flat) cremation", "Grave (flat)",
      "cemetery"
    )
  ) %>%
  # transform sitetype field to tidy data about burial_type and burial_construction
  dplyr::mutate(
    burial_type = ifelse(
      grepl("cremation", sitetype), "cremation",
      ifelse(
        grepl("inhumation", sitetype), "inhumation",
        "unknown"
      )
    ),
    burial_construction = ifelse(
      grepl("mound", sitetype), "mound",
      ifelse(
        grepl("flat", sitetype), "flat",
        "unknown"
      )
    )
  ) %>%
  # reduce variable selection to necessary information
  dplyr::select(
    -sitetype
  )

save(dates_research_selection, file = "analysis/data/tmp_data/dates_research_selection.RData")



#### remove dates without coordinates ####

load("analysis/data/tmp_data/dates_research_selection.RData")

dates_coordinates <- dates_research_selection %>% dplyr::filter(
  !is.na(lat) & !is.na(lon)
)

save(dates_coordinates, file = "analysis/data/tmp_data/dates_coordinates.RData")



#### crop date selection to research area ####

load("analysis/data/tmp_data/dates_coordinates.RData")
load("analysis/data/tmp_data/research_area.RData")

# transform data to sf and the correct CRS
dates_sf <- dates_coordinates %>% sf::st_as_sf(coords = c("lon", "lat"))
sf::st_crs(dates_sf) <- 4326
dates_sf %<>% sf::st_transform("+proj=aea +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10 +x_0=0 +y_0=0 +ellps=intl +units=m +no_defs")

# get dates within research area
dates_research_area <- sf::st_intersection(dates_sf, research_area) %>%
  sf::st_set_geometry(NULL) %>%
  dplyr::select(-id)

# add lon and lat columns again
dates_research_area %<>%
  dplyr::left_join(
    dates_coordinates[, c("date_id", "lat", "lon")]
  )

save(dates_research_area, file = "analysis/data/tmp_data/dates_research_area.RData")



#### remove labnr duplicates ####

load("analysis/data/tmp_data/dates_research_area.RData")

# identify dates without correct labnr
ids_incomplete_labnrs <- dates_research_area$date_id[grepl('n/a', dates_research_area$labnr)]

# remove labnr duplicates, except for those with incorrect labnrs
duplicates_removed_dates_research_area_ids <- dates_research_area %>%
  dplyr::filter(
    !(date_id %in% ids_incomplete_labnrs)
  ) %>%
  dplyr::select(-calage_density_distribution) %>%
  c14bazAAR::as.c14_date_list() %>%
  c14bazAAR::remove_duplicates() %$%
  date_id

# merge removed selection with incorrect labnr selection
dates_prepared <- dates_research_area %>%
  dplyr::filter(
    date_id %in% c(duplicates_removed_dates_research_area_ids, ids_incomplete_labnrs)
  )

save(dates_prepared, file = "analysis/data/tmp_data/dates_prepared.RData")



#### merge dates if multiple dates for one grave ####

load("analysis/data/tmp_data/dates_prepared.RData")

# merge information
graves_prepared <- dates_prepared %>%
  dplyr::group_by(site, feature) %>%
  dplyr::do(res = tibble::as_tibble(.)) %$%
  res %>%
  pbapply::pblapply(function(x){

    # check if there are multiple dates for one feature and if there's
    # a number in the feature variable
    if (nrow(x) > 1 & grepl("[0-9]", x$feature[1])) {

      # remove list column and apply data.frame merging function
      res <- x %>%
        dplyr::select(-calage_density_distribution) %>%
        dplyr::group_by(site) %>%
        dplyr::summarise_all(
          .funs = list(~c14bazAAR:::compare_and_combine_data_frame_values(.))
        ) %>%
        dplyr::ungroup()

      # combine density distribution data.frames
      res$calage_density_distribution <- list(x$calage_density_distribution %>% purrr::reduce(
        function(a, b) {
          dplyr::full_join(a, b, by = "age") %>%
            dplyr::transmute(
              age = age,
              dens_dist = purrr::map2_dbl(dens_dist.x, dens_dist.y, function(n, m){sum(n, m, na.rm = T)}),
              norm_dens = dens_dist/max(dens_dist),
              two_sigma = (two_sigma.x | two_sigma.y) %>% ifelse(is.na(.), FALSE, .)
            )
        }
      ))

      return(res)
    } else {
      return(x)
    }

  }) %>%
  do.call(rbind, .) %>%
  # replace missing values (NA) in the major variables
  dplyr::mutate(
    burial_type = tidyr::replace_na(burial_type, "unknown"),
    burial_construction = tidyr::replace_na(burial_construction, "unknown")
  ) %>%
  # remove graves without coordinates
  dplyr::filter(
    !is.na(lat) & !is.na(lon)
  )

save(graves_prepared, file = "analysis/data/tmp_data/graves_prepared.RData")
