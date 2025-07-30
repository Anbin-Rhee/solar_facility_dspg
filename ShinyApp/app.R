# ===================================================================
# THIS IS THE FULLY POLISHED VERSION OF app.R
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
  
  # --- Update locality dropdown
  observe({
    updateSelectInput(session, "parcel_locality",
                      choices = c("All", sort(unique(final_data$LOCALITY))),
                      selected = "All"
    )
  })
  
  # --- Reactive filtered parcel data
  filtered_parcel_data <- reactive({
    req(input$parcel_locality)
    data_to_filter <- if (input$parcel_locality == "All") {
      final_data
    } else {
      final_data %>% filter(LOCALITY == input$parcel_locality)
    }
    
    if (nrow(data_to_filter) > 5000) {
      showNotification("Displaying a random sample of 5,000 parcels for performance.", type = "warning", duration = 6)
      data_to_filter <- sample_n(data_to_filter, 5000)
    }
    
    return(data_to_filter)
  })
  
  # --- Render Overview Map (static)
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
        popup = ~paste0(
          "<b>Facility:</b> ", Facility_Name, "<br>",
          "<b>County:</b> ", County, "<br>",
          "<b>Capacity (AC):</b> ", Capacity_MW, " MW<br>",
          "<b>Technology:</b> Photovoltaic (PV)<br>",
          "<b>Year Commissioned:</b> ", Commission_Year
        ),
        group = "Solar Facilities"
      ) %>%
      addLayersControl(
        baseGroups = c("Street Map", "Satellite", "Topographic", "Dark"),
        overlayGroups = c("Solar Facilities"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  # --- Render Interactive Map
  output$interactive_map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron, group = "Street Map") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "Topographic") %>%
      addProviderTiles(providers$CartoDB.DarkMatter, group = "Dark") %>%
      setView(lng = -79.5, lat = 37.5, zoom = 7) %>%
      addPolylines(data = va_state_border, color = "#00008B", weight = 2.5, opacity = 1) %>%
      addCircleMarkers(
        data = map_data,
        lng = ~Longitude,
        lat = ~Latitude,
        radius = 5,
        color = "gold",
        stroke = TRUE,
        fillOpacity = 0.8,
        group = "Solar Facilities",
        popup = ~paste("<b>Facility:</b>", Facility_Name)
      ) %>%
      addPolylines(
        data = lines_va,
        color = "green",
        weight = 2,
        opacity = 0.9,
        group = "Transmission Lines",
        popup = ~paste("Transmission Line")
      ) %>%
      addCircleMarkers(
        data = VA_cities,
        lng = ~st_coordinates(geometry)[,1],
        lat = ~st_coordinates(geometry)[,2],
        radius = 4,
        color = "red",
        stroke = FALSE,
        fillOpacity = 0.6,
        group = "Urban Centers",
        popup = ~paste0("<b>City:</b> ", NAME)
      ) %>%
      addPolylines(
        data = VA_roads,
        color = "gray",
        weight = 1,
        opacity = 0.7,
        group = "Roads"
      ) %>%
      addCircleMarkers(
        data = water_features,
        lng = ~st_coordinates(geometry)[,1],
        lat = ~st_coordinates(geometry)[,2],
        radius = 3,
        color = "blue",
        stroke = FALSE,
        fillOpacity = 0.5,
        group = "Water Features",
        popup = ~paste0("<b>Waterbody:</b> ", FULLNAME)
      ) %>%
      addLayersControl(
        baseGroups = c("Street Map", "Satellite", "Topographic", "Dark"),
        overlayGroups = c("Solar Facilities", "Transmission Lines", "Urban Centers", "Roads", "Water Features"),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      hideGroup(c("Transmission Lines", "Urban Centers", "Roads", "Water Features"))
  })
  
  # --- Observer for County / Parcel Rendering
  observe({
    proxy <- leafletProxy("interactive_map") %>%
      clearShapes() %>%
      clearControls()
    
    if (input$map_level == "County Level") {
      selected_year_data <- county_year_summary %>% filter(Year == input$county_year)
      counties_to_show <- left_join(va_counties, selected_year_data, by = c("NAME" = "County"))
      
      proxy %>%
        addPolygons(
          data = counties_to_show,
          fillColor = "#76CBEC",
          fillOpacity = 0.6,
          weight = 1.5,
          color = "#444444",
          popup = ~paste0(
            "<b>County:</b> ", NAME, "<br>",
            "<b>Year:</b> ", Year, "<br>",
            "<b>Price per Acre ($):</b> ", round(as.numeric(Price_Per_Acre), 0), "<br>",
            "<b>Corn Yield:</b> ", round(as.numeric(CornYield), 1), " bu/acre<br>",
            "<b>Soybean Yield:</b> ", round(as.numeric(SoyYield), 1), " bu/acre<br>",
            "<b>Avg Housing Age:</b> ", round(as.numeric(HousingAge), 1), "<br>",
            "<b>Population:</b> ", round(as.numeric(Population), 0), "<br>",
            "<b>Housing Units:</b> ", round(as.numeric(TotalHousingUnits), 0), " (",
            round(as.numeric(OccupiedUnits), 0), " occupied / ",
            round(as.numeric(VacantUnits), 0), " vacant)<br>",
            "<b>Treated:</b> ", ifelse(as.numeric(Treated) == 1, "Yes (Has solar facility)", "No"), "<br>",
            "<b>Post-period:</b> ", ifelse(as.numeric(Post) == 1, "Yes", "No")
          )
        ) %>%
        flyTo(lng = -79.5, lat = 37.5, zoom = 7)
    }
    
    if (input$map_level == "Parcel Level") {
      df <- filtered_parcel_data()
      if (nrow(df) == 0) return()
      
      proxy %>%
        addPolygons(
          data = df,
          fillColor = "#D2691E",
          fillOpacity = 0.6,
          color = "darkgray",
          weight = 0.5,
          label = ~paste0("Parcel ID: ", PARCELID),
          popup = ~paste0(
            "<b>Parcel ID:</b> ", PARCELID, "<br>",
            "<b>Acres:</b> ", ifelse(is.na(Acres), "NA", round(as.numeric(Acres), 2)), "<br>",
            "<b>Price per Acre ($):</b> ", ifelse(is.na(per_acre), "NA", round(as.numeric(per_acre), 2)), "<br>",
            "<b>Flatness Score:</b> ", ifelse(is.na(composite_flatness_score), "NA", round(as.numeric(composite_flatness_score), 2)), "<br>",
            "<b>Dist to Solar Facility (mi):</b> ", ifelse(is.na(sf_pc_dist), "NA", round(as.numeric(sf_pc_dist), 2)), "<br>",
            "<b>Dist to Grid Line (mi):</b> ", ifelse(is.na(dist_parcel_to_line), "NA", round(as.numeric(dist_parcel_to_line), 2)), "<br>",
            "<b>Dist to Road (mi):</b> ", ifelse(is.na(dist_road_miles), "NA", round(as.numeric(dist_road_miles), 2)), "<br>",
            "<b>Dist to Water (mi):</b> ", ifelse(is.na(dist_water_miles), "NA", round(as.numeric(dist_water_miles), 2)), "<br>",
            "<b>Dist to Urban Center (mi):</b> ", ifelse(is.na(dist_urban_miles), "NA", round(as.numeric(dist_urban_miles), 2))
          )
        ) %>%
        
        # Re-add Transmission Lines and Roads (after clearing)
        addPolylines(
          data = lines_va,
          color = "green",
          weight = 2,
          opacity = 0.9,
          group = "Transmission Lines",
          popup = ~"Transmission Line"
        ) %>%
        
        addPolylines(
          data = VA_roads,
          color = "gray",
          weight = 1,
          opacity = 0.7,
          group = "Roads"
        )
      
      # Zoom logic
      if (input$parcel_locality != "All") {
        county_shape <- va_counties %>% filter(NAME == input$parcel_locality)
        if (nrow(county_shape) > 0) {
          proxy %>% addPolylines(data = county_shape, color = "black", weight = 3, opacity = 1)
          bbox <- st_bbox(county_shape)
          proxy %>% flyToBounds(bbox$xmin, bbox$ymin, bbox$xmax, bbox$ymax)
        }
      } else {
        proxy %>%
          addPolylines(data = va_state_border, color = "#00008B", weight = 2.5, opacity = 1) %>%
          flyTo(lng = -79.5, lat = 37.5, zoom = 7)
      }
    }
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
    \\text{ The effect of distance from infrastructure (transmission lines) on parcel value does not change after a facility is commissioned.} \\\\
&\\qquad \\boldsymbol{H_a: \\beta_{Dist \\times Post} \\neq 0}: 
    \\text{ The effect of distance from infrastructure (transmission lines) on parcel value is different after a facility is commissioned.}
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
        "<li><strong>Increased Valuation of Grid Proximity Post-Construction:</strong> The model's primary finding is the statistically significant, negative coefficient <strong>(-0.139*)</strong> on the <code>is_post_period × log_grid_dist</code> interaction term. <strong>This allows us to reject the null hypothesis</strong> that the effect of grid distance on parcel value is the same before and after a facility is commissioned. <strong>This result indicates that after a solar facility is built, land parcels located farther from the electrical grid experience a relative decrease in value.</strong></li>",
        "<li><strong>Insignificant Impact of Solar Facility Proximity:</strong> Conversely, the interaction term between the distance to the solar facility and the post-construction period, <code>log_sf_dist × is_post_period</code>, is not statistically significant. This suggests a lack of widespread evidence for a systematic price premium or penalty (i.e., an amenity or nuisance effect) that is dependent on a parcel's specific distance from the solar facility itself.</li>",
        "<li><strong>Model Validation through Control Variables:</strong> The model's control variables perform in a manner consistent with established land valuation principles. For example, land value per acre is negatively associated with parcel size (<code>Acres</code>) and distance from roads (<code>dist_road_miles</code>) and water (<code>dist_water_miles</code>). The statistical significance and expected direction of these controls increase confidence in the overall model specification.</li>",
        "</ul>"
      )
    )
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
