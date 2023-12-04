# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("dplyr", "ggmap", "ragg", "readr", "rnaturalearth", "sf", "stringr", "tibble") # packages that your targets need to run
  # format = "qs", # Optionally set the default storage format. qs is fast.
  #
  # For distributed computing in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller with 2 workers which will run as local R processes:
  #
  #   controller = crew::crew_controller_local(workers = 2)
  #
  # Alternatively, if you want workers to run on a high-performance computing
  # cluster, select a controller from the {crew.cluster} package. The following
  # example is a controller for Sun Grid Engine (SGE).
  #
  #   controller = crew.cluster::crew_controller_sge(
  #     workers = 50,
  #     # Many clusters install R as an environment module, and you can load it
  #     # with the script_lines argument. To select a specific verison of R,
  #     # you may need to include a version string, e.g. "module load R/4.3.0".
  #     # Check with your system administrator if you are unsure.
  #     script_lines = "module load R"
  #   )
  #
  # Set other options as needed.
)

# tar_make_clustermq() is an older (pre-{crew}) way to do distributed computing
# in {targets}, and its configuration for your machine is below.
options(clustermq.scheduler = "multicore")

# tar_make_future() is an older (pre-{crew}) way to do distributed computing
# in {targets}, and its configuration for your machine is below.
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
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
      get_stadiamap(bbox = c(
        left   = ethiopia_bbox[["xmin"]],
        right  = ethiopia_bbox[["xmax"]],
        bottom = ethiopia_bbox[["ymin"]],
        top    = ethiopia_bbox[["ymax"]]
      ), zoom = 7, maptype = "stamen_terrain")
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
