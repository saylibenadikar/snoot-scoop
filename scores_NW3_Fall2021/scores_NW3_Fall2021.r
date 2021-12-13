install.packages("viridis")

library(viridis)

source("../utility_scripts/data_prep.r")
source("../utility_scripts/annotation_defaults.r")

data <- scent_data %>%
  filter(date >= "2021-09-22", date <= "2021-12-21", level == "NW3") %>%
  mutate(trial = str_replace(trial, "-NW3", "")) %>%
  group_by(year, state, date, trial) %>%
  mutate(number_teams = n()/4) %>%
  ungroup() %>%
  group_by(year, state, date, trial, team, number_teams) %>%
  summarize(total_score = sum(score)) %>%
  mutate(total_score = if_else(total_score < 0, 0, total_score)) %>%
  ungroup() %>%
  arrange(desc(number_teams))
head(data)

plot <- ggplot(data=data, mapping=aes(x=total_score, fill=..x..)) +
  geom_histogram(binwidth=25) +
  scale_x_continuous(
    breaks = c(0, 25, 50, 75, 100),
    labels = c("0", "25", "50", "75", "100\npoints")) +
  scale_y_continuous(
    breaks = c(0, 10, 20, 30),
    labels = c("", "10", "20", "30 teams")) +
  scale_fill_gradient(low="red", high="forestgreen") +
  facet_wrap(~trial) +
  theme_minimal()  +
  theme(
    legend.position = 'none',
    axis.title = element_blank(),
  )

annotated_plot <- getAnnotatedPlot(
  plot,
  title = 'NW3 Trial Scores - Fall 2021',
  subtitle = 'Distribution of scores at each NW3 trial hosted in Fall 2021')
annotated_plot

ggsave("scores_NW3_Fall2021.png", plot=annotated_plot, path=".", width=5274, height=2673, units="px", bg="white")
