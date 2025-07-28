# tabs/maps_tab.R

maps_tab <- tabPanel(
  "Maps",
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Map Controls"),
      
      # Main switch for geographic level
      radioButtons("map_level", "Select Geographic Level:",
                   choices = c("County Level", "Parcel Level"),
                   selected = "County Level"),
      hr(),
      
      # County Level controls
      conditionalPanel(
        condition = "input.map_level == 'County Level'",
        helpText("Showing Virginia county boundaries.")
      ),
      
      # Parcel Level controls
      conditionalPanel(
        condition = "input.map_level == 'Parcel Level'",
        selectInput("parcel_variable", "Select Parcel Variable:",
                    choices = map_variables),
        selectInput("parcel_locality", "Filter by Locality:",
                    choices = NULL)  # We'll populate this dynamically
      )
    ),
    
    mainPanel(
      width = 9,
      leafletOutput("interactive_map", height = "800px")
    )
  )
)
