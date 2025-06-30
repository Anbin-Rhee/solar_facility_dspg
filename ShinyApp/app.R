library(shiny)
#install.packages("bslib") # This should ideally be run once, not every time the app starts
library(shinythemes) # You don't seem to be using shinythemes, so this might be unnecessary
library(bslib)
addResourcePath("myimages", "www")

ui <- navbarPage(
  title = NULL,
  fluid = TRUE, # Removes the default tab title look
  
  # Custom CSS
  header = tagList(
    tags$head(
      tags$style(HTML("
        /* Ensure the body itself has no top margin or padding */
        body {
          margin-top: 0 !important;
          padding-top: 0 !important;
        }

        /* Target the main navbar container directly and remove all unnecessary spacing */
        .navbar {
          min-height: 0 !important; /* Remove any minimum height */
          margin-bottom: 0 !important; /* Ensure no margin at the bottom of the navbar */
          border: none !important; /* Remove any default border that might add height */
          padding-top: 0 !important; /* Ensure no top padding on the navbar itself */
          padding-bottom: 0 !important; /* Ensure no bottom padding on the navbar itself */
          padding-left: 0 !important;  /* NEW: Remove left padding */
          padding-right: 0 !important; /* NEW: Remove right padding */
        }
        /* Ensure the .container-fluid inside the navbar has no horizontal padding */
        .navbar .container-fluid {
          padding-left: 0 !important;  
          padding-right: 0 !important; 
        }
        /* Ensure the navbar-header (which holds branding/toggle) doesn't add height */
        .navbar-header {
          min-height: 0 !important;
          padding-top: 0 !important;
          padding-bottom: 0 !important;
        }

        /* Ensure the navbar-brand (if present, though you have title=NULL) doesn't add height */
        .navbar-brand {
          height: auto !important;
          padding-top: 0 !important;
          padding-bottom: 0 !important;
        }

        /*  Remove blue navbar background */
        .navbar-default {
          background-color: transparent;
          border: none;
          box-shadow: none;
          margin-bottom: 0;
          padding: 0;
        }

        /*  Remove collapse spacing */
        .navbar-collapse {
          padding: 0;
          margin: 0;
          width: 100%; /* Make sure the collapse content also takes full width */
        }

        /*  Layout nav items in a row and distribute them */
        .navbar-nav {
          display: flex;
          justify-content: space-around;
          align-items: stretch;
          width: 100%;
          margin: 0;
          height: auto;
        }

        /*  Each tab container */
        .navbar-nav > li {
          margin: 0;
          flex-grow: 1;
          text-align: center;
        }

        /*  Tab buttons styled like blue rectangles */
        .navbar-nav > li > a {
          background-color: #001f87;
          color: gold !important;
          font-weight: bold;
          padding: 10px 0;
          margin: 0;
          border-radius: 0px;
          border: none;
          display: block;
          height: 100%;
          text-align: center;
        }

        /*  Hover effect for tabs */
        .navbar-nav > li > a:hover {
          background-color: #002f9c !important;
          color: white !important;
        }

        /* ✅Active tab styling */
        .navbar-nav > .active > a,
        .navbar-nav > .active > a:focus,
        .navbar-nav > .active > a:hover {
          background-color: #000066 !important;
          color: white !important;
          border: none;
          border-bottom: 3px solid white;
          padding-bottom: 7px;
        }

        /* Title */
        h1 {
          color: #001f87;
          font-weight: bold;
          text-align: center;
          margin-top: 30px;
        }

        /*  Subtitle */
        h3 {
          color: #efb173;
          font-style: italic;
          text-align: center;
          margin-bottom: 30px;
        }
        
        /* Academic Text Styling for Overview Tab - Simplified for readability */
        #overview-content {
          max-width: 900px; /* Max width for readability */
          margin: 40px auto; /* Center the content horizontally, add top/bottom margin */
          padding: 20px; /* Space inside the content box */
          background-color: #f9f9f9; /* Light background for the content area */
          border-radius: 8px; /* Slightly rounded corners */
          box-shadow: 0 2px 5px rgba(0,0,0,0.1); /* Subtle shadow */
        }
        /* No specific styling for p, h2, h3, ul, li here for now, let them default */
        
         /* --- NEW CSS FOR FULL WIDTH IMAGE --- */
        /* Ensure the tab content area itself has no horizontal padding */
        .tab-content > .tab-pane {
          padding-left: 0 !important;
          padding-right: 0 !important;
        }

        /* Ensure the fluid container within the tab content has no horizontal padding */
        .tab-content .container-fluid {
          padding-left: 0 !important;
          padding-right: 0 !important;
        }

        /* Ensure the 12-column element itself has no horizontal padding */
        .col-sm-12 { /* Assuming Shiny's column is .col-sm-12 by default */
          padding-left: 0 !important;
          padding-right: 0 !important;
        }

        /* Ensure the image is a block element and truly spans 100% */
        .tab-content img {
          display: block; /* Make it a block element to control margins/padding fully */
          margin: 0 !important; /* Remove any default margins */
          padding: 0 !important; /* Remove any default paddings */
          max-width: 100%; /* Ensure it's responsive */
          height: auto; /* Maintain aspect ratio */
        }
        /* --- END NEW CSS --- */
      "))
    )
  ),
  
  
  # HOME tab — now the first tab shown
  tabPanel(title = tagList(icon("home"), "Home"),
           fluidPage(
             fluidRow(
               column(width = 12,
                      h1("Land Value & Solar"),
                      h3("The Impact of Utility-Scale Solar Facilities on Agricultural Land Prices in Virginia"),
                      tags$img(src = "Solar1.jpg", width = "100%")
               )
             )
           )
  ),
  
  # Other placeholder tabs
  tabPanel("Overview",
           fluidPage(
             tags$div(
               id = "overview-content", # Target for basic container styling
               tags$h2("Introduction", style = "color: #001f87;"), # Optional: keep heading color
               tags$p("Virginia, founded in 1607, is a state made up of 95 counties and 38 independent cities, and has a unique landscape which is made up of the coastal plain, piedmont, blue ridge mountains, valley and ridge, and the Appalachian plateau. Virginia spans over 42,000 square miles and is known for its colonial history, as well as its agricultural heritage."),
               tags$p("In 2023, Virginia was ranked as the 9th largest producer of solar energy in the US. Virginia also gets 5% of its energy from solar (Virginia Department of Energy). The development of utility-scale facilities presents an important step towards green energy, in the fight against climate change."),
               
               tags$h2("Rise of Solar Development in Virginia", style = "color: #001f87;"), # Optional: keep heading color
               tags$p("Utility-scale solar facilities consist of arrays of solar panels; each composed of individual photovoltaic cells. The individual photovoltaic cells collect direct current energy from the sun, which is then converted into alternating current energy and delivered to a local power grid. Under the Biden administration green energy solutions were pushed heavily and $7 billion dollars in grants were allocated through the Solar for All Grant to deliver residential solar energy to 900,000 households (EPA). Even further, the state of Virginia has been pushing towards carbon-neutrality and is working towards using 100% carbon free energy sources by 2050 (Virginia Department of Energy). Both of these efforts have led to an expansion in utility scale solar facility development, and in 2024 the state of Virginia created enough solar energy to power nearly 750,000 average households (Environment America). While this development of solar energy has been beneficial in some cases, local farmers are grappling over whether or not it affects agrarian land values in the state."),
               
               tags$h2("Research Questions", style = "color: #001f87;"), # Optional: keep heading color
               tags$p("1. What is the effect of utility-scale solar facility (USSF) implementation on agricultural land values at the county level in Virginia?"),
               tags$p("2. What is the impact of utility-scale solar facilities (USSF) on the market value of nearby agricultural properties in Virginia?")
             )
           )
  ),
  tabPanel("Methods", fluidPage(h3("Methods content coming soon..."))),
  tabPanel("Results", fluidPage(h3("Results content coming soon..."))),
  tabPanel("Maps", fluidPage(h3("Maps content coming soon..."))),
  tabPanel("Meet the Team", fluidPage(h3("Team bios coming soon...")))
)

server <- function(input, output, session) {}

app <- shinyApp(ui = ui, server = server)
app$staticPaths <- list(
  `/` = httpuv::staticPath(
    file.path(getwd(), "www"), indexhtml = FALSE, fallthrough = TRUE
  )
)
app

#list.files("www")

