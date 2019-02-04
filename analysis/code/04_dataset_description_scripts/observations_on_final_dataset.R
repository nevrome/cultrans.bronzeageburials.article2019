storage_file <- "analysis/data/output_data/sf_desc.txt"

#### graves_per_region ####

load("analysis/data/tmp_data/graves_per_region.RData")
gpr <- graves_per_region

txtstorage::store("gpr size", nrow(gpr), storage_file)

#### dates_per_region ####

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

dprcrosstab <- table(dpr$burial_type, dpr$burial_construction)
save(
  dprcrosstab,
  file = "analysis/data/output_data/dprcrosstab.RData"
)
