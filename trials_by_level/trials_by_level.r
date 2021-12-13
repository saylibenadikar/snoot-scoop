install.packages("viridis")

library(viridis)

source("../utility_scripts/data_prep.r")
source("../utility_scripts/annotation_defaults.r")

data <- scent_data %>%
  select(year, level, trial) %>%
  distinct(trial, .keep_all=TRUE)

plot <- ggplot(data = data) +
  geom_bar(
    mapping = aes(y = year, fill = fct_relevel(level, c("L3", "L2", "L1", "Summit", "Elite", "NW3", "NW2", "NW1"))),
    position = "fill") +
  coord_cartesian(ylim=c(2009, 2021)) +
  scale_y_continuous(breaks=seq(2009, 2021, 1)) +
  scale_x_continuous(breaks=seq(0, 1, 0.25), labels=c("", "25%", "50%", "75%", "100%")) +
  scale_fill_viridis(option="turbo", name="Competition\nLevel", discrete=TRUE) +
  theme_void() +
  theme(
    legend.position = 'right',
    axis.title.y = element_blank(),
    axis.text = element_text(size = 9)
  )

annotated_plot <- getAnnotatedPlot(
  plot,
  title="NACSW Trials by Level",
  subtitle="Percentage of trials every year by competition level")
annotated_plot

ggsave("trials_by_level.png", plot=annotated_plot, path=".", width=4194, height=3226, units="px", bg="white")
