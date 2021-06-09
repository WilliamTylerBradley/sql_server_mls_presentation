# library(ggplot2)
# 
# ggplot() +
#   xlim(c(0, 100)) +
#   ylim(c(0, 100)) +
#   geom_rect(aes(xmin = 20 / 2,
#             ymin = 20 / 2,
#             xmax = 100 - 20 / 2,
#             ymax = 100 - 20 / 2),
#             color = '#F4A201',
#             fill = '#F4A201') +
#   geom_rect(aes(xmin = 22.5 / 2,
#                 ymin = 22.5 / 2,
#                 xmax = 100 - 22.5 / 2,
#                 ymax = 100 - 22.5 / 2),
#             color = 'white',
#             fill = 'white') +
#   geom_rect(aes(xmin = 25 / 2,
#                 ymin = 25 / 2,
#                 xmax = 100 - 25 / 2,
#                 ymax = 100 - 25 / 2),
#             color = '#F4A201',
#             fill = '#F4A201') +
#   theme_void()
# ggsave("background.png",
#        width = 1,
#        height = 1,
#        type = "cairo")

library(data.table)

# Title Slide
df <- CJ(x = seq(1, 100),
         y = seq(1, 100))
df[, color := ifelse(x >= 5 & x <= 95 &
                       y >= 5 & y <= 95,
                     '#F4A201', '#FFFFFF')]
df[, color := ifelse(x >= 7.5 & x <= 92.5 &
                       y >= 7.5 & y <= 92.5,
                     '#FFFFFF', color)]
df[, color := ifelse(x >= 10 & x <= 90 &
                       y >= 10 & y <= 90,
                     '#F4A201', color)]

df <- as.matrix(dcast(df, y ~ x, value.var = "color")[, y := NULL])

png("title_background.png", width=500, height=500)
par(mar=c(0,0,0,0), xpd=NA, mgp=c(0,0,0), oma=c(0,0,0,0), ann=F)
plot.new()
plot.window(0:1, 0:1)
usr<-par("usr")    
rasterImage(df, usr[1], usr[3], usr[2], usr[4], interpolate = FALSE)
dev.off()

# Normal Slide
df <- CJ(x = seq(1, 960),
         y = seq(1, 700))
df[, color := ifelse(y >= 700 * .96,
                     '#F4A201', '#FFFFFF')]

df <- as.matrix(dcast(df, y ~ x, value.var = "color")[, y := NULL])

png("normal_background.png", width=960, height=700)
par(mar=c(0,0,0,0), xpd=NA, mgp=c(0,0,0), oma=c(0,0,0,0), ann=F)
plot.new()
plot.window(0:1, 0:1)
usr<-par("usr")    
rasterImage(df, usr[1], usr[3], usr[2], usr[4], interpolate = FALSE)
dev.off()

