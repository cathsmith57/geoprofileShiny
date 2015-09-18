# geoprofileShiny User Guide

## Install packages
Make sure that the following packages are installed using install.packages("package_name")

Running app and generating interactive maps:
- shiny
- leaflet

Running Rgeoprofile:
- Rgeoprofile - available [here](https://evolve.sbcs.qmul.ac.uk/lecomber/sample-page/geographic-profiling/geographic-profiling-in-r/)

Plotting data:
- scales

Geocoding points:
- ggmap

## Data requirements

Rgeoprofile uses two data files, examples of which are provided in the [Example data folder](https://github.com/cathsmith57/geoprofileShiny/tree/master/Example%20data)

### cases
Locations of cases, or crime sites, using one row per individual. Requires the following information:
- *id* - a unique identifier for each case.
- *lon* and *lat* - the longitude and latitude of case locations.
- Alternatively, *loc* is a character string specifying a location, such as postcode (uses geocode function from ggmap package to generate lon and lat columns).

### venues (optional)
Locations of potential transmission venues, or suspect sites. Requires the following information:
- *id* - a unique identifier of each location. These must be different to the IDs used for cases.
- *name* - the name of the location.
- *type* - the type of location.
- *lon* and *lat* - the longitude and latitude of locations.
- Alternatively, *loc* is a character string specifying a location, such as postcode (uses geocode function from ggmap package to generate lon and lat columns).


**NB: id, lon, lat, name and type columns must be named as stated in *italics* above.**

## Running App

1. Create a new folder to act as your working directory.
2. Download the [FormatGP.R](https://github.com/cathsmith57/geoprofileShiny/tree/master/FormatGP.R) script, the [App](https://github.com/cathsmith57/geoprofileShiny/tree/master/App) folder, and the [ExampleData](https://github.com/cathsmith57/geoprofileShiny/tree/master/Example%20data) folder and save in your working directory.
3. Open FormatGP.R and run the script. It will prompt you to select your working directory and then run the shiny app.
	- If you wish to use different data sets, change the file paths in the *Import data* section as required.
