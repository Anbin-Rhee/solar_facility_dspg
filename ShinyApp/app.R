library(shiny)
#install.packages("bslib") # This should ideally be run once, not every time the app starts
library(shinythemes) # You don't seem to be using shinythemes, so this might be unnecessary
library(bslib)
addResourcePath("myimages", "www")

source("tabs/home_tab.R")


source("tabs/overview_tab.R")

source("tabs/methods_tab.R")
source("tabs/results_tab.R")
source("tabs/maps_tab.R")
source("tabs/team_tab.R")

# --- UI Skeleton ---
ui <- navbarPage(
  title = NULL,
  fluid = TRUE,
  
  header = tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  
  # Assemble the tabs from their variables
  home_tab,
  overview_tab,
  methods_tab,
  results_tab,
  maps_tab,
  team_tab
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

