library(targets)

tar_option_set(
  packages = c("dplyr", "ggmap", "ragg", "readr", "rnaturalearth", "sf", "stringr", "tibble")
)

tar_source()

list(
  tar_target(
       name = water,
    command = read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-05-04/water.csv')
  ),
  tar_target(
       name = water_pp,
    command = pp_water(water)
  ),
  tar_target(
       name = ethiopia_sf,
    command = ne_countries(country = "ethiopia", scale = "medium", returnclass = "sf")
  ),
  tar_target(
       name = ethiopia_bbox,
    command = st_bbox(ethiopia_sf)
  ),
  tar_target(
       name = ethiopia_water,
    command = { water_pp |>
      filter(country == "Ethiopia") |>
      filter(lat >= ethiopia_bbox$ymin) |>
      filter(lat <= ethiopia_bbox$ymax) |>
      filter(lon >= ethiopia_bbox$xmin) |>
      filter(lon <= ethiopia_bbox$xmax) |>
      filter(!is.na(water_source))
    }
  ),
  tar_target(
       name = ethiopia_map,
    command = {
      get_stadiamap(
           zoom = 7,
	maptype = "stamen_terrain",
           bbox = c(
             left   = ethiopia_bbox[["xmin"]],
             right  = ethiopia_bbox[["xmax"]],
             bottom = ethiopia_bbox[["ymin"]],
             top    = ethiopia_bbox[["ymax"]]
           )
      )
    }
  ),
  tar_target(
       name = ethiopia_water_sources_map,
    command = {
      ggmap(ethiopia_map) +
        geom_point(aes(x = lon, y = lat), data = ethiopia_water, size = .2, alpha = .2) +
        facet_wrap(~water_source) +
        labs(
             title = "Water Sources in Ethiopia",
          subtitle = "Source: WPDX | Graphic: Matthew Henderson"
        ) +
        theme_mjh(background_colour = "#060a19", text_colour = "#ebecf4")
    }
  ),
  tar_target(
       name = save_map,
    command = {
      agg_png("img/water-sources.png", res = 300, height = 8, width = 7.43, units = "in")
      print(ethiopia_water_sources_map)
      dev.off()
    }
  )
)
