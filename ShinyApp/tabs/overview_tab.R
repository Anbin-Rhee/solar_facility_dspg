overview_tab <- tabPanel("Overview",
                         # Part 1: A simple CSS rule that is waiting to be activated.
                         # This rule only works when the page body has the class "overview-full-width".
                         tags$head(
                           tags$style(HTML("
            .overview-full-width .container-fluid {
                max-width: 100% !important;
                padding-left: 40px;
                padding-right: 40px;
            }
        "))
                         ),
                         
                         # Part 2: A self-contained JavaScript snippet.
                         # This script adds/removes the "overview-full-width" class when you switch tabs.
                         tags$script(HTML("
        $(document).on('shown.bs.tab', 'a[data-toggle=\"tab\"]', function(e) {
            // Get the text of the newly shown tab
            var tab_text = $(e.target).text();

            if (tab_text === 'Overview') {
                $('body').addClass('overview-full-width');
            } else {
                $('body').removeClass('overview-full-width');
            }
        });

        // Also check when the app first loads
        $(document).ready(function() {
            var active_tab_text = $('.navbar-nav > li.active > a').text();
            if (active_tab_text === 'Overview') {
                $('body').addClass('overview-full-width');
            }
        });
    ")),
                         
                         # Part 3: Your original tab content. This does not need to change.
                         tags$div(
                           id = "overview-content",
                           tags$h2("Introduction", style = "color: #001f87;"),
                           tags$p("Virginia, founded in 1607, is a state made up of 95 counties and 38 independent cities, and has a unique landscape which is made up of the coastal plain, piedmont, blue ridge mountains, valley and ridge, and the Appalachian plateau. Virginia spans over 42,000 square miles and is known for its colonial history, as well as its agricultural heritage."),
                           tags$p("In 2023, Virginia was ranked as the 9th largest producer of solar energy in the US. Virginia also gets 5% of its energy from solar (Virginia Department of Energy). The development of utility-scale facilities presents an important step towards green energy, in the fight against climate change."),
                           
                           tags$h2("Rise of Solar Development in Virginia", style = "color: #001f87;"),
                           tags$p("Utility-scale solar facilities consist of arrays of solar panels; each composed of individual photovoltaic cells. The individual photovoltaic cells collect direct current energy from the sun, which is then converted into alternating current energy and delivered to a local power grid. Under the Biden administration green energy solutions were pushed heavily and $7 billion dollars in grants were allocated through the Solar for All Grant to deliver residential solar energy to 900,000 households (EPA). Even further, the state of Virginia has been pushing towards carbon-neutrality and is working towards using 100% carbon free energy sources by 2050 (Virginia Department of Energy). Both of these efforts have led to an expansion in utility scale solar facility development, and in 2024 the state of Virginia created enough solar energy to power nearly 750,000 average households (Environment America). While this development of solar energy has been beneficial in some cases, local farmers are grappling over whether or not it affects agrarian land values in the state."),
                           
                           tags$h2("Research Questions", style = "color: #001f87;"),
                           tags$p("1. What is the effect of utility-scale solar facility (USSF) implementation on agricultural land values at the county level in Virginia?"),
                           tags$p("2. What is the impact of utility-scale solar facilities (USSF) on the market value of nearby agricultural properties in Virginia?")
                         )
)