# Running app
library(leaflet)
library(RColorBrewer)
library(zoo)
library(epitools)
library(ggplot2)

shinyUI(
  navbarPage("Cluster Explorer", id="nav",
                   tabPanel("Interactive map", 
                            div(class="outer",
                                tags$head(                                  
                                  includeCSS(paste0(getwd(),"/www/styles.css"))
                                ),
                                leafletOutput("datamap", width="100%", height="100%"),
                                  
                                absolutePanel(id = "controls2", class = "panel panel-default", fixed = T,
                                              draggable = F, top = 60, left = "auto", right = 20, bottom = "auto",
                                              width = 330, height = "auto", 
                                              checkboxInput("disCase", "Display cases:", value=T),                                                                                                            
                                              checkboxInput("disContext", "Display potential transmission venues:", value=F),
                                              checkboxInput("disGP", "Display geographic profile:", value=F)
                                                  )
                                )),
                   tabPanel("Table",
                            dataTableOutput("res"),
                            tags$head(tags$style(type="text/css", "#res table td{line-height:'10px';}"))                
                   )
  
))