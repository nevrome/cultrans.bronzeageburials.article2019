library(magrittr)

load("data_simulation/sed_simulation_regions_timeslices_spatial_distance.RData")
sed_simulation <- sed_spatial_distance
load("data_analysis/squared_euclidian_distance_over_timeblocks_burial_type.RData")
sed_burial_type <- sed_spatial_distance %>% dplyr::mutate(model_group = "burial_type")
load("data_analysis/squared_euclidian_distance_over_timeblocks_burial_construction.RData")
sed_burial_construction <- sed_spatial_distance %>% dplyr::mutate(model_group = "burial_construction")

sed_all <- sed_simulation %>%
  dplyr::select(-model_id) %>%
  rbind(sed_burial_type) %>%
  rbind(sed_burial_construction)

sed_all <- sed_all %>%
  dplyr::filter(mean_sed != 0)

#print(sed_all)

library(ggplot2)
plu <- ggplot(sed_all) +
  geom_boxplot(
    mapping = aes(
      x = as.factor(distance),
      y = mean_sed,
      fill = model_group
    ),
    width = 0.9
  ) +
  facet_wrap(
    nrow = 2,
    ~time
  ) +
  scale_fill_manual(
    name = "Real world context",
    values = c(
      "burial_type" = "#0072B2",
      "burial_construction" = "#009E73",
      "low equal interaction" = "#fb9a99",
      "low spatial interaction" = "#ffff33",
      "high equal interaction" = "#e31a1c",
      "high spatial interaction" = "#ff7f00"
    )
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(size = 30, face = "bold"),
    legend.position = "bottom",
    legend.title = element_text(size = 20, face = "bold"),
    legend.text = element_text(size = 20),
    strip.text.x = element_text(size = 20),
    axis.text = element_text(size = 20),
    axis.title = element_text(size = 20)
  ) +
  guides(
    fill = guide_legend(nrow = 3, byrow = TRUE)
  ) +
  xlab("Spatial Distance Classes") +
  ylab("Squared Euclidian Distance") +
  ylim(0, 2) +
  NULL

plu %>%
  ggsave(
    "figures_plots/sed_simulation/squared_euclidian_distance_vs_spatial_distance_sim_multiple.jpeg",
    plot = .,
    device = "jpeg",
    scale = 1,
    dpi = 300,
    width = 550, height = 280, units = "mm",
    limitsize = F
  )
  
