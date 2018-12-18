library(magrittr)

load("data_simulation/sed_simulation_mantel_sed_spatial.RData")
mantel_simulations <- mantel_test_results %>% dplyr::mutate(model_id = as.integer(model_id))
load("data_simulation/sed_simulation_model_grid.RData")
mantel_simulations %<>% dplyr::left_join(models_grid[, c("model_id", "model_group")], by = "model_id")
load("data_analysis/mantel_sed_spatial_burial_type.RData")
mantel_burial_type <- mantel_test_results
load("data_analysis/mantel_sed_spatial_burial_construction.RData")
mantel_burial_construction <- mantel_test_results

mantel_burial_type %<>%
  dplyr::mutate(
    context = "burial_type"
  )

mantel_burial_construction %<>%
  dplyr::mutate(
    context = "burial_construction"
  )

mantel_real_world <- rbind(mantel_burial_type, mantel_burial_construction)

library(ggplot2)

variant <- "high equal interaction"
title <- variant %>% gsub(" ", "_", .)
mantel_simulations <- mantel_simulations %>% dplyr::filter(model_group == variant)
mantel_real_world <- mantel_real_world

#### 1 ####

ju1 <- ggplot() +
  geom_hline(
    yintercept = 0,
    colour = "red",
    size = 2
  ) + 
  geom_line(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic,
      group = model_id
    ),
   position = position_nudge(x = -0.25),
    size = 0.2,
    alpha = 0
  ) +
  geom_point(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic
    ),
    position = position_nudge(x = -0.25),
    size = 1,
    alpha = 0
  ) +
  geom_point(
    data = mantel_real_world,
    mapping = aes(
      x = time,
      y = statistic,
      colour = context
    ),
    position = position_nudge(x = -0.25),
    size = 6
  ) +
  geom_line(
    data = mantel_real_world,
    mapping = aes(
      x = time,
      y = statistic,
      colour = context,
      group = context
    ),
    position = position_nudge(x = -0.25),
    size = 0.7
  ) +
  geom_boxplot(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic
    ),
    width = 0.2
  ) +
  geom_dotplot(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic,
      fill = base::cut(
        signif, 
        breaks = c(0, 0.01, 0.05, 0.1, seq(0.2, 1, 0.1)), 
        labels = c("< 0.01", "< 0.05", "< 0.1", rep("> 0.1", 9))
      ),
    ),
    binaxis = "y",
    stackdir = "down",
    position = position_nudge(x = -0.4),
    dotsize = 0.5,
    binpositions = "all",
    method = "histodot",
    binwidth = 0.025,
    alpha = 0
  ) +
  scale_fill_manual(
    name = "Mantel test significance level of simulation runs",
    values = c(
      "< 0.01" = "#800026",
      "< 0.05" = "#e31a1c",
      "< 0.1" = "#fd8d3c",
      "> 0.1" = "white"
    )
  ) +
  scale_colour_manual(
    name = "Real world context",
    values = c(
      "burial_type" = "#0072B2",
      "burial_construction" = "#009E73"
    )
  ) +
  theme_bw() +
  theme(
    legend.position = "bottom",
    axis.text = element_text(size = 15, angle = 45, hjust = 1),
    axis.title = element_text(size = 15),
    strip.text.x = element_text(size = 13),
    legend.title = element_text(size = 15, face = "bold"),
    legend.text = element_text(size = 15),
    legend.box = "vertical"
  ) +
  ylab("Spearman's rank correlation coefficient") +
  xlab("time blocks calBC") +
  ylim(c(-0.6, 0.75))

ju1$layers[[6]] <- NULL

ju1 %>%
  ggsave(
    "figures_plots/sed_simulation/sed_simulation_step_1.jpeg",
    plot = .,
    device = "jpeg",
    scale = 1,
    dpi = 300,
    width = 300, height = 300, units = "mm",
    limitsize = F
  )

#### 2 ####

