rm(list=ls())

#------------------
# Load packages
#------------------
library(rgdal)
library(Rgeoprofile)
library(shiny)
library(RColorBrewer)

#------------------
# Load data
#------------------

setwd("I:\\FES Victoria\\1. FES-Disease & Lead Areas\\TB\\5. Projects & Audits\\R&D\\2012-11 Gegraphical profiling\\Clusters\\")

# load london cluster and spatial data
#load("I:\\FES Victoria\\1. FES-Disease & Lead Areas\\TB\\5. Projects & Audits\\R&D\\2012-11 Gegraphical profiling\\Clusters\\R\\Lon1013.RData")

# save as clusterGP
save.image("R\\ClusterGP.RData")

# load
load("R\\ClusterGP.RData")

#------------------
# Venues and cases
#------------------

# venues
ven<-read.csv("GP\\VenuesGC.csv")


# reproject venues to ll

##strings for projections
bng<-"+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +datum=OSGB36 +units=m +no_defs +ellps=airy +towgs84=446.448,-125.157,542.060,0.1502,0.2470,0.8421,-20.4894"
wgs84 <- '+proj=longlat +datum=WGS84'
mrc <- '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs'

## make points spatial objects
v<-ven[which(!is.na(ven$EASTOSGB)),]
rownames(v)<-NULL
coordinates(v)<-c("EASTOSGB","NORTHOSGB")
v@proj4string<-CRS(bng)

## transform
v<-spTransform(v,CRS(wgs84))

# add coords to data
v.f<-cbind(v@coords,v@data)

# add hitscores var
v.f$Hitscores<-NA

# select only cases in clusters of interest
head(ven)
unique(ven$CLUSTER)
names(d.ll)

table(d@data$clusterno1_analysis_rc[which(d@data$clusterno1_analysis_rc%in%unique(ven$CLUSTER))])

# Import E1518 data 
## - this isn't in the matched dataset for some reason
## they are in as E1587
d@data[which(d@data$clusterno1_analysis_rc=="E1587"),"id"]

# subset - only those in clusters of interest
## use lat long projection
e<-d.ll[which(d.ll@data$clusterno1_analysis_rc%in%
                                            c(as.character(unique(ven$CLUSTER)),"E1587")),]

table(e@data$clusterno1_analysis_rc)

## create clusterid variable, rename  E1587 to E1518
e@data$clusterid<-e@data$clusterno1_analysis_rc
e@data$clusterid[e@data$clusterid=="E1587"]<-"E1518"
table(e@data$clusterid)

## join coords to data
e.f<-cbind(e@coords,e@data)

# rename var
names(v.f)[which(names(v.f)=="CLUSTER")]<-"clusterid"

#------------------
# Check data plots look ok
#------------------
Lon.ll<-spTransform(Lon,CRS(wgs84))

plot(Lon.ll)
plot(v, add=T)
plot(e, add=T, col="red")

#------------------
# Run Rgeoprofile
#------------------
# choose cluster
cluster<-unique(e$clusterid)[5]

detach(package:raster)
LoadData(e.f[which(e.f$clusterid==cluster),c("EASTOSGB","NORTHOSGB")], 
         v.f[which(v.f$clusterid==cluster),c("EASTOSGB","NORTHOSGB")])
ModelParameters(sigma_expectation=0.01,Delta=1,Samples=10000)
GraphicParameters(Location=getwd(),Guardrail = 0.05,pointcol="red")
CreateMaps()
RunMCMC()
ThinandAnalyse(thinning=50)

#------------------
# Save results
#------------------
# save bbox
box<-list(xmin=xmin, xmax=xmax,ymin=ymin, ymax=ymax)
assign(paste0("box",cluster), box)

# save hitscores
v.f$Hitscore[which(v.f$clusterid==cluster)]<-reporthitscores()$hitscores

# save raster image
#library(raster)
#plotWindow = list(c(xmin, xmax), c(ymin, ymax))
#levels = seq(0, 1, length.out = nring + 1)
#jpeg(paste0(getwd(),"//Leaflet//GPApp//www//geoprofile",cluster,".jpeg"))
#par(mar = c(0,0,0,0))
#image(raster(1-hitscoremat), col=heat.colors(length(levels)-1), breaks=levels)
#contour(raster(1-hitscoremat), add = TRUE, drawlabels = FALSE, levels=levels)
#dev.off()

# save raster
library(raster)
gp<-raster(1-hitscoremat)
extent(gp)<-c(xmin, xmax, ymin, ymax)
crs(gp)<-CRS(wgs84)
gp<-leaflet::projectRasterForLeaflet(gp)
assign(paste0("gp",cluster),gp)

# save rasters in list
gpList<-list(E1014=gpE1014, E1518=gpE1518, E1142=gpE1142, E1158=gpE1158, C1467=gpC1467)


#------------------
# combine venues and cases for shiny
#------------------

names(e.f)
names(v.f)
names(v.f)[which(names(v.f)=="NAME")]<-"id"
v.f$caserepdate<-NA
e.f$CATEGORY<-"case"
e.f$Hitscore<-NA
e.f<-e.f[,c("EASTOSGB", "NORTHOSGB", "id", "CATEGORY", "caserepdate", "clusterid", "Hitscore")]
v.f<-v.f[,c("EASTOSGB", "NORTHOSGB", "id", "CATEGORY", "caserepdate", "clusterid", "Hitscore")]
str(e.f)
str(v.f)
v.f$clusterid<-as.character(v.f$clusterid)
v.f$CATEGORY<-as.character(v.f$CATEGORY)
d.f<-rbind(e.f, v.f)

cols<-c("black",brewer.pal(length(unique(v.f$CATEGORY)), "Set1"))
d.f<-merge(d.f, data.frame(col=cols, CATEGORY=c("case",unique(v.f$CATEGORY))), by="CATEGORY", all.x=T)
d.f[which(is.na(d.f$Hitscore)),]

#------------------
# Run app
#------------------
runApp("Leaflet\\GPApp", launch.browser=T)

