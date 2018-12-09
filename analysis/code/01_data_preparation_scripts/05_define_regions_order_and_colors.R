region_order <- c(
  "Southeastern Central Europe",
  "Poland",
  "Southern Germany",
  "Northeastern France",
  "Northern Germany",
  "Southern Scandinavia",
  "Benelux",
  "England"
)

save(region_order, file = "analysis/data/tmp_data/region_order.RData")

region_colors <- c(
  "Southeastern Central Europe" = "#999999",
  "Poland" = "#ffe500",
  "Southern Germany" = "#56B4E9",
  "Northeastern France" = "#009E73",
  "Northern Germany" = "#000000",
  "Southern Scandinavia" = "#0072B2",
  "Benelux" = "#D55E00",
  "England" = "#CC79A7"
)

save(region_colors, file = "analysis/data/tmp_data/region_colors.RData")
