# ===================================================================
# THIS IS THE ENTIRE CONTENT OF app.R
# ===================================================================

source("global.R")
# 1. SOURCE UI TABS 

source("tabs/home_tab.R")
source("tabs/overview_tab.R")
source("tabs/methods_tab.R")
source("tabs/results_tab.R")
source("tabs/maps_tab.R")
source("tabs/team_tab.R")

# 2. DEFINE USER INTERFACE (UI)
ui <- navbarPage(
  title = NULL,
  fluid = TRUE,
  
  header = tags$head(
    withMathJax(),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  
  home_tab,
  overview_tab,
  methods_tab,
  results_tab,
  maps_tab,
  team_tab
)

# 3. DEFINE SERVER LOGIC
server <- function(input, output, session) {
  
  observe({
    updateSelectInput(session, "parcel_locality",
                      choices = c("All", sort(unique(final_data$LOCALITY))),
                      selected = "All")
  })
  
  output$overview_map <- renderLeaflet({
    leaflet(data = map_data) %>%
      addProviderTiles(providers$CartoDB.Positron, group = "Street Map") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "Topographic") %>%
      addProviderTiles(providers$CartoDB.DarkMatter, group = "Dark") %>%
      addCircleMarkers(
        lng = ~Longitude,
        lat = ~Latitude,
        radius = 5,
        color = "gold",
        stroke = TRUE,
        fillOpacity = 0.8,
        popup = ~paste(
          "<b>Facility:</b>", Facility_Name, "<br>",
          "<b>County:</b>", County, "<br>",
          "<b>Capacity (AC):</b>", paste(Capacity_MW, "MW"), "<br>",
          "<b>Technology:</b>", "Photovoltaic (PV)", "<br>",
          "<b>Year Commissioned:</b>", Commission_Year
        )
      ) %>%
      addLayersControl(
        baseGroups = c("Street Map", "Satellite", "Topographic", "Dark"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  output$county_did_equation <- renderUI({
    withMathJax(
      p('$$
      \\begin{aligned}
      \\log(Price_{ct}) = \\beta_0 
      & + \\beta_1 DiD_{ct} 
      + \\beta_2 Population_{ct} 
      + \\beta_3 TotalHousing_{ct} \\\\
      & + \\beta_4 OccupiedHousing_{ct}
      + \\beta_5 VacantHousing_{ct}
      + \\beta_6 AvgHouseAge_{ct} \\\\
      & + \\beta_7 CornYield_{ct}
      + \\beta_8 SoybeansYield_{ct}
      + \\gamma_c 
      + \\delta_t 
      + \\epsilon_{ct}
      \\end{aligned}
      $$')
    )
  })
  
  output$parcel_did_equation <- renderUI({
    withMathJax(
      p(style = "font-style: italic !important;",
        '$$
        \\begin{aligned}
        \\log(\\text{Price per Acre}_{i,c,s,t}) = \\alpha
         &+ \\beta \\log(\\text{SFDist}_{i,c,s,t})
         + \\delta \\log(\\text{GridDist}_{i,c,s,t})
         + \\sigma \\text{Post}_{t} \\\\
         &+ \\gamma(\\log(\\text{SFDist}_{i,c,s,t}) \\times \\text{Post}_{t})
         + \\phi(\\log(\\text{GridDist}_{i,c,s,t}) \\times \\text{Post}_{t}) \\\\
         &+ \\theta_1 \\text{Acres}_{i}
         + \\theta_2 \\text{FlatnessScore}_{i}
         + \\theta_3 \\text{RoadDist}_{i}
         + \\theta_4 \\text{WaterDist}_{i} 
         + \\theta_5 \\text{UrbanDist}_{i} \\\\
         &+ \\mu_i + \\lambda_c + \\tau_t + \\epsilon_{i,c,s,t}
        \\end{aligned}
        $$'
      )
    )
  })
  
  output$county_results_table <- renderUI({
    table1 <- modelsummary(county_model_simple,
                           output = "gt",
                           stars = TRUE,
                           statistic = "std.error",
                           gof_map = c("nobs", "r.squared", "adj.r.squared"),
                           title = "Table 1a: Simple Model")
    
    table2 <- modelsummary(county_model_full,
                           output = "gt",
                           stars = TRUE,
                           statistic = "std.error",
                           gof_map = c("nobs", "r.squared", "adj.r.squared"),
                           title = "Table 1b: Full Model")
    
    tagList(
      fluidRow(
        column(width = 6, table1),
        column(width = 6, table2)
      )
    )
  })
  
  output$parcel_results_table <- render_gt({
    req(parcel_model_full) 
    
    modelsummary(
      parcel_model_full,
      output = "gt",
      stars = TRUE,
      statistic = "std.error",
      gof_map = c("nobs", "r.squared"),
      title = "Table 2: Parcel-Level Continuous DiD Regression Results"
    )
  })
  
  output$hypotheses_full_output <- renderUI({
    withMathJax(HTML("
<p>To formally test our research questions, we established the following null ($H_0$) and alternative ($H_a$) hypotheses:</p>
    $$
    \\begin{aligned}
&\\text{For the County-Level Analysis:} \\\\
&\\qquad \\boldsymbol{H_0: \\beta_{DiD} = 0}: 
    \\text{ The presence of a solar facility has no effect on average county-level agricultural land values.} \\\\
&\\qquad \\boldsymbol{H_a: \\beta_{DiD} \\neq 0}: 
    \\text{ The presence of a solar facility has a non-zero effect on average county-level agricultural land values.} \\\\
    \\\\
&\\text{For the Parcel-Level Analysis:} \\\\
&\\qquad \\boldsymbol{H_0: \\beta_{Dist \\times Post} = 0}: 
    \\text{ The effect of distance from infrastructure on parcel value does not change after a facility is commissioned.} \\\\
&\\qquad \\boldsymbol{H_a: \\beta_{Dist \\times Post} \\neq 0}: 
    \\text{ The effect of distance from infrastructure on parcel value is different after a facility is commissioned.}
    \\end{aligned}
    $$
  "))
  })
  
  output$parcel_interpretation_output <- renderUI({
    HTML(
      paste0(
        "<hr>",
        "<h4><strong>Interpretation of Results</strong></h4>",
        "<p>The analysis of the parcel-level interaction model reveals how land values are affected by a parcel's specific location relative to new solar facilities and existing grid infrastructure.</p>",
        "<ul>",
        "<li><strong>Increased Valuation of Grid Proximity Post-Construction:</strong> The model's primary finding is the statistically significant, negative coefficient <strong>(-0.139*)</strong> on the <code>is_post_period × log_grid_dist</code> interaction term. <strong>This allows us to reject the null hypothesis</strong> that the effect of grid distance on parcel value is the same before and after a facility is commissioned. This result indicates that after a solar facility is built, land parcels located farther from the electrical grid experience a relative decrease in value.</li>",
        "<li><strong>Insignificant Impact of Solar Facility Proximity:</strong> Conversely, the interaction term between the distance to the solar facility and the post-construction period, <code>log_sf_dist × is_post_period</code>, is not statistically significant. This suggests a lack of widespread evidence for a systematic price premium or penalty (i.e., an amenity or nuisance effect) that is dependent on a parcel's specific distance from the solar facility itself.</li>",
        "<li><strong>Model Validation through Control Variables:</strong> The model's control variables perform in a manner consistent with established land valuation principles. For example, land value per acre is negatively associated with parcel size (<code>Acres</code>) and distance from roads (<code>dist_road_miles</code>) and water (<code>dist_water_miles</code>). The statistical significance and expected direction of these controls increase confidence in the overall model specification.</li>",
        "</ul>"
      )
    )
  })
  
  filtered_parcel_data <- reactive({
    req(input$parcel_locality)
    
    data_to_filter <- if (input$parcel_locality == "All") {
      final_data
    } else {
      final_data %>% filter(LOCALITY == input$parcel_locality)
    }
    
    if (nrow(data_to_filter) > 5000) {
      notification_message <- if (input$parcel_locality == "All") {
        "Displaying a random sample of 5,000 parcels from across Virginia for performance."
      } else {
        paste("Displaying a random sample of 5,000 parcels for", input$parcel_locality, "for performance.")
      }
      showNotification(notification_message, type = "warning", duration = 8)
      
      data_to_filter <- sample_n(data_to_filter, 5000)
    }
    
    return(data_to_filter)
  })
  
  output$interactive_map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron, group = "Street Map") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "Topographic") %>%
      addProviderTiles(providers$CartoDB.DarkMatter, group = "Dark") %>%
      setView(lng = -79.5, lat = 37.5, zoom = 7) %>%
      addPolylines(
        data = va_state_border, color = "#00008B", weight = 2.5, opacity = 1
      ) %>%
      addCircleMarkers(
        data = map_data, lng = ~Longitude, lat = ~Latitude, radius = 5, color = "gold",
        stroke = TRUE, fillOpacity = 0.8, group = "Solar Facilities",
        popup = ~paste("<b>Facility:</b>", Facility_Name)
      ) %>%
      addPolylines(
        data = lines_va, color = "green", weight = 2, opacity = 0.9,
        group = "Transmission Lines", popup = ~paste("Transmission Line")
      ) %>%
      addLayersControl(
        baseGroups = c("Street Map", "Satellite", "Topographic", "Dark"),
        overlayGroups = c("Solar Facilities", "Transmission Lines"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  observe({
    proxy <- leafletProxy("interactive_map") %>%
      clearShapes() %>%
      clearControls()
    
    add_solar_facilities <- function(map_proxy) {
      map_proxy %>% addCircleMarkers(
        data = map_data, lng = ~Longitude, lat = ~Latitude, radius = 5, color = "gold",
        stroke = TRUE, fillOpacity = 0.8, group = "Solar Facilities",
        popup = ~paste("<b>Facility:</b>", Facility_Name)
      )
    }
    
    add_transmission_lines <- function(map_proxy) {
      map_proxy %>% addPolylines(
        data = lines_va, color = "green", weight = 2, opacity = 0.9,
        group = "Transmission Lines", popup = ~paste("Transmission Line")
      )
    }
    
    if (input$map_level == "County Level") {
      proxy %>%
        addPolygons(
          data = va_counties, fillColor = "transparent", weight = 1.5, color = "#444444", opacity = 1.0,
          popup = ~paste0("<b>County:</b> ", NAME), label = ~NAME,
          highlightOptions = highlightOptions(weight = 3, color = "blue", bringToFront = TRUE)
        ) %>%
        addPolylines(data = va_state_border, color = "#00008B", weight = 2.5, opacity = 1) %>%
        add_solar_facilities() %>%
        add_transmission_lines() %>%
        flyTo(lng = -79.5, lat = 37.5, zoom = 7)
      return() 
    }
    
    if (input$map_level == "Parcel Level") {
      df <- filtered_parcel_data()
      if (nrow(df) == 0) return()
      
      selected_var <- input$parcel_variable
      data_column <- as.numeric(df[[selected_var]])
      if (all(is.na(data_column))) return()
      
      pal <- colorNumeric(palette = "viridis", domain = data_column, na.color = "transparent")
      
      proxy %>%
        addPolygons(
          data = df, fillColor = ~pal(data_column), fillOpacity = 0.7, weight = 0.5, color = "grey",
          popup = ~paste0("<b>", names(which(map_variables == selected_var)), ":</b> ", round(data_column, 2))
        ) %>%
        addLegend(
          position = "topleft", pal = pal, values = data_column,
          title = names(which(map_variables == selected_var)), na.label = "No Data", opacity = 1
        ) %>%
        add_solar_facilities() %>%
        add_transmission_lines()
      
      if (input$parcel_locality != "All") {
        selected_county_shape <- va_counties %>% filter(NAME == input$parcel_locality)
        proxy %>% addPolylines(data = selected_county_shape, color = "black", weight = 3, opacity = 1.0)
        
        if (nrow(selected_county_shape) > 0) {
          bbox <- sf::st_bbox(selected_county_shape)
          proxy %>% flyToBounds(lng1 = bbox$xmin, lat1 = bbox$ymin, lng2 = bbox$xmax, lat2 = bbox$ymax)
        }
      } else {
        proxy %>% 
          addPolylines(data = va_state_border, color = "#00008B", weight = 2.5, opacity = 1) %>%
          flyTo(lng = -79.5, lat = 37.5, zoom = 7)
      }
    }
  })
}

# 4. RUN THE APPLICATION
app <- shinyApp(ui = ui, server = server)

# Serve everything inside the "www/" folder as if it's coming from the root "/"
# This enables src="Solar1.jpg" and href="styles.css" to work as expected
app$staticPaths <- list(
  "/" = httpuv::staticPath(
    path = file.path(getwd(), "www"),
    indexhtml = FALSE,
    fallthrough = TRUE
  )
)

# Return the app object so it runs in R
app