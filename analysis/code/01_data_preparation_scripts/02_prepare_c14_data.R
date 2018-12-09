library(magrittr)

#### set constants ####

# c14 reference zero
bol <- 1950
# 2sigma range probability threshold
threshold <- (1 - 0.9545) / 2



#### data download ####

radonb <- c14bazAAR::get_RADONB()

save(radonb, file = "analysis/data/tmp_data/radonb.RData")



#### calibration ####

load("analysis/data/tmp_data/radonb.RData")

bronze <- radonb %>%
  tibble::as.tibble() %>%
  # remove dates without age
  dplyr::filter(!is.na(c14age) & !is.na(c14std)) %>%
  # remove dates outside of theoretical calibration range
  dplyr::filter(!(c14age < 71) & !(c14age > 46401))

bronze <- bronze %>%
  dplyr::mutate(
    # add list column with the age density distribution for every date
    calage_density_distribution = Bchron::BchronCalibrate(
      ages      = bronze$c14age,
      ageSds    = bronze$c14std,
      calCurves = rep("intcal13", nrow(bronze)),
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

bronze$calage_density_distribution %<>% lapply(
  function(x) {
    x$age = -x$age + bol
    return(x)
  }
)

save(bronze, file = "analysis/data/tmp_data/bronze.RData")

# plot to check the calibration result
# library(ggplot2)
# bronze$calage_density_distribution[[3]] %>%
#   ggplot() +
#   geom_point(aes(age, norm_dens, color = two_sigma))



#### filter time ####

load("analysis/data/tmp_data/bronze.RData")

# add artifical id
bronze <- bronze %>%
  dplyr::mutate(
    id = 1:nrow(.)
  )

# filter dates to only include dates in in time range of interest
bronze0 <- bronze %>%
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

save(bronze0, file = "analysis/data/tmp_data/bronze0.RData")



#### filter research question ####

load("analysis/data/tmp_data/bronze0.RData")

bronze05 <- bronze0 %>%
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

save(bronze05, file = "analysis/data/tmp_data/bronze05.RData")



#### remove dates without coordinates ####

load("data_analysis/bronze05.RData")

bronze1 <- bronze05 %>% dplyr::filter(
  !is.na(lat) & !is.na(lon)
)

save(bronze1, file = "analysis/data/tmp_data/bronze1.RData")



#### crop date selection to research area ####

load("analysis/data/tmp_data/bronze1.RData")
load("analysis/data/tmp_data/research_area.RData")

# transform data to sf and the correct CRS
bronze12 <- bronze1 %>% sf::st_as_sf(coords = c("lon", "lat"))
sf::st_crs(bronze12) <- 4326
bronze12 %<>% sf::st_transform("+proj=aea +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10 +x_0=0 +y_0=0 +ellps=intl +units=m +no_defs")

# get dates within research area
bronze15 <- sf::st_intersection(bronze12, research_area) %>%
  sf::st_set_geometry(NULL) %>%
  dplyr::select(-id.1)

# add lon and lat columns again
bronze15 %<>%
  dplyr::left_join(
    bronze1[, c("id", "lat", "lon")]
  )

save(bronze15, file = "analysis/data/tmp_data/bronze15.RData")



#### remove labnr duplicates ####

load("analysis/data/tmp_data/bronze15.RData")

# identify dates without correct labnr
ids_incomplete_labnrs <- bronze15$id[grepl('n/a', bronze15$labnr)]

# remove labnr duplicates, except for those with incorrect labnrs
duplicates_removed_bronze15_ids <- bronze15 %>%
  dplyr::filter(
    !(id %in% ids_incomplete_labnrs)
  ) %>%
  dplyr::select(-calage_density_distribution) %>%
  c14bazAAR::as.c14_date_list() %>%
  c14bazAAR::remove_duplicates() %$%
  id

# merge removed selection with incorrect labnr selection
bronze16 <- bronze15 %>%
  dplyr::filter(
    id %in% c(duplicates_removed_bronze15_ids, ids_incomplete_labnrs)
  )

save(bronze16, file = "analysis/data/tmp_data/bronze16.RData")



#### merge dates of one grave ####

load("analysis/data/tmp_data/bronze16.RData")

# take a look at the dates per feature
# bronze16 %>%
#   dplyr::group_by(site, feature) %>%
#   dplyr::filter(n()>1)

# merge information
bronze17 <- bronze16 %>%
  dplyr::group_by(site, feature) %>%
  dplyr::do(res = tibble::as_tibble(.)) %$%
  res %>%
  pbapply::pblapply(function(x){

    # check if there are multiple dates for one feature and if there's
    # a Number the feature variable
    if (nrow(x) > 1 & grepl("[0-9]", x$feature[1])) {

      # remove list column and apply data.frame merging function
      res <- x %>%
        dplyr::select(-calage_density_distribution) %>%
        dplyr::group_by(site) %>%
        dplyr::summarise_all(
          .funs = dplyr::funs(c14bazAAR:::compare_and_combine_data_frame_values)
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

save(bronze17, file = "analysis/data/tmp_data/bronze17.RData")

# compare results of group calibration with single date calibration
# library(ggplot2)
# ggplot() +
#   geom_line(data = a, mapping = aes(x = age, y = dens_dist), color = "green") +
#   geom_line(data = b, mapping = aes(x = age, y = dens_dist), color = "blue") +
#   geom_line(data = c, mapping = aes(x = age, y = dens_dist), color = "red")

#### unnest dates ####

load("analysis/data/tmp_data/bronze17.RData")

# unnest calage_density_distribution to have per year information:
# a diachron perspective
bronze2 <- bronze17 %>%
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

save(bronze2, file = "analysis/data/tmp_data/bronze2.RData")