ju2 <- ggplot() +
  geom_hline(
    yintercept = 0,
    colour = "red",
    size = 2
  ) + 
  geom_line(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic,
      group = model_id
    ),
   position = position_nudge(x = -0.25),
    size = 0.2,
    alpha = 0.2
  ) +
  geom_point(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic
    ),
    position = position_nudge(x = -0.25),
    size = 1
  ) +
  geom_point(
    data = mantel_real_world,
    mapping = aes(
      x = time,
      y = statistic,
      colour = context
    ),
    position = position_nudge(x = -0.25),
    size = 6
  ) +
  geom_line(
    data = mantel_real_world,
    mapping = aes(
      x = time,
      y = statistic,
      colour = context,
      group = context
    ),
    position = position_nudge(x = -0.25),
    size = 0.7
  ) +
  geom_boxplot(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic
    ),
    width = 0.2
  ) +
  geom_dotplot(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic,
      fill = base::cut(
        signif, 
        breaks = c(0, 0.01, 0.05, 0.1, seq(0.2, 1, 0.1)), 
        labels = c("< 0.01", "< 0.05", "< 0.1", rep("> 0.1", 9))
      ),
    ),
    binaxis = "y",
    stackdir = "down",
    position = position_nudge(x = -0.4),
    dotsize = 0.5,
    binpositions = "all",
    method = "histodot",
    binwidth = 0.025,
    alpha = 0
  ) +
  scale_fill_manual(
    name = "Mantel test significance level of simulation runs",
    values = c(
      "< 0.01" = "#800026",
      "< 0.05" = "#e31a1c",
      "< 0.1" = "#fd8d3c",
      "> 0.1" = "white"
    )
  ) +
  scale_colour_manual(
    name = "Real world context",
    values = c(
      "burial_type" = "#0072B2",
      "burial_construction" = "#009E73"
    )
  ) +
  theme_bw() +
  theme(
    legend.position = "bottom",
    axis.text = element_text(size = 15, angle = 45, hjust = 1),
    axis.title = element_text(size = 15),
    strip.text.x = element_text(size = 13),
    legend.title = element_text(size = 15, face = "bold"),
    legend.text = element_text(size = 15),
    legend.box = "vertical"
  ) +
  ylab("Spearman's rank correlation coefficient") +
  xlab("time blocks calBC") +
  ylim(c(-0.6, 0.75))

ju2$layers[[6]] <- NULL

ju2 %>%
  ggsave(
    "figures_plots/sed_simulation/sed_simulation_step_2.jpeg",
    plot = .,
    device = "jpeg",
    scale = 1,
    dpi = 300,
    width = 300, height = 300, units = "mm",
    limitsize = F
  )

#### 3 ####

ju3 <- ggplot() +
  geom_hline(
    yintercept = 0,
    colour = "red",
    size = 2
  ) + 
  geom_line(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic,
      group = model_id
    ),
   position = position_nudge(x = -0.25),
    size = 0.2,
    alpha = 0.2
  ) +
  geom_point(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic
    ),
    position = position_nudge(x = -0.25),
    size = 1
  ) +
  geom_point(
    data = mantel_real_world,
    mapping = aes(
      x = time,
      y = statistic,
      colour = context
    ),
    position = position_nudge(x = -0.25),
    size = 6
  ) +
  geom_line(
    data = mantel_real_world,
    mapping = aes(
      x = time,
      y = statistic,
      colour = context,
      group = context
    ),
    position = position_nudge(x = -0.25),
    size = 0.7
  ) +
  geom_boxplot(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic
    ),
    width = 0.2
  ) +
  geom_dotplot(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic,
      fill = base::cut(
        signif, 
        breaks = c(0, 0.01, 0.05, 0.1, seq(0.2, 1, 0.1)), 
        labels = c("< 0.01", "< 0.05", "< 0.1", rep("> 0.1", 9))
      ),
    ),
    binaxis = "y",
    stackdir = "down",
    position = position_nudge(x = -0.4),
    dotsize = 0.5,
    binpositions = "all",
    method = "histodot",
    binwidth = 0.025,
    alpha = 0
  ) +
  scale_fill_manual(
    name = "Mantel test significance level of simulation runs",
    values = c(
      "< 0.01" = "#800026",
      "< 0.05" = "#e31a1c",
      "< 0.1" = "#fd8d3c",
      "> 0.1" = "white"
    )
  ) +
  scale_colour_manual(
    name = "Real world context",
    values = c(
      "burial_type" = "#0072B2",
      "burial_construction" = "#009E73"
    )
  ) +
  theme_bw() +
  theme(
    legend.position = "bottom",
    axis.text = element_text(size = 15, angle = 45, hjust = 1),
    axis.title = element_text(size = 15),
    strip.text.x = element_text(size = 13),
    legend.title = element_text(size = 15, face = "bold"),
    legend.text = element_text(size = 15),
    legend.box = "vertical"
  ) +
  ylab("Spearman's rank correlation coefficient") +
  xlab("time blocks calBC") +
  ylim(c(-0.6, 0.75))

