methods_tab <- tabPanel("Methods",
                        value = "Methods",
                        fluidPage(
                          tags$h2("Methodology", style = "color: #001f87;"),
                          p("This page details the statistical models and data used to analyze the impact of utility-scale solar facilities (USSFs) on agricultural land values in Virginia."),
                          
                          tabsetPanel(
                            id = "methods_tabs",
                            
                            # ===================================================
                            # FINAL County Level Analysis Tab
                            # ===================================================
                            tabPanel("County Level Analysis",
                                     # Add withMathJax() to ensure all LaTeX renders correctly
                                     withMathJax(),
                                     div(class = "method-section",
                                         h3(tags$strong("Econometric Model"), style = "margin-top: 0;"),
                                         p("To estimate the causal effect of USSFs on the value of agricultural land, we employ a Two-Way Fixed Effects (TWFE) Difference-in-Differences (DiD) model. This approach isolates the impact of solar facility presence by controlling for unobserved, time-invariant county characteristics and statewide temporal trends.")
                                     ),
                                     div(class = "method-section",
                                         h4(tags$strong("Model Specification")),
                                         uiOutput("county_did_equation")
                                     ),
                                     div(class = "method-section",
                                         h4(tags$strong("Variable Definitions")),
                                         # This table is now updated for consistent formatting
                                         tags$table(class = "table table-striped table-hover",
                                                    tags$thead(
                                                      tags$tr(
                                                        tags$th("Variable Name"),
                                                        tags$th("Description"),
                                                        tags$th("Role in Analysis")
                                                      )
                                                    ),
                                                    tags$tbody(
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\log(\\text{Price})\\)")),
                                                        tags$td("The natural log of the average price per acre of agricultural land sold."),
                                                        tags$td("Dependent Variable")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{DiD}\\)")),
                                                        tags$td("Indicator equal to 1 for a county in a year after its first USSF is commissioned."),
                                                        tags$td("Key Independent Variable")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{Population}\\)")),
                                                        tags$td("Total county population."),
                                                        tags$td("Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{TotalHousing}\\)")),
                                                        tags$td("Total number of housing units in the county."),
                                                        tags$td("Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{OccupiedHousing}\\)")),
                                                        tags$td("Number of occupied housing units in the county."),
                                                        tags$td("Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{VacantHousing}\\)")),
                                                        tags$td("Number of vacant housing units in the county."),
                                                        tags$td("Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{AvgHouseAge}\\)")),
                                                        tags$td("Average age of housing units in the county."),
                                                        tags$td("Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{CornYield}\\)")),
                                                        tags$td("County-level corn yield, as a proxy for agricultural land quality."),
                                                        tags$td("Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{SoybeansYield}\\)")),
                                                        tags$td("County-level soybeans yield, as a proxy for agricultural land quality."),
                                                        tags$td("Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("Fixed Effects \\(\\gamma_c, \\delta_t\\)")),
                                                        tags$td("Categorical controls for each county (c) and each year (t) in the dataset."),
                                                        tags$td("Fixed Effects")
                                                      )
                                                    )
                                         )
                                     ),
                                     div(class = "method-section",
                                         h4(tags$strong("Identification Strategy")),
                                         p("The causal effect of interest is captured by the ", withMathJax("\\(\\beta_1\\)"), " coefficient on the DiD term. To ensure robust inference, standard errors are clustered at the county level.")
                                     ),
                                     
                                     hr(),
                                     h3(tags$strong("Data Generation for Control Variables"), style = "margin-top: 20px;"),
                                     p("The control variables listed in the table were compiled from publicly available national datasets."),
                                     div(class = "method-section",
                                         h4(tags$strong("Socioeconomic Data")),
                                         p("Data on county-level population and housing characteristics are sourced from the U.S. Census Bureau's American Community Survey (ACS) 5-Year Estimates. These variables control for demographic shifts and development pressures that influence land prices:"),
                                         tags$ul(
                                           tags$li(tags$strong("Population:"), " Controls for the scale of the local economy and housing demand."),
                                           tags$li(tags$strong("Housing Units (Total, Occupied, Vacant):"), " Control for the state of the local housing market and development pressure."),
                                           tags$li(tags$strong("Average House Age:"), " Indicates the character and age of development in a county.")
                                         )
                                     ),
                                     div(class = "method-section",
                                         h4(tags$strong("Agricultural Data")),
                                         p("To account for differences in land quality, we use data on crop yields for major commodities, provided by the U.S. Department of Agriculture's National Agricultural Statistics Service (USDA NASS)."),
                                         tags$ul(
                                           tags$li(tags$strong("Crop Yields (Corn, Soybeans):"), " Serve as a direct proxy for the intrinsic quality and productivity of agricultural land within the county.")
                                         )
                                     ),
                            ),
                            
                            
                            tabPanel("Parcel Level Analysis",
                                     # Use withMathJax() to ensure all LaTeX renders correctly within this panel
                                     withMathJax(), 
                                     div(class = "method-section",
                                         h3(tags$strong("Econometric Model"), style = "margin-top: 0;"),
                                         p("To more granularly estimate the impact of solar development, we employ a continuous Difference-in-Differences (DiD) model. This model leverages the exact distance from each parcel to the nearest solar facility and the electrical grid, allowing us to see how the impact on land value changes as distance changes. The model includes multiple fixed effects to control for unobserved heterogeneity."),
                                         p("In the model specification below, the subscripts denote the level of observation: ", tags$b("i"), " for an individual parcel, ", tags$b("c"), " for the county, ", tags$b("s"), " for the relevant solar facility, and ", tags$b("t"), " for the transaction year.")
                                     ),
                                     div(class = "method-section",
                                         h4(tags$strong("Model Specification")),
                                         uiOutput("parcel_did_equation")
                                     ),
                                     div(class = "method-section",
                                         h4(tags$strong("Variable Definitions")),
                                         tags$table(class = "table table-striped table-hover",
                                                    tags$thead(
                                                      tags$tr(
                                                        tags$th("Variable Name"),
                                                        tags$th("Description"),
                                                        tags$th("Role in Analysis")
                                                      )
                                                    ),
                                                    tags$tbody(
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\log(\\text{Price per Acre})\\)")),
                                                        tags$td("The natural log of the sale price per acre for an individual parcel."),
                                                        tags$td("Dependent Variable")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\gamma (\\log(\\text{SFDist}) \\times \\text{Post})\\)")),
                                                        tags$td("The interaction between the logged distance to a solar facility and the post-construction period."),
                                                        tags$td("Key Independent Variable")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\phi (\\log(\\text{GridDist}) \\times \\text{Post})\\)")),
                                                        tags$td("The interaction between the logged distance to the electrical grid and the post-construction period."),
                                                        tags$td("Key Independent Variable")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\log(\\text{SFDist})\\)")),
                                                        tags$td("The natural log of the distance from the parcel to the nearest solar facility."),
                                                        tags$td("Main Effect Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\log(\\text{GridDist})\\)")),
                                                        tags$td("The natural log of the distance from the parcel to the nearest electrical grid infrastructure."),
                                                        tags$td("Main Effect Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{Post}\\)")),
                                                        tags$td("An indicator variable equal to 1 for the period after a nearby solar facility is built."),
                                                        tags$td("Main Effect Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{Acres}\\)")),
                                                        tags$td("The size of the individual parcel in acres."),
                                                        tags$td("Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{FlatnessScore}\\)")),
                                                        tags$td("A 0-100 score derived from slope and terrain metrics, where higher is flatter."),
                                                        tags$td("Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{RoadDist}\\)")),
                                                        tags$td("The distance in miles from the parcel to the nearest major road."),
                                                        tags$td("Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{WaterDist}\\)")),
                                                        tags$td("The distance in miles from the parcel to the nearest major water body."),
                                                        tags$td("Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("\\(\\text{UrbanDist}\\)")),
                                                        tags$td("The distance in miles from the parcel to the nearest urban/suburban county."),
                                                        tags$td("Control")
                                                      ),
                                                      tags$tr(
                                                        tags$td(withMathJax("Fixed Effects: \\(\\mu_i\\) (Land Cover), \\(\\lambda_c\\) (County), \\(\\tau_t\\) (Year)")),
                                                        tags$td("Categorical controls included in the model:\n
           • \\(\\mu_i\\): Land cover fixed effect — controls for parcel-level land cover classification (e.g., cropland, pasture).\n
           • \\(\\lambda_c\\): County fixed effect — accounts for unobserved differences across counties (e.g., zoning policies).\n
           • \\(\\tau_t\\): Year fixed effect — captures time-specific effects (e.g., inflation, market shocks)."),
                                                        tags$td("Fixed Effects")
                                                      )
                                                      
                                                    )
                                         )
                                     ),
                                     div(class = "method-section",
                                         h4(tags$strong("Identification Strategy")),
                                         p("The causal effects of interest are captured by the coefficients ", withMathJax("\\(\\gamma\\) and \\(\\phi\\)"), ". A statistically significant ", withMathJax("\\(\\gamma\\)"), " suggests that the price effect of a solar facility's presence depends on a parcel's distance from that facility, after controlling for other factors.")
                                     ),
                                     hr(),
                                     h3(tags$strong("Data Generation for Control Variables"), style = "margin-top: 20px;"),
                                     p("The control variables listed in the table were generated through several geospatial processes."),
                                     div(class = "method-section",
                                         h4(tags$strong("1. Topographic Analysis")),
                                         p("The 'FlatnessScore' is generated by analyzing a high-resolution Digital Elevation Model (DEM). From this model, we calculate several key terrain metrics for each parcel:"),
                                         tags$ul(
                                           tags$li(tags$strong("Mean Slope:"), " The average steepness across the parcel, measured in degrees."),
                                           tags$li(tags$strong("Terrain Ruggedness Index (TRI):"), " A measure of localized elevation variation to identify 'bumpy' terrain."),
                                           tags$li(tags$strong("Topographic Position Index (TPI):"), " Indicates if a parcel is on a hilltop, in a valley, or on a flat plain."),
                                           tags$li(tags$strong("Elevation Standard Deviation:"), " Measures the overall variability in elevation within a single parcel.")
                                         ),
                                         p("These metrics are combined to produce a single score from 0 to 100, where a higher score indicates a flatter, more solar suitable parcel.")
                                     ),
                                     div(class = "method-section",
                                         h4(tags$strong("2. Proximity Analysis")),
                                         p("The various distance metrics are calculated by measuring the straight-line distance from each parcel's boundary to the nearest of the following features:"),
                                         tags$ul(
                                           tags$li(tags$strong("Roads:"), " Proximity to roads is crucial for construction access and maintenance."),
                                           tags$li(tags$strong("Water:"), " Relevant for construction but also an environmental consideration."),
                                           tags$li(tags$strong("Urban Centers:"), " Acts as a proxy for land value pressure and proximity to the electrical grid and workforce.")
                                         )
                                     ),
                                     div(class = "method-section",
                                         h4(tags$strong("3. Land Cover Classification")),
                                         p("To account for land use, we use the USDA Cropland Data Layer (CDL) raster. The process involves:"),
                                         tags$ol(
                                           tags$li(tags$strong("Reclassification:"), " Simplifying the 100+ detailed CDL codes into broad categories (e.g., Agriculture, Forest)."),
                                           tags$li(tags$strong("Zonal Statistics:"), " Identifying the single most common (modal) land cover category for each parcel."),
                                           tags$li(tags$strong("Final Classification:"), " Assigning the modal category to the parcel for use in the model.")
                                         )
                                     )
                            )
                          )
                        )
)