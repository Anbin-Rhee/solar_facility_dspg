results_tab <- tabPanel("Results",
                        value = "Results",
                        fluidPage(
                          tags$h2("Model Results", style = "color: #001f87;"),
                          p("This page presents the results from the econometric models detailed in the Methods tab. The tables show the estimated coefficients, standard errors, and significance levels for the key variables of interest."),
                          
                          tabsetPanel(
                            id = "results_tabs",
                            
                            # --- County Level Results Sub-Tab ---
                            tabPanel("County Level Results",
                                     # Add withMathJax to render the hypotheses correctly
                                     withMathJax(),
                                     div(class = "method-section",
                                         h3(tags$strong("County-Level DiD Model Results")),
                                         p("The table below shows the estimated effect of a solar facility's presence on the average price of agricultural land in a county. The other variables (Population, Housing, etc.) are included as controls to isolate the main effect."),
                                         
                                         # This will display the regression table from the server
                                         uiOutput("county_results_table"),
                                         
                                         hr(),
                                         h4(tags$strong("Interpreting the Results")),
                                         p("The analysis reveals several key findings about the impact of solar facilities on county-level agricultural land prices:"),
                                         tags$ul(
                                           tags$li(
                                             tags$strong("No Statistically Significant Effect: "), "The primary finding from both the simple and full models is that the 'DiD' coefficient is statistically insignificant. In the full model (Table 1b), the coefficient is -0.027, but we cannot confidently conclude this effect is different from zero due to its high p-value. This suggests there is no statistical evidence of a widespread, county-level impact on land prices."
                                           ),
                                           tags$li(
                                             tags$strong("Robust and Stable Results: "), "The main finding is highly robust. The 'DiD' coefficient remains small and insignificant even after adding numerous demographic and agricultural control variables. Furthermore, the Adjusted R-squared decreases slightly in the full model, indicating that these controls add little explanatory power and do not alter the core conclusion."
                                           ),
                                           tags$li(
                                             tags$strong("Role of Fixed Effects: "), "The model's relatively high R-squared value (around 37-38%) is driven almost entirely by the powerful county and year fixed effects. These effects control for baseline differences between counties and broad economic trends over time, which are the main sources of variation in land prices in this model."
                                           ),
                                           tags$li(
                                             tags$strong("Hypothesis Test Conclusion: "), 
                                             "Given the statistically insignificant result, ",
                                             tags$strong("we fail to reject our null hypothesis"),
                                             ". The formal hypotheses for the key coefficient are:",
                                             tags$ul(
                                               style = "margin-top: 10px;", # Adds a little space
                                               tags$li(withMathJax("Null Hypothesis \\(H_0: \\beta_{\\text{DiD}} = 0\\): The presence of a solar facility has no effect on average county-level agricultural land values.")),
                                               tags$li(withMathJax("Alternative Hypothesis \\(H_a: \\beta_{\\text{DiD}} \\neq 0\\): The presence of a solar facility has a non-zero effect on average county-level agricultural land values."))
                                             )
                                           )
                                         )
                                     )
                            ),
                            # --- Parcel Level Results Sub-Tab ---
                            tabPanel("Parcel Level Results",
                                     div(class = "method-section",
                                         h3(tags$strong("Parcel-Level Continuous DiD Model Results")),
                                         p("This table displays the results from the more advanced continuous interaction model. This model tests whether the impact of a solar facility on land value changes depending on a parcel's specific distance from the facility and from the electrical grid."),
                                         
                                         # This will display the regression table from the server
                                         uiOutput("parcel_results_table"),
                                         
                                         hr(),
                                         uiOutput("parcel_interpretation_output")
                                     )
                            )
                          )
                        )
)
