library(targets)

tar_option_set(
  packages = c("dplyr", "ggmap", "readr", "rnaturalearth", "sf", "stringr", "tibble")
)

tar_source()

list(
  tar_target(
       name = water,
    command = read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-05-04/water.csv')
  ),
  tar_target(
       name = water_pp,
    command = {
      water |>
	rename(
	      lat = lat_deg,
	      lon = lon_deg,
	  country = country_name
	) |>
	mutate(
	  water_source = str_replace(water_source, " \\(River/Stream/Lake/Pond/Dam\\)", "")
	)
    }
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

      background_colour <- "#060a19"
            text_colour <- "#ebecf4"
              base_size <- 12
                  font1 <- "Cardo"

      ggmap(ethiopia_map) +
        geom_point(aes(x = lon, y = lat), data = ethiopia_water, size = .2, alpha = .2) +
        facet_wrap(~water_source) +
        labs(
             title = "Water Sources in Ethiopia",
          subtitle = "Source: WPDX | Graphic: Matthew Henderson"
        ) +
	theme(
	  plot.margin       = margin(20, 10, 20, 10),
	  panel.background  = element_rect(fill = background_colour, colour = NA),
	  plot.background   = element_rect(fill = background_colour, colour = NA),
	  legend.background = element_rect(fill = background_colour),
	  strip.background  = element_rect(fill = background_colour),
	  plot.title        = element_text(colour = text_colour, size = 26, hjust = 1, family = font1, margin = margin(5, 0, 20, 0)),
	  plot.subtitle     = element_text(colour = text_colour, size = base_size, hjust = 1, family = font1, margin = margin(5, 0, 10, 0)),
	  plot.caption      = element_text(colour = text_colour, size = base_size, hjust = 0.5, family = font1),
	  legend.title      = element_text(colour = text_colour, size = base_size, hjust = 0.5, family = font1),
	  strip.text        = element_text(colour = text_colour, size = base_size, hjust = 0.5, family = font1, margin = margin(5, 0, 5, 0)),
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

    }
  ),
  tar_target(
       name = save_map,
    command = {
      ggsave(
            plot = ethiopia_water_sources_map,
	filename = "plot/water-sources.png",
	   width = 4000,
	  height = 3000,
	   units = "px"
      )
    }
  )
)
