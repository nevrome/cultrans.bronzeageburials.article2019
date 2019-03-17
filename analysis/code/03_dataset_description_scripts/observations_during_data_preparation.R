storage_file <- "analysis/data/output_data/sf_prep.txt"



#### bronze ####
load("analysis/data/tmp_data/radonb.RData")
txtstorage::store("size radonb", nrow(radonb), storage_file)
rm(radonb)



#### bronze ####
load("analysis/data/tmp_data/bronze.RData")
txtstorage::store("size bronze", nrow(bronze), storage_file)
rm(bronze)



#### bronze0 ####
load("analysis/data/tmp_data/bronze0.RData")
txtstorage::store("size bronze0", nrow(bronze0), storage_file)
rm(bronze0)



#### bronze05 ####
load("analysis/data/tmp_data/bronze05.RData")
txtstorage::store("size bronze05", nrow(bronze05), storage_file)
txtstorage::store("bronze05 variable amount", ncol(bronze05), storage_file)
rm(bronze05)



#### bronze1 ####
load("analysis/data/tmp_data/bronze1.RData")
txtstorage::store("size bronze1", nrow(bronze1), storage_file)
txtstorage::store("bronze1 variable amount", ncol(bronze1), storage_file)
rm(bronze1)



#### bronze15 ####

load("analysis/data/tmp_data/bronze15.RData")

# size
txtstorage::store("size bronze15", nrow(bronze15), storage_file)

# count indiviual labnrs
labnrs_amount <- bronze15$labnr %>% unique() %>% length()
txtstorage::store("bronze15 labnrs amount", labnrs_amount, storage_file)

# count labnr duplicates without n/a labnrs
labnr_doubles <- bronze15[!grepl('n/a', bronze15$labnr), ] %>%
  dplyr::group_by(labnr) %>%
  dplyr::filter(dplyr::n() > 1) %>%
  nrow()
txtstorage::store("bronze15 labnr doubles", labnr_doubles, storage_file)

# count graves represented by multiple c14 dates
multi_dates_one_grave <- bronze15 %>%
  dplyr::group_by(site, feature) %>%
  dplyr::filter(dplyr::n() > 1) %>%
  nrow()
txtstorage::store("bronze15 multi dates one grave", multi_dates_one_grave, storage_file)

bronze15_burial_type_doubles <- bronze15 %>%
  dplyr::group_by(site, feature) %>%
  dplyr::filter(dplyr::n() > 1) %>%
  dplyr::ungroup() %$%
  burial_type %>% table %>%
  unclass %>%
  paste(names(.), ., collapse = ", ", sep = ": ")
txtstorage::store("bronze15 burial_type doubles", bronze15_burial_type_doubles, storage_file)

bronze15_burial_construction_doubles <- bronze15 %>%
  dplyr::group_by(site, feature) %>%
  dplyr::filter(dplyr::n() > 1) %>%
  dplyr::ungroup() %$%
  burial_construction %>% table %>%
  unclass %>%
  paste(names(.), ., collapse = ", ", sep = ": ")
txtstorage::store("bronze15 burial_construction doubles", bronze15_burial_construction_doubles, storage_file)

rm(bronze15)



#### bronze16 ####

load("analysis/data/tmp_data/bronze16.RData")

# size
txtstorage::store("size bronze16", nrow(bronze16), storage_file)

# count the dates per feature - get max
max_dates_per_grave <- bronze16[grepl("[0-9]", bronze16$feature), ] %>%
  dplyr::group_by(site, feature) %>%
  # dplyr::filter(dplyr::n()>1)
  dplyr::summarise(n = dplyr::n()) %>%
  # dplyr::arrange(desc(n)) %>%
  dplyr::ungroup() %$%
  max(n)
txtstorage::store("bronze16 max dates per grave", max_dates_per_grave, storage_file)

multi_dates_one_grave <- bronze16 %>%
  dplyr::group_by(site, feature) %>%
  dplyr::filter(dplyr::n() > 1)
txtstorage::store("bronze16 multi dates one grave", nrow(multi_dates_one_grave), storage_file)

with_numbers_in_feature <- multi_dates_one_grave[grepl("[0-9]", multi_dates_one_grave$feature), ]
txtstorage::store("bronze16 multi dates one grave with numbers", nrow(with_numbers_in_feature), storage_file)

rm(bronze16)



#### bronze17 ####
load("analysis/data/tmp_data/bronze17.RData")
txtstorage::store("size bronze17", nrow(bronze17), storage_file)



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
