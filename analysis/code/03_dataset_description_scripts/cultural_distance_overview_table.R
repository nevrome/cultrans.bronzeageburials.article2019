library(magrittr)

#### burial_construction: sed - spatial distance ####

load("analysis/data/tmp_data/mantel_sed_spatial_burial_construction.RData")
load("analysis/data/tmp_data/squared_euclidian_distance_over_timeblocks_burial_construction.RData")
burial_construction_distance <- sed_spatial_distance %>% dplyr::mutate(context = "burial_construction")
burial_construction_mantel <- mantel_test_results
names(burial_construction_mantel)[2:3] <- c("bc-sp: Correlation coefficient", "bc-sp: p-Value")



#### burial_type: sed - spatial distance ####

load("analysis/data/tmp_data/mantel_sed_spatial_burial_type.RData")
load("analysis/data/tmp_data/squared_euclidian_distance_over_timeblocks_burial_type.RData")
burial_type_distance <- sed_spatial_distance %>% dplyr::mutate(context = "burial_type")
burial_type_mantel <- mantel_test_results
names(burial_type_mantel)[2:3] <- c("bt-sp: Correlation coefficient", "bt-sp: p-Value")



#### burial_construction & burial_type: sed - sed ####

load("analysis/data/tmp_data/mantel_sed_spatial_burial_type_burial_construction.RData")
load("analysis/data/tmp_data/mantel_sed_spatial_burial_type_burial_construction.RData")
burial_type_burial_construction_mantel <- mantel_test_results
names(burial_type_burial_construction_mantel)[2:3] <- c("bt-bc: Correlation coefficient", "bt-bc: p-Value")



#### distance_and_correlation_table ####

distance_and_correlation_table <- rbind(
  burial_type_distance,
  burial_construction_distance
) %>%
  tidyr::spread(context, mean_sed) %>%
  dplyr::select(-regionA, -regionB) %>%
  dplyr::group_by(time) %>%
  dplyr::summarise(
    `bc: Mean distance` = mean(burial_construction, na.rm = TRUE),
    `bt: Mean distance` = mean(burial_type, na.rm = TRUE)
  ) %>%
  dplyr::left_join(
    burial_construction_mantel,
    by = "time"
  )  %>%
  dplyr::left_join(
    burial_type_mantel,
    by = "time"
  ) %>%
  dplyr::select(
    1,3,6,7,2,4,5
  ) %>%
  dplyr::left_join(
    burial_type_burial_construction_mantel,
    by = "time"
  ) %>%
  dplyr::mutate_if(
    is.numeric,
    round,
    3
  )

save(distance_and_correlation_table, file = "analysis/data/output_data/distance_and_correlation_table.RData")
