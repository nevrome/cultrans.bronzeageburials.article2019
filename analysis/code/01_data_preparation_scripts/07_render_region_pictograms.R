#### load data ####

load("analysis/data/tmp_data/regions.RData")
load("analysis/data/tmp_data/extended_area.RData")
extended_area <- extended_area$geometry
load("analysis/data/tmp_data/region_order.RData")
load("analysis/data/tmp_data/region_colors.RData")



#### plot loop ####

path = "analysis/data/tmp_data/"

for (i in 1:nrow(regions)) {

  one_region <- regions[regions$NAME == region_order[i], ]
  one_region_buffer <- one_region %>%
    sf::st_buffer(400000)

  one_region_geom <- one_region$geometry
  one_region_buffer_geom <- one_region_buffer$geometry

  one_region_name <- one_region$NAME %>% gsub(" ", "_", ., fixed = TRUE)

  png(
    filename = paste0(path, one_region_name, ".png"),
    width = 87*4, height = 100*4, units = "px", res = 300
  )
  par(mar = c(0,0,0,0),
      pin = c(4,2),
      pty = "m",
      xaxs = "i",
      xaxt = 'n',
      xpd = FALSE,
      yaxs = "i",
      yaxt = 'n',
      bg = NA)
  plot(extended_area, border = NA , col = "grey85", lwd = 2)
  plot(one_region_buffer_geom, border = NA, col = scales::alpha(region_colors[i], 0.4), add = TRUE)
  plot(one_region_geom, border = NA, col = region_colors[i], add = TRUE)
  dev.off()

}
