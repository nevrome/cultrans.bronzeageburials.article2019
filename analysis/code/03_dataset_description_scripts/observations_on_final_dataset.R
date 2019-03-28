storage_file <- "analysis/data/output_data/sf_desc.txt"



#### total number of graves ####

load("analysis/data/tmp_data/graves_per_region.RData")
gpr <- graves_per_region

txtstorage::store("gpr size", nrow(gpr), storage_file)



#### number of graves per regions ####

load("analysis/data/tmp_data/graves_per_region.RData")

regions_graves_amounts <- graves_per_region %>%
  dplyr::group_by(
    region
  ) %>%
  dplyr::summarise(
    n = dplyr::n()
  ) %$%
  paste(paste0("**", region, "**"), paste0("(", n, ")"), collapse = ", ", sep = " ")

txtstorage::store("regions graves amounts", regions_graves_amounts, storage_file)

gprcrosstab_top <- gpr %>%
  dplyr::group_by(
    region, burial_type, burial_construction
  ) %>%
  dplyr::summarise(
    n = dplyr::n()
  ) %>%
  dplyr::ungroup() %>%
  tidyr::spread(
    key = burial_construction, value = n, fill = 0
  )

gprcrosstab_sum <- gpr %>%
  dplyr::group_by(
    burial_type, burial_construction
  ) %>%
  dplyr::summarise(
    n = dplyr::n()
  ) %>%
  dplyr::ungroup() %>%
  tidyr::spread(
    key = burial_construction, value = n, fill = 0
  ) %>%
  dplyr::mutate(
    region = "Total"
  )

gprcrosstab <- rbind(gprcrosstab_top, gprcrosstab_sum)

save(
  gprcrosstab,
  file = "analysis/data/output_data/gprcrosstab.RData"
)



#### dates analysis ####

load("analysis/data/tmp_data/dates_per_region.RData")
dpr <- dates_per_region

txtstorage::store("dpr size", nrow(dpr), storage_file)

txtstorage::store(
  c(
    "dpr sites amount",
    "dpr period amount",
    "dpr culture amount"
  ),
  c(
    dpr$site %>% unique %>% length(),
    dpr$period %>% unique %>% length(),
    dpr$culture %>% unique %>% length()
  ),
  storage_file
)

material <- dpr$material %>% table(useNA = "always") %>% as.data.frame()

txtstorage::store(
  c(
    "dpr material bone amount",
    "dpr material cremated bones amount",
    "dpr material charcoal wood amount",
    "dpr material other amount",
    "dpr material unknown amount"
  ),
  c(
    material$Freq[material$. %in% c("collagen, bone", "cremated bones", "dentin")] %>% sum,
    material$Freq[material$. %in% c("cremated bones")],
    material$Freq[material$. %in% c("bark", "charcoal", "wood")] %>% sum,
    material$Freq[!material$. %in% c("collagen, bone", "cremated bones", "dentin", "bark", "charcoal", "wood") & !is.na(material$.)] %>% sum,
    material$Freq[is.na(material$.)]
  ),
  storage_file
)

dpr$species %>% table(useNA = "always")
