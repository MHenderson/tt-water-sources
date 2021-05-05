library(ggmap)
library(ragg)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(tidyverse)

water <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-05-04/water.csv')

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


background_colour <- "#060a19"
text_colour <- "#ebecf4"

font1 <- "Cardo"

#agg_png(here::here("plots", paste0("plot-", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")), res = 300, height = 8, width = 7.43, units = "in")
agg_png(here::here("water-sources.png"), res = 300, height = 8, width = 7.43, units = "in")

p <- ggmap(ethiopia_map) +
  geom_point(aes(x = lon, y = lat), data = ethiopia_water, size = .2, alpha = .2) +
  facet_wrap(~water_source) +
  labs(
    title = "Water Sources in Ethiopia",
    subtitle = "Source: WPDX | Graphic: Matthew Henderson"
  ) +
  theme_void() +
  theme(
    plot.margin = margin(20, 10, 20, 10),
    panel.background  = element_rect(fill = background_colour, colour = NA),
    plot.background   = element_rect(fill = background_colour, colour = NA),
    legend.background = element_rect(fill = background_colour),
    strip.background  = element_rect(fill = background_colour),
    plot.title        = element_text(colour = text_colour, size = 26, hjust = 1, family = font1, margin = margin(5, 0, 20, 0)),
    plot.subtitle     = element_text(colour = text_colour, size = 10, hjust = 1, family = font1, margin = margin(5, 0, 10, 0)),
    plot.caption      = element_text(colour = text_colour, size = 10, hjust = 0.5, family = font1),
    legend.title      = element_text(colour = text_colour, size = 10, hjust = 0.5, family = font1),
    strip.text        = element_text(colour = text_colour, size = 10, hjust = 0, family = font1, margin = margin(5, 0, 5, 0)),
    legend.position   = "none",
    axis.title.x      = element_blank(),
    axis.title.y      = element_blank(),
    axis.text.x       = element_blank(),
    axis.text.y       = element_blank(),
    axis.ticks.x      = element_blank(),
    axis.ticks.y      = element_blank(),
    panel.grid.major  = element_blank(),
    panel.grid.minor  = element_blank()
  )

print(p)

dev.off()
