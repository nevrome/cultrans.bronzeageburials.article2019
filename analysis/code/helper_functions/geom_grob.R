library(ggplot2)
library(tibble)
library(gridExtra)
library(grid)

GeomCustom <- ggproto(
  "GeomCustom",
  Geom,
  setup_data = function(self, data, params) {
    data <- ggproto_parent(Geom, self)$setup_data(data, params)
    data
  },
  
  draw_group = function(data, panel_scales, coord) {
    vp <- grid::viewport(x=data$x, y=data$y)
    g <- grid::editGrob(data$grob[[1]], vp=vp)
    ggplot2:::ggname("geom_custom", g)
  },
  
  required_aes = c("grob","x","y")
  
)

geom_custom <-  function(mapping = NULL,
                         data = NULL,
                         stat = "identity",
                         position = "identity",
                         na.rm = FALSE,
                         show.legend = NA,
                         inherit.aes = FALSE,
                         ...) {
  layer(
    geom = GeomCustom,
    mapping = mapping,
    data = data,
    stat = stat,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}

# d <- tibble(x=1, f=rep(letters[1:11]))
# gl <- lapply(1:4, function(c) rectGrob(gp=gpar(fill=c), width=0.2, height=0.2))
# dummy <- tibble(f=letters[1:4], grob = gl )
# 
# ggplot(d, aes(x,x)) +
#   facet_wrap(~f) +
#   geom_custom(data=dummy, aes(grob=grob), inherit.aes = FALSE,
#               x = 0.5, y=0.5)
