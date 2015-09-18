# server.R


shinyServer(function(input, output, session) {
  values<-reactiveValues(starting=TRUE)
  session$onFlushed(function(){
    values$starting<-FALSE
  })
  

  output$res<-renderDataTable({
    if(exists("venues")){
      venues
    } else {
      data.frame("Venues" = "No venues provided")
    }
          
  }, options= list(
    paging=F, searching=F,
    drawCallback=I("function(settings){document.getElementById('res').style.width='800px';}"))
  )
  

  
  output$datamap <- renderLeaflet({ 
    leaflet() %>% 
      addTiles() %>%
#      addProviderTiles("OpenStreetMap.BlackAndWhite") %>%
      setView(lat=median(cases$lat),lng=median(cases$lon), zoom=10, options=list(maxZoom=11))      
  })
  
  observe({
    datamap<-leafletProxy("datamap", data=cases)
    datamap %>% clearMarkers()
    if(exists("venues")){
      datamap %>% addMarkers(data=venues, lat=~lat, lng=~lon, layerId=~id, group="venues")    
    }
    datamap %>% addCircleMarkers(lng=~lon, lat=~lat, 
                                 fillColor=~"black", color="black", weight=1,radius=6, fillOpacity=1,
                                 layerId=~id, group="cases")
    datamap %>% clearGroup("geoprofile")
    datamap %>% addRasterImage(gp, opacity=0.3, project=F, group="geoprofile", colors=heat.colors(20))    
    
    if(input$disGP==T){
      datamap %>% showGroup("geoprofile")
    } else if(input$disGP==F){
      datamap %>% clearGroup("geoprofile")
    }
    
    if(input$disCase==T){
      datamap %>% showGroup("cases")
      
    } else if(input$disCase==F){
      datamap %>% hideGroup("cases")
    }
    
    if(input$disContext==T){
      datamap %>% showGroup("venues")
      
    } else if(input$disContext==F){
      datamap %>% hideGroup("venues")
    }

      
  })


popContent<-function(ID){

    if(ID%in%cases$id){
      selectedID <- cases[cases$id == ID,]
      content<-as.character(
        tagList(
          tags$strong("ID"), selectedID$id, tags$br()
          )
        )
      

  } else {
    selectedID <- venues[venues$id==ID,]
    content <- as.character(tagList(
      tags$strong("ID"), selectedID$id, tags$br(),
      tags$strong("Name"), selectedID$name, tags$br(),
      tags$strong("Type"), selectedID$type, tags$br(),
      tags$strong("Hitscore"), round(selectedID$hitscore, 3), tags$br()
    ))
  }
  

  return(content) 
 
  }

observe({ 
  datamap<-leafletProxy("datamap")
  datamap %>% clearPopups()
  event<-input$datamap_marker_click
  if (is.null(event)){
    return()
  } else{
    isolate({datamap %>% addPopups(event$lng, event$lat, popContent(event$id),
                                   options=popupOptions(closeOnClick=T))})
  }

})

})

