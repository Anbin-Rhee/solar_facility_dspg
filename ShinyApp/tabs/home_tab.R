home_tab <- tabPanel(title = tagList(icon("home"), "Home"),
                     fluidPage(
                       fluidRow(
                         column(width = 12,
                                h1("Land Value & Solar"),
                                h3("The Impact of Utility-Scale Solar Facilities on Agricultural Land Prices in Virginia"),
                                tags$img(src = "Solar1.jpg", width = "100%")
                         )
                       )
                     )
)