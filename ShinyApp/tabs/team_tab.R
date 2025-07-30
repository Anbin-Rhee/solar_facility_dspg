team_tab <- tabPanel(
  "Meet the Team",
  fluidPage(
    
    # === UNDERGRADUATE INTERNS ===
    tags$h2("Undergraduate Interns", style = "color:#001f87; text-align: center; font-weight: bold; margin-top: 20px; margin-bottom: 30px;"),
    
    # Aziza
    tags$div(style = "display: flex; align-items: center; margin-bottom: 40px;",
             tags$div(
               style = "flex: 0 0 250px; text-align: center; padding-right: 20px;",
               tags$img(src = "aziza.jpeg", style = "border-radius: 10px; max-width: 250px;")
             ),
             tags$div(
               style = "flex: 1;",
               tags$h4("Aziza Altyyeva"),
               tags$p("Berea College"),
               tags$p("Mathematics & Economics, minor in Computer Science"),
               tags$p("DSPG 2025 Intern"),
               tags$p(
                 tags$a(href = "mailto:altyyevaa@berea.edu", "altyyevaa@berea.edu"),
                 " | ",
                 tags$a(href = "https://www.linkedin.com/in/aziza-altyyeva7520/", target = "_blank", "LinkedIn")
               )
             )
    ),
    
    # Collin
    tags$div(style = "display: flex; align-items: center; margin-bottom: 40px;",
             tags$div(
               style = "flex: 0 0 250px; text-align: center; padding-right: 20px;",
               tags$img(src = "collin_headshot.jpeg", style = "border-radius: 10px; max-width: 250px;")
             ),
             tags$div(
               style = "flex: 1;",
               tags$h4("Collin Holt"),
               tags$p("University of Richmond"),
               tags$p("Business Administration with concentrations in Business Analytics & Management, minor in Geography"),
               tags$p("DSPG 2025 Intern"),
               tags$p(
                 tags$a(href = "mailto:collin.holt@richmond.edu", "collin.holt@richmond.edu"),
                 " | ",
                 tags$a(href = "https://linkedin.com/in/collin-holt-1158a1274", target = "_blank", "LinkedIn")
               )
             )
    ),
    
    tags$hr(style = "margin-top: 50px; margin-bottom: 30px;"),
    
    # === GRADUATE FELLOW ===
    tags$h2("Graduate Fellow", style = "color:#001f87; text-align: center; font-weight: bold; margin-bottom: 30px;"),
    
    tags$div(style = "display: flex; align-items: flex-start; margin-bottom: 40px;",
             tags$div(
               style = "flex: 0 0 250px; text-align: center; padding-right: 20px;",
               tags$img(src = "Anbin_Rhee.jpeg", style = "border-radius: 10px; max-width: 250px;")
             ),
             tags$div(
               style = "flex: 1;",
               tags$h4("Anbin Rhee"),
               tags$p("Graduate Fellow | Virginia Tech"),
               tags$p("Department of Statistics"),
               tags$p(
                 tags$a(href = "mailto:abrhee@vt.edu", "abrhee@vt.edu")
               )
             )
    ),
    
    tags$hr(style = "margin-top: 50px; margin-bottom: 30px;"),
    
    # === FACULTY MENTOR ===
    tags$h2("Faculty Mentor", style = "color:#001f87; text-align: center; font-weight: bold; margin-bottom: 30px;"),
    
    tags$div(style = "display: flex; align-items: flex-start; margin-bottom: 40px;",
             tags$div(
               style = "flex: 0 0 250px; text-align: center; padding-right: 20px;",
               tags$img(src = "dr_cary_headshot.jpeg", style = "border-radius: 10px; max-width: 250px;")
             ),
             tags$div(
               style = "flex: 1;",
               tags$h4("Dr. Michael Cary"),
               tags$p("Research Assistant Professor | Virginia Tech"),
               tags$p("Department of Agricultural and Applied Economics"),
               tags$p(
                 tags$a(href = "mailto:macary@vt.edu", "macary@vt.edu"),
                 " | ",
                 tags$a(href = "https://cat-astrophic.github.io/", target = "_blank", "Personal Website")
               )
             )
         )
    ),
    
  # === ACKNOWLEDGMENTS (unchanged, already perfect) ===
  tags$h2("Acknowledgments", style = "color:#001f87; text-align: center; font-weight: bold; margin-bottom: 20px;"),
  
  # USDA Grant Acknowledgment Box
  tags$div(
    style = "border: 2px solid #1a3e2f; border-radius: 10px; padding: 15px; margin-bottom: 20px; background-color: #f9f9f9;",
    fluidRow(
      column(
        width = 2,
        tags$img(src = "usda_logo.png", style = "max-width: 100px;")
      ),
      column(
        width = 10,
        tags$p(
          style = "font-size: 16px;",
          tags$b("This work is supported by the U.S. Department of Agriculture, National Institute of Food and Agriculture"),
          " as part of the DATA-ACRE program [grant no. 2022-67037-36639 / project accession no. 2021-10424]."
        )
      )
    )
  ),
  
  tags$p("This project was also supported by the USDA through the Data Science for the Public Good (DSPG) Young Scholars Program at Virginia Tech."),
  tags$p("We would like to thank all faculty, graduate fellows, and staff who contributed to the success of this project."),
  
  # === Enhanced Collapsible Citations Section ===
  tags$details(
    style = "margin-top: 20px;",
    tags$summary(
      style = "
      cursor: pointer;
      color: #001f87;
      font-weight: bold;
      font-size: 20px;
      display: flex;
      align-items: center;
      list-style: none;
    ",
      tags$span("▸", style = "margin-right: 8px; transition: transform 0.3s;", id = "citation_arrow"),
      "Click to view data source citations (APA format)"
    ),
    tags$div(style = "margin-top: 10px; font-size: 14px;",
             tags$ul(
               tags$li(
                 "U.S. Census Bureau. (2025, June). County population by characteristics: 2020–2024. United States Census Bureau. Retrieved July 25, 2024, from ",
                 tags$a(href = "https://www.census.gov/data/datasets/time-series/demo/popest/2020s-counties-detail.html", target = "_blank", "https://www.census.gov/data/datasets/time-series/demo/popest/2020s-counties-detail.html")
               ),
               tags$li(
                 "United States Census Bureau. (2021, October 8). County population totals: 2010–2019. U.S. Census Bureau. Retrieved July 25, 2024, from ",
                 tags$a(href = "https://www.census.gov/data/datasets/time-series/demo/popest/2010s-counties-total.html", target = "_blank", "https://www.census.gov/data/datasets/time-series/demo/popest/2010s-counties-total.html")
               ),
               tags$li(
                 "United States Census Bureau. (2020). Gini index of income inequality. U.S. Census Bureau. Retrieved July 25, 2024, from ",
                 tags$a(href = "https://data.census.gov/table/DECENNIALCD1182020.H1?g=040XX00US51", target = "_blank", "https://data.census.gov/table/DECENNIALCD1182020.H1?g=040XX00US51")
               ),
               tags$li(
                 "National Agricultural Statistics Service. (2023, July 18). QuickStats. U.S. Department of Agriculture. Retrieved July 25, 2024, from ",
                 tags$a(href = "https://quickstats.nass.usda.gov/", target = "_blank", "https://quickstats.nass.usda.gov/")
               ),
               tags$li(
                 "U.S. Department of Homeland Security. (2024, January 19). Hospitals. Homeland Infrastructure Foundation-Level Data. Retrieved July 25, 2024, from ",
                 tags$a(href = "https://hifld-geoplatform.hub.arcgis.com/datasets/3486fb60feb2454c99232248fdf624ec_0/explore?location=36.709536%2C-78.748939%2C6.48", target = "_blank", "https://hifld-geoplatform.hub.arcgis.com/datasets/3486fb60feb2454c99232248fdf624ec_0/explore")
               ),
               tags$li(
                 "U.S. Census Bureau, Department of Commerce. (2019). TIGER/Line Shapefile, 2019, state, Virginia, Primary and Secondary Roads State-based Shapefile. Data.gov. Retrieved July 25, 2024, from ",
                 tags$a(href = "https://catalog.data.gov/dataset/tiger-line-shapefile-2019-state-virginia-primary-and-secondary-roads-state-based-shapefile", target = "_blank", "https://catalog.data.gov/dataset/tiger-line-shapefile-2019...")
               ),
               tags$li(
                 "Zhang, C. (2025). CropScape - NASS CDL Program. USDA National Agricultural Statistics Service. Retrieved July 25, 2024, from ",
                 tags$a(href = "https://nassgeodata.gmu.edu/CropScape/", target = "_blank", "https://nassgeodata.gmu.edu/CropScape/")
               ),
               tags$li(
                 "U.S. Department of Agriculture, Economic Research Service. (2025, January 7). Rural-urban continuum codes. Retrieved July 24, 2025, from ",
                 tags$a(href = "https://www.ers.usda.gov/data-products/rural-urban-continuum-codes", target = "_blank", "https://www.ers.usda.gov/data-products/rural-urban-continuum-codes")
               ),
               tags$li(
                 "University of Virginia Library. (2024). Virginia cities. Retrieved July 25, 2024, from ",
                 tags$a(href = "https://hub.arcgis.com/datasets/uvalibrary::virginia-cities/explore", target = "_blank", "https://hub.arcgis.com/datasets/uvalibrary::virginia-cities/explore")
               ),
               tags$li(
                 "Virginia Department of Energy. (2025, January 7). Solar power. Retrieved July 25, 2024, from ",
                 tags$a(href = "https://www.energy.virginia.gov/renewable-energy/SolarPower.shtml", target = "_blank", "https://www.energy.virginia.gov/renewable-energy/SolarPower.shtml")
               ),
               tags$li(
                 "U.S. Environmental Protection Agency. (2024, April 22). Biden-Harris Administration announces $7 billion solar for all grants. Retrieved July 25, 2024, from ",
                 tags$a(href = "https://www.epa.gov/newsreleases/biden-harris-administration-announces-7-billion-solar-all-grants-deliver-residential", target = "_blank", "https://www.epa.gov/newsreleases/biden-harris-administration-announces-7-billion-solar-all-grants-deliver-residential")
               ),
               tags$li(
                 "U.S. Energy Information Administration. (2025, February 20). Virginia: State profile and energy estimates. Retrieved July 25, 2024, from ",
                 tags$a(href = "https://www.eia.gov/state/analysis.php?sid=VA", target = "_blank", "https://www.eia.gov/state/analysis.php?sid=VA")
               ),
               tags$li(
                 "Environment America. (2025, May 8). Virginia among national leaders in solar energy growth. Retrieved July 25, 2024, from ",
                 tags$a(href = "https://environmentamerica.org/virginia/updates/virginia-among-national-leaders-in-solar-energy-growth-data-centers-threaten-progress/", target = "_blank", "https://environmentamerica.org/virginia/updates/virginia-among-national-leaders-in-solar-energy-growth-data-centers-threaten-progress/")
               ),
               tags$li(
                 "Hu, C., Chen, Z., Liu, P., Zhang, W., He, X., & Bosch, D. (2025). Impact of large-scale solar on property values: Evidence from the United States. *Proceedings of the National Academy of Sciences*, 122(24). ",
                 tags$a(href = "https://doi.org/10.1073/pnas.2418414122", target = "_blank", "https://doi.org/10.1073/pnas.2418414122")
               ),
               tags$li(
                 "D'Hose, T., Cougnon, M., De Vliegher, A., Vandecasteele, B., Viaene, N., Cornelis, W., Van Bockstaele, E., & Reheul, D. (2014). The positive relationship between soil quality and crop production: A case study on cover crops in organic farming. *Applied Soil Ecology, 75*, 189–198. ",
                 tags$a(href = "https://doi.org/10.1016/j.apsoil.2013.11.001", target = "_blank", "https://doi.org/10.1016/j.apsoil.2013.11.001")
               ),
               tags$li(
                 "U.S. Geological Survey. (n.d.). USGS.gov | Science for a changing world. Retrieved July 25, 2024, from ",
                 tags$a(href = "https://www.usgs.gov", target = "_blank", "https://www.usgs.gov")
               ),
               tags$li(
                 "Lawrence Berkeley National Laboratory & U.S. Geological Survey. (2025, April). U.S. large-scale solar photovoltaic database (USPVDB). Retrieved July 25, 2024, from ",
                 tags$a(href = "https://energy.usgs.gov/uspvdb/viewer/#3/37.25/-96.25", target = "_blank", "https://energy.usgs.gov/uspvdb/viewer/#3/37.25/-96.25")
               ),
               tags$li(
                 "U.S. Census Bureau. (n.d.). U.S. Census Bureau. Retrieved July 24, 2025, from ",
                 tags$a(href = "https://www.census.gov", target = "_blank", "https://www.census.gov")
               ),
               tags$li(
                 "Virginia Department of Emergency Management, Virginia Geographic Information Network. (n.d.). VGIN. Retrieved July 24, 2025, from ",
                 tags$a(href = "https://vgin.vdem.virginia.gov/", target = "_blank", "https://vgin.vdem.virginia.gov/")
               ),
               tags$li(
                 "U.S. Department of Agriculture. (n.d.). U.S. Department of Agriculture. Retrieved July 24, 2025, from ",
                 tags$a(href = "https://www.usda.gov", target = "_blank", "https://www.usda.gov")
               )
             )
    ),
    
    # JavaScript for rotating arrow
    tags$script(HTML("
    document.addEventListener('DOMContentLoaded', function() {
      const details = document.querySelector('details');
      const arrow = document.querySelector('#citation_arrow');

      if (details && arrow) {
        details.addEventListener('toggle', function() {
          arrow.style.transform = details.open ? 'rotate(90deg)' : 'rotate(0deg)';
        });
      }
    });
  "))
  )
  )