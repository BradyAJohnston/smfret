#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    theme = shinythemes::shinytheme("cosmo"),

    # Application title
    titlePanel("Fitting State Decays to PPR Data"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(width = 3,

                sliderInput("cutoffs", label = "State Cutoffs",
                            min = 0, max = 1, value = c(0.49,0.7), 0.01),
                radioButtons("state", label = "State to Fit", choices = 1:3),
                selectInput("rna_selected", label = "RNA RDP", choices = 0:13,
                            selected = 1,
                            multiple = TRUE)
            ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("plots")
        )
    )
))
