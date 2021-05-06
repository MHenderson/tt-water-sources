library(ggmap)
library(ragg)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(tidyverse)

source("theme_mjh.R")

if(!file.exists('water.csv')) {
  download.file('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-05-04/water.csv', 'water.csv')
}

water <- readr::read_csv('water.csv')

water <- water %>%
  rename(
    lat = lat_deg,
    lon = lon_deg,
    country = country_name
  ) %>%
  mutate(
    water_source = str_replace(water_source, " \\(River/Stream/Lake/Pond/Dam\\)", "")
  )

ethiopia <- ne_countries(country = "ethiopia", scale = "medium", returnclass = "sf")

ethiopia_bbox <- st_bbox(ethiopia)

ethiopia_water <- water %>%
  filter(country == "Ethiopia") %>%
  filter(lat >= ethiopia_bbox$ymin) %>%
  filter(lat <= ethiopia_bbox$ymax) %>%
  filter(lon >= ethiopia_bbox$xmin) %>%
  filter(lon <= ethiopia_bbox$xmax)


ethiopia_map <- get_stamenmap(bbox = c(
  left   = ethiopia_bbox[["xmin"]],
  right  = ethiopia_bbox[["xmax"]],
  bottom = ethiopia_bbox[["ymin"]],
  top    = ethiopia_bbox[["ymax"]]
), zoom = 7, maptype = "terrain")

ethiopia_water <- ethiopia_water %>%
  filter(!is.na(water_source))

#agg_png(here::here("plots", paste0("plot-", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")), res = 300, height = 8, width = 7.43, units = "in")
agg_png(here::here("water-sources.png"), res = 300, height = 8, width = 7.43, units = "in")

p <- ggmap(ethiopia_map) +
  geom_point(aes(x = lon, y = lat), data = ethiopia_water, size = .2, alpha = .2) +
  facet_wrap(~water_source) +
  labs(
    title = "Water Sources in Ethiopia",
    subtitle = "Source: WPDX | Graphic: Matthew Henderson"
  ) +
  theme_mjh(background_colour = "#060a19", text_colour = "#ebecf4")

print(p)

dev.off()
