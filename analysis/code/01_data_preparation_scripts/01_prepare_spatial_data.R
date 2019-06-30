#### natural earth data ####

# land_outline
# land_outline <- rnaturalearth::ne_download(
#   scale = 50, type = 'land', category = 'physical'
# ) %>% sf::st_as_sf()
# save(land_outline, file = "analysis/data/input_data/natural_earth_geodata/land_outline.RData")
load("analysis/data/input_data/natural_earth_geodata/land_outline.RData")
save(land_outline, file = "analysis/data/tmp_data/land_outline.RData")

# countries
# countries <- rnaturalearth::ne_download(
#   scale = 50, type = 'countries', category = 'cultural'
# ) %>% sf::st_as_sf()
# save(countries, file = "analysis/data/input_data/natural_earth_geodata/countries.RData")
load("analysis/data/input_data/natural_earth_geodata/countries.RData")
save(countries, file = "analysis/data/tmp_data/countries.RData")

# rivers
# rivers <- rnaturalearth::ne_download(
#   scale = 50, type = 'rivers_lake_centerlines', category = 'physical'
# ) %>% sf::st_as_sf()
# save(rivers, file = "analysis/data/input_data/natural_earth_geodata/rivers.RData")
load("analysis/data/input_data/natural_earth_geodata/rivers.RData")
save(rivers, file = "analysis/data/tmp_data/rivers.RData")

# lakes
# lakes <- rnaturalearth::ne_download(
#   scale = 50, type = 'lakes', category = 'physical'
# ) %>% sf::st_as_sf()
# save(lakes, file = "analysis/data/input_data/natural_earth_geodata/lakes.RData")
load("analysis/data/input_data/natural_earth_geodata/lakes.RData")
save(lakes, file = "analysis/data/tmp_data/lakes.RData")



#### research area ####

# load manually crafted research area shape file, transform it to
# EPSG:102013 and store the result
research_area <- sf::st_read(
  "analysis/data/input_data/research_area_shapefile/research_area.shp", quiet = TRUE
) %>%
  sf::st_transform(
  "+proj=aea +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10 +x_0=0 +y_0=0 +ellps=intl +units=m +no_defs"
  )
save(research_area, file = "analysis/data/tmp_data/research_area.RData")



#### area ####

# load natural earth data land outline shape, crop it approximately to
# Europe, transform it to EPSG:102013, crop it to the research area and store the result
land_outline_small <- land_outline %>%
  sf::st_crop(xmin = -20, ymin = 35, xmax = 35, ymax = 65) %>%
  sf::st_transform(
    "+proj=aea +lat_1=43 +lat_2=62 +lat_0=30 +lon_0=10 +x_0=0 +y_0=0 +ellps=intl +units=m +no_defs"
  )
area <- sf::st_intersection(sf::st_buffer(land_outline_small, 0), research_area)
save(area, file = "analysis/data/tmp_data/area.RData")



#### extended area ####

# crop land outline to bbox of research area
extended_research_area <- sf::st_bbox(research_area) %>% sf::st_as_sfc()
extended_area <- sf::st_intersection(sf::st_buffer(land_outline_small, 0), extended_research_area)
save(extended_area, file = "analysis/data/tmp_data/extended_area.RData")
