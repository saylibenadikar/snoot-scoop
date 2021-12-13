install.packages(c("statebins", "viridis"))

library(statebins) # https://rpubs.com/sdtanner/Statebin_project
library(viridis)

source("../utility_scripts/data_prep.r")
source("../utility_scripts/annotation_defaults.r")

data <- scent_data %>%
  select(state, trial) %>%
  distinct(trial, .keep_all=TRUE) %>%
  group_by(state) %>%
  summarize(number_of_trials = n()) %>%
  ungroup() %>%
  arrange(desc(number_of_trials))
head(data)

plot <- statebins(
    state_data = data,
    value_col = "number_of_trials",
    ggplot2_scale_function = scale_fill_viridis,
    light_label = "white",
    dark_label = "white",
    font_size = 5,
    round = TRUE) +
  scale_fill_viridis(option="turbo", name="Number of trials") +
  theme_statebins() +
  theme(
    legend.position = 'right',
    legend.text = element_text(size=9, color="black"),
    legend.key.height = unit(1.2, "cm")
  )

annotated_plot <- getAnnotatedPlot(
  plot,
  title="Number of NACSW Trials by State",
  subtitle="State-wise count of all trials since 2009")
annotated_plot

ggsave("trials_across_space_states.png", plot=annotated_plot, path=".", width=4194, height=3226, units="px",
       bg="white")