ju3 %>%
  ggsave(
    "figures_plots/sed_simulation/sed_simulation_step_3.jpeg",
    plot = .,
    device = "jpeg",
    scale = 1,
    dpi = 300,
    width = 300, height = 300, units = "mm",
    limitsize = F
  )

#### 4 ####

ju4 <- ggplot() +
  geom_hline(
    yintercept = 0,
    colour = "red",
    size = 2
  ) + 
  geom_line(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic,
      group = model_id
    ),
   position = position_nudge(x = -0.25),
    size = 0.2,
    alpha = 0.2
  ) +
  geom_point(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic
    ),
    position = position_nudge(x = -0.25),
    size = 1
  ) +
  geom_point(
    data = mantel_real_world,
    mapping = aes(
      x = time,
      y = statistic,
      colour = context
    ),
    position = position_nudge(x = -0.25),
    size = 6
  ) +
  geom_line(
    data = mantel_real_world,
    mapping = aes(
      x = time,
      y = statistic,
      colour = context,
      group = context
    ),
    position = position_nudge(x = -0.25),
    size = 0.7
  ) +
  geom_boxplot(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic
    ),
    width = 0.2
  ) +
  geom_dotplot(
    data = mantel_simulations,
    mapping = aes(
      x = time,
      y = statistic,
      fill = base::cut(
        signif, 
        breaks = c(0, 0.01, 0.05, 0.1, seq(0.2, 1, 0.1)), 
        labels = c("< 0.01", "< 0.05", "< 0.1", rep("> 0.1", 9))
      ),
    ),
    binaxis = "y",
    stackdir = "down",
    position = position_nudge(x = -0.4),
    dotsize = 0.5,
    binpositions = "all",
    method = "histodot",
    binwidth = 0.025
  ) +
  scale_fill_manual(
    name = "Mantel test significance level of simulation runs",
    values = c(
      "< 0.01" = "#800026",
      "< 0.05" = "#e31a1c",
      "< 0.1" = "#fd8d3c",
      "> 0.1" = "white"
    )
  ) +
  scale_colour_manual(
    name = "Real world context",
    values = c(
      "burial_type" = "#0072B2",
      "burial_construction" = "#009E73"
    )
  ) +
  theme_bw() +
  theme(
    legend.position = "bottom",
    axis.text = element_text(size = 15, angle = 45, hjust = 1),
    axis.title = element_text(size = 15),
    strip.text.x = element_text(size = 13),
    legend.title = element_text(size = 15, face = "bold"),
    legend.text = element_text(size = 15),
    legend.box = "vertical"
  ) +
  ylab("Spearman's rank correlation coefficient") +
  xlab("time blocks calBC") +
  ylim(c(-0.6, 0.75))

ju4 %>%
  ggsave(
    "figures_plots/sed_simulation/sed_simulation_step_4.jpeg",
    plot = .,
    device = "jpeg",
    scale = 1,
    dpi = 300,
    width = 300, height = 300, units = "mm",
    limitsize = F
  )

