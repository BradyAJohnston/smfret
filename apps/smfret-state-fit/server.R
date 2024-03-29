#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)


transitions <- readRDS("transitions.rds")
# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    cut_transitions <- reactive({
        state_cutoffs <- c(0, input$cutoffs, 1)

        cut_df <- transitions %>%
            # filter(time < 21) %>%
            mutate(
                from = case_when(
                    from > 1 ~ 1,
                    from < 0 ~ 0,
                    TRUE     ~ from
                ),
                to = case_when(
                    to > 1 ~ 1,
                    to < 0 ~ 0,
                    TRUE   ~ to
                ),
                from_cut = cut(from, breaks = state_cutoffs, labels = FALSE),
                to_cut   = cut(to, breaks = state_cutoffs, labels = FALSE)
            ) %>%
            mutate(rna = factor(rna, levels = 0:13))

        cut_df
    })

    bin_states <- reactive({
        cut_transitions() %>%
            filter(from_cut == input$state) %>%
            ungroup() %>%
            mutate(
                time_bin = cut(time, breaks = seq(0, max(ceiling(time)), by = 1), labels = FALSE)
            ) %>%
            group_by(rna, time_bin) %>%
            summarise(n = n()) %>%
            mutate(nn = n / max(n))
    })

    fit_models <- reactive({
        bin_states() %>%
            biochemr::b_dose_resp(time_bin, nn, rna,
                                  .model = drc::EXD.2(names = c("max", "rate")))
    })


    output$plots <- renderPlot({

        fit <- fit_models()

        plt1 <- fit %>%
            filter(rna %in% input$rna_selected) %>%
            biochemr::b_plot() +
            geom_col(aes(dose, resp, fill = rna), alpha = 0.3,
                     data = fit %>%
                         filter(rna %in% input$rna_selected) %>%
                         unnest(data)) +
            facet_grid(rows = vars(rna)) +
            scale_colour_discrete(breaks = 0:13) +
            guides(colour = "none", fill = "none") +
            labs(x = "Time (s)") +
            theme_classic() +
            theme(
                axis.text.y = element_blank(),
                axis.title.y = element_blank(),
                axis.ticks.y = element_blank(),
                strip.text = element_blank(),
                strip.background = element_blank()
            )


        plt2 <- fit %>%
            filter(rna %in% input$rna_selected) %>%
            biochemr::b_plot_coefs(rna, "rate", colour = rna) +
            facet_grid(rows = vars(rna), scales = "free_y") +
            coord_cartesian(xlim = c(0, 10)) +
            guides(colour = "none") +
            scale_colour_discrete(breaks = 0:13) +
            scale_x_continuous(breaks = 0:10) +
            theme(panel.grid.major.y = element_blank(),
                  panel.grid.minor.x = element_blank(),
                  strip.text = element_blank(),
                  strip.background = element_blank())

        cut1 <- input$cutoffs[1]
        cut2 <- input$cutoffs[2]

        plt3 <- cut_transitions() %>%
            filter(rna %in% input$rna_selected) %>%
            ggplot(aes(from, to)) +
            geom_density2d_filled(contour_var = "ndensity", bins = 15) +
            geom_segment(aes(x = x1, xend = x2, y = y1, yend = y2),
                         colour = "white",
                         linetype = "dashed",
                         data = data.frame(
                             x1 = c(cut1, cut2, 0, 0, 0),
                             x2 = c(cut1, cut2, cut1, cut2, 1),
                             y1 = c(0, 0, cut1, cut2, 0),
                             y2 = c(cut1, cut2, cut1, cut2, 1)
                         )) +
            scale_x_continuous(expand = expansion(c(0,0))) +
            scale_y_continuous(expand = expansion(c(0,0))) +
            scale_colour_discrete(breaks = 0:13) +
            theme_light() +
            guides(fill = "none") +
            labs(x = "Before Transition", y = "After Transition") +
            facet_grid(rows = vars(rna)) +
            theme(aspect.ratio = 1)

        patchwork::wrap_plots(plt2, plt1, plt3, nrow = 1)
    }, height = reactive({length(input$rna_selected) * 200}))

})
