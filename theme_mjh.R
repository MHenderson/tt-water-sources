theme_mjh <- function(..., base_size = 12, font1 = "Cardo", background_colour = "#eff2f7", text_colour = "#10192d") {

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
    panel.grid.minor  = element_blank(),
    ...
  )

}

