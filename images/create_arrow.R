library(ggplot2)

ggplot() +
  xlim(c(0, 1)) +
  ylim(c(0, 1)) +
  geom_segment(aes(x = .1, y = .1,
               xend = .9, yend = .9),
               arrow = arrow(length = unit(0.5, "npc")),
               size = 5,
               lineend = "round", linejoin = "round",
               color = "#F4A201") +
  theme_void() +
  coord_equal()
ggsave("images/arrow.png",
       width = 1,
       height = 1,
       bg = "transparent")
