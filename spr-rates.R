library(tidyverse)

spr_data <- readr::read_csv("~/Dropbox/BondLab/Data/SPR/fitted-data.csv")[1:13, 1:14]

theme_set(theme_light())

t2_plot <- spr_data %>%
  mutate(rna = str_extract(rna, "\\d+"),
         rna = as.numeric(rna)) %>%
  ggplot(aes(t2, rna)) +
  geom_errorbar(aes(xmin = t2 - t2.err, xmax = t2 + t2.err)) +
  geom_point() +
  scale_y_continuous(breaks = 1:13) +
  scale_x_log10()

t1_plot <- spr_data %>%
  mutate(rna = str_extract(rna, "\\d+"),
         rna = as.numeric(rna)) %>%
  ggplot(aes(t1, rna)) +
  geom_errorbar(aes(xmin = t1 - t1.err, xmax = t1 + t1.err)) +
  geom_point() +
  scale_y_continuous(breaks = 1:13) +
  xlim(c(0,NA))

patchwork::wrap_plots(
  t1_plot + labs(x = "Half Life (s)",
                 y = "RNA Sample",
                 title = "t1 (Linear x Axis)"),
  t2_plot +
    labs(x = "Half Life (s)",
         y = "RNA Sample",
         title = "t2 (Log x Axis)")
  ) +
  patchwork::plot_annotation(title = "Half Life of Both Fitted Decays.")

