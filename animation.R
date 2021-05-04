library(magick)
library(tictoc)

tic()
imgs <- image_read(list.files("plots/plot1", full.names = TRUE))

animation <- image_animate(image_scale(imgs, "300x300"), fps = 4, dispose = "previous")

image_write(animation, "plot1.gif")
toc()
