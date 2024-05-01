library(ggplot2)
library(ggthemes)
library(ggmap)
library(scales)
library(grid)
library(dplyr)
library(gridExtra)
library(mapproj)

#Load in data
dat.cocc <- read.csv("Cocci positive animals GPS.csv", header = T)

#ggmap
states <- map_data("state")
counties <- map_data("county")
counties_merged <- read.csv("counties.csv", header=T)

p <-ggplot(data = counties_merged) + 
  geom_polygon(aes(x = long, y = lat, group = group, fill = log10(n)), color = "black", size=0.2) + #county polygons colored by log(sample size)
  geom_polygon(data= states,aes( x = long, y = lat, group = group), fill = "transparent", color = "black", size=1) + #state polygons to highlight political borders
  geom_point(data = dat.cocc, aes(x= long, y=lat, size=n), shape =21, color = "black", fill= "orange") + #controls cocci + sampling points
  scale_fill_gradient2(low = "black", mid="steelblue1", high= "navy", na.value="white") + #controls gardeint for county sampling
  coord_map(xlim = c(-123, -105),ylim = c(31.5, 40))+ #controls plot boundries without messing up polygons
  theme(axis.text=element_text(size=14), #controls axis text size
        axis.title=element_text(size=18))+
  theme_classic()+
  #guides(fill=FALSE)+  # do this to leave off the color legend
  labs(x="Longitude", y= "Latitude") #axis labels
p

ggsave(
  filename = "mammal_cocci_sampling.pdf",
  plot = p,
  width = 8,
  height = 6,
  unit = "in",
  bg = "transparent",
  device = "pdf"
)
