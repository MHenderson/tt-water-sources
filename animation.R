library(magick)
library(tictoc)

tic()
imgs <- image_read(list.files("plots/plot6", full.names = TRUE))

animation <- image_animate(image_scale(imgs, "300x300"), fps = 4, dispose = "previous")

image_write(animation, "plot6.gif")
toc()
