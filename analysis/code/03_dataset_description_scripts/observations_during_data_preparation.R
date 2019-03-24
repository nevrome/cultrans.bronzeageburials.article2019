storage_file <- "analysis/data/output_data/sf_prep.txt"



#### early subsets ####

load("analysis/data/tmp_data/radonb.RData")
txtstorage::store("size radonb", nrow(radonb), storage_file)
rm(radonb)

load("analysis/data/tmp_data/dates_calibrated.RData")
txtstorage::store("size dates_calibrated", nrow(dates_calibrated), storage_file)
rm(dates_calibrated)

load("analysis/data/tmp_data/dates_time_selection.RData")
txtstorage::store("size dates_time_selection", nrow(dates_time_selection), storage_file)
rm(dates_time_selection)

load("analysis/data/tmp_data/dates_research_selection.RData")
txtstorage::store("size dates_research_selection", nrow(dates_research_selection), storage_file)
txtstorage::store("dates_research_selection variable amount", ncol(dates_research_selection), storage_file)
rm(dates_research_selection)

load("analysis/data/tmp_data/dates_coordinates.RData")
txtstorage::store("size dates_coordinates", nrow(dates_coordinates), storage_file)
txtstorage::store("dates_coordinates variable amount", ncol(dates_coordinates), storage_file)
rm(dates_coordinates)



#### dates_research_area ####

load("analysis/data/tmp_data/dates_research_area.RData")

# size
txtstorage::store("size dates_research_area", nrow(dates_research_area), storage_file)

# count indiviual labnrs
labnrs_amount <- dates_research_area$labnr %>% unique() %>% length()
txtstorage::store("dates_research_area labnrs amount", labnrs_amount, storage_file)

# count labnr duplicates without n/a labnrs
labnr_doubles <- dates_research_area[!grepl('n/a', dates_research_area$labnr), ] %>%
  dplyr::group_by(labnr) %>%
  dplyr::filter(dplyr::n() > 1) %>%
  nrow()
txtstorage::store("dates_research_area labnr doubles", labnr_doubles, storage_file)

# count graves represented by multiple c14 dates
multi_dates_one_grave <- dates_research_area %>%
  dplyr::group_by(site, feature) %>%
  dplyr::filter(dplyr::n() > 1) %>%
  nrow()
txtstorage::store("dates_research_area multi dates one grave", multi_dates_one_grave, storage_file)

dates_research_area_burial_type_doubles <- dates_research_area %>%
  dplyr::group_by(site, feature) %>%
  dplyr::filter(dplyr::n() > 1) %>%
  dplyr::ungroup() %$%
  burial_type %>% table %>%
  unclass %>%
  paste(names(.), ., collapse = ", ", sep = ": ")
txtstorage::store("dates_research_area burial_type doubles", dates_research_area_burial_type_doubles, storage_file)

dates_research_area_burial_construction_doubles <- dates_research_area %>%
  dplyr::group_by(site, feature) %>%
  dplyr::filter(dplyr::n() > 1) %>%
  dplyr::ungroup() %$%
  burial_construction %>% table %>%
  unclass %>%
  paste(names(.), ., collapse = ", ", sep = ": ")
txtstorage::store("dates_research_area burial_construction doubles", dates_research_area_burial_construction_doubles, storage_file)

rm(dates_research_area)



#### dates_prepared ####

load("analysis/data/tmp_data/dates_prepared.RData")

# size
txtstorage::store("size dates_prepared", nrow(dates_prepared), storage_file)

# count dates per feature - get max
max_dates_per_grave <- dates_prepared[grepl("[0-9]", dates_prepared$feature), ] %>%
  dplyr::group_by(site, feature) %>%
  dplyr::summarise(n = dplyr::n()) %>%
  dplyr::ungroup() %$%
  max(n)
txtstorage::store("dates_prepared max dates per grave", max_dates_per_grave, storage_file)

multi_dates_one_grave <- dates_prepared %>%
  dplyr::group_by(site, feature) %>%
  dplyr::filter(dplyr::n() > 1)
txtstorage::store("dates_prepared multi dates one grave", nrow(multi_dates_one_grave), storage_file)

with_numbers_in_feature <- multi_dates_one_grave[grepl("[0-9]", multi_dates_one_grave$feature), ]
txtstorage::store("dates_prepared multi dates one grave with numbers", nrow(with_numbers_in_feature), storage_file)

rm(dates_prepared)



#### graves_prepared ####
load("analysis/data/tmp_data/graves_prepared.RData")
txtstorage::store("size graves_prepared", nrow(graves_prepared), storage_file)



#### regions ####
load("analysis/data/tmp_data/regions.RData")
load("analysis/data/tmp_data/region_order.RData")

regions_graves_amounts <- regions %>% sf::st_set_geometry(NULL) %>%
  dplyr::mutate(
    region_name = factor(regions$NAME, levels = region_order)
  ) %>%
  dplyr::arrange(region_name) %$%
  paste(paste0("**", region_name, "**"), paste0("(", number_of_graves, ")"), collapse = ", ", sep = " ")
txtstorage::store("regions graves amounts", regions_graves_amounts, storage_file)
