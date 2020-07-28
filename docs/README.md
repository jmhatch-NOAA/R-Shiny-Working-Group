Interactive [Leaflet](https://rstudio.github.io/leaflet/) maps of modeled mean monthly density and coefficient of variation for the mean monthly density for North Atlantic Right Whales (_Eubalaena glacialis_) in the month of July ([Roberts _et al_. 2016](https://www.nature.com/articles/srep22615)).

Data downloaded from [here](http://seamap.env.duke.edu/models/Duke-EC-GOM-2015/EC_North_Atlantic_right_whale_maps.html).

R code below:
```r
## load libraries
library(dplyr)
library(raster)
library(leaflet)

## load rasters (downloaded from http://seamap.env.duke.edu/models/Duke-EC-GOM-2015/EC_North_Atlantic_right_whale_maps.html)
narw_july_abundance = here::here('EC_North_Atlantic_right_whale', 'EC_North_Atlantic_right_whale_month07_abundance.img') %>% raster()
narw_july_cv = here::here('EC_North_Atlantic_right_whale', 'EC_North_Atlantic_right_whale_month07_cv.img') %>% raster()

## abundance color palette
abundance_breaks = c(-Inf, 0.01, 0.015, 0.022, 0.032, 0.046, 0.068, 0.10, 0.15, 0.22, 0.32, 0.46, 0.68, 1.0, 1.5, 2.2, 3.2, 4.6, 6.8, 10, Inf)
abundance_colors = c('#c2523c', '#cc5e33', '#d67129', '#e3871e', '#eda413', '#f2b90f', '#f7d40a', '#faea05', '#e1fa00', '#9cf000', '#59e800', '#1ade00', '#08d123', '#11bf51', '#1aad75', '#1f9c89', '#1c8a91', '#166b8a', '#114b82', '#0b2c7a')
abundance_pal = colorBin(palette = abundance_colors, reverse = TRUE, domain = values(narw_july_abundance), bins = abundance_breaks, na.color = 'transparent')
  
## cv color palette
cv_breaks = c(-Inf, seq(0, 1, 0.1), Inf)
cv_colors = c('#ff0000', '#ff6200', '#ff9d00', '#ffd900', '#f4ff2b', '#cdff70','#99ffad', '#4affea', '#2ed2ff', '#3b90ff', '#3355ff', '#002673')
cv_pal = colorBin(palette = cv_colors, reverse = TRUE, domain = values(narw_july_cv), bins = cv_breaks, na.color = 'transparent')

## Leaflet
leaflet() %>% 
  setView(lng = -73.50671, lat = 35.82039, zoom = 5) %>%
  addProviderTiles(providers$Esri.OceanBasemap) %>% 
  addRasterImage(narw_july_abundance, colors = abundance_pal, opacity = 1.0,  group = 'abundance') %>%
  addLegend('bottomleft', pal = abundance_pal, values = values(narw_july_abundance), title = 'animals / 100 km2', group = 'abundance') %>%
  addRasterImage(narw_july_cv, colors = cv_pal, opacity = 1.0,  group = 'cv') %>%
  addLegend('bottomleft', pal = cv_pal, values = values(narw_july_cv), title = 'coefficient of variation', group = 'cv') %>%
  addLayersControl(overlayGroups = c('abundance', 'cv'), options = layersControlOptions(collapsed = TRUE)) %>%
  hideGroup('cv')
```
