rm(list=ls())

#------------------------------------------
# Format data and run Rgeoprofile
#------------------------------------------

#------------------
# Set working directory
#------------------
setwd(choose.dir())

#------------------
# Load packages
#------------------

# Plotting data
library(scales)

# Formatting data
## geocoding points
library(ggmap)

# Running geoprofile
library(Rgeoprofile)

## Running shiny
library(shiny)
## sometimes need to be updated for shiny to run
#install.packages("httpuv")
#install.packages("Rcpp")

# Generating interactive maps
library(leaflet)


#------------------
# Import data
#------------------
cases<-read.csv("Example data//cases.csv", stringsAsFactors=T)
venues<-read.csv("Example data//venues.csv", stringsAsFactors=T)

#------------------
# Geocode data if needed
#------------------

# cases
if(!("lat" %in% names(cases))){
  cases$loc<-as.character(cases$loc)
  cases<-cbind(cases, geocode(cases[,"loc"]))
}

## remove points with no location data
cases<-cases[complete.cases(cases[,c("lat","lon")]),]

# venues
if(exists("venues")){
  if(!("lat" %in% names(venues))){
    venues$loc<-as.character(venues$loc)
    venues<-cbind(venues, geocode(venues[,"loc"]))
  }
  venues<-venues[complete.cases(venues[,c("lat","lon")]),]  
}

#------------------
# Run geoprofile
#------------------

detach(package:raster)
if(exists("venues")){
  LoadData(cases[,c("lon", "lat")],
           venues[,c("lon", "lat")])
} else {
  LoadData(cases[,c("lon", "lat")])
}

ModelParameters(sigma_expectation=0.01,Delta=1,Samples=10000)
GraphicParameters(Location=getwd(),Guardrail = 0.05,pointcol="red")
CreateMaps()
RunMCMC()
ThinandAnalyse(thinning=50)

#------------------
# Save results
#------------------
if(exists("venues")){
  venues$hitscore<-reporthitscores()$hitscores
}

library(raster)
gp<-raster(1-hitscoremat)
extent(gp)<-c(xmin, xmax, ymin, ymax)
wgs84 <- '+proj=longlat +datum=WGS84'
crs(gp)<-CRS(wgs84)
gp<-leaflet::projectRasterForLeaflet(gp)

#------------------
# Run Shiny app
#------------------
runApp("App", launch.browser=T)
