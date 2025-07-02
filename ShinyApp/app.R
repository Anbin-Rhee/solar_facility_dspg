library(shiny)
#install.packages("bslib") # This should ideally be run once, not every time the app starts
library(shinythemes) # You don't seem to be using shinythemes, so this might be unnecessary
library(bslib)
addResourcePath("myimages", "www")

ui <- navbarPage(
  title = NULL,
  fluid = TRUE, # Removes the default tab title look
  
  #Link to your external stylesheet
  header = tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
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

