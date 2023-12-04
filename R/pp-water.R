pp_water <- function(X) {
  X |>
    rename(
          lat = lat_deg,
          lon = lon_deg,
      country = country_name
    ) |>
    mutate(
      water_source = str_replace(water_source, " \\(River/Stream/Lake/Pond/Dam\\)", "")
    )
}
