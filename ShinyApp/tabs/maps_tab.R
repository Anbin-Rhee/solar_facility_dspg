# tabs/maps_tab.R

maps_tab <- tabPanel(
  "Maps",
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Map Controls"),
      
      # Geographic Level Switch
      radioButtons("map_level", "Select Geographic Level:",
                   choices = c("County Level", "Parcel Level"),
                   selected = "County Level"),
      hr(),
      
      # County Level controls
      conditionalPanel(
        condition = "input.map_level == 'County Level'",
        selectInput("county_year", "Select Year:",
                    choices = sort(unique(county_level_data$Year), decreasing = TRUE),
                    selected = max(county_level_data$Year)),
        helpText("Click on a county to view its land value and demographic indicators.")
      ),
      
      
      # Parcel Level controls
      conditionalPanel(
        condition = "input.map_level == 'Parcel Level'",
        selectInput("parcel_locality", "Filter by Locality:",
                    choices = NULL)
      ),
      
      hr(),
      tags$div(
        style = "margin-top: 10px; font-size: 13px;",
        tags$strong("🛈 Map User Guide"),
        tags$ul(
          style = "padding-left: 18px;",
          
          tags$li(tags$strong("ATTENTION:"), " The maps may take longer to load on initial use. Please allow approximately 2–5 minutes for full data rendering, especially when switching to parcel-level views."),
          
          tags$li("Use the buttons above to switch between County and Parcel views."),
          
          tags$li(tags$strong("County Level:"), " Shows average values (e.g., price per acre, corn yield) across Virginia counties. Click a county to view details."),
          
          tags$li(tags$strong("Parcel Level:"), " Displays individual land parcels for a selected locality. For performance, a sample of up to 5,000 parcels may be shown."),
          
          tags$li("Additional map layers (e.g., Roads, Urban Centers, Water) are simplified for speed — only major cities, roads, and features are included."),
          
          tags$li("You can toggle layers in either view, but they are best used while viewing individual parcels."),
          
          tags$li("The map automatically zooms to your selected locality. If loading seems slow, please wait a few seconds for data to appear.")
        )
      )
    ),
    
    mainPanel(
      width = 9,
      leafletOutput("interactive_map", height = "800px")
    )
  )
)
