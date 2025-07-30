home_tab <- tabPanel(
  title = tagList(icon("home"), "Home"),
  fluidPage(
    fluidRow(
      column(
        width = 12,
        
        # --- Main Project Title ---
        h1("Do Utility-Scale Solar Facilities Affect the Value of Farm(Land)?",
           style = "text-align: center; margin-bottom: 15px;"),
        
        # --- Authors and Program Info ---
        div(
          style = "font-size: 18px; color: #FDCA00; text-align: center;",
          p(tags$b(tags$i("Aziza Altyyeva & Collin Holt"))),
          p(tags$b(tags$i(
            tags$a(
              href = "https://aaec.vt.edu/academics/undergraduate/dspg.html",
              target = "_blank",
              style = "color: #FDCA00; text-decoration: underline;",
              "Data Science for the Public Good, "
            ),
            "Summer 2025"
          ))),
          p(tags$b(tags$i("Virginia Tech")))
        ),
        
        # --- Image ---
        tags$br(),
        tags$img(src = "Solar1.jpg", width = "100%", style = "border-radius: 10px;"),
        tags$br(),
        
        # --- Image Citation at Bottom-Right ---
        div(
          style = "text-align: right; font-size: 12px; margin-top: 10px;",
          tags$a(
            href = "https://commons.wikimedia.org/wiki/File:Imagesolar.png",
            target = "_blank",
            style = "text-decoration: underline; color: #888;",
            "Image Source: Wikimedia Commons"
          )
        )
      )
    )
  )
)
