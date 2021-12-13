install.packages(c("ggridges", "viridis"))

library(ggridges)
library(viridis)

source("../utility_scripts/data_prep.r")
source("../utility_scripts/annotation_defaults.r")

nw1l1_data <- scent_data %>%
  filter(level %in% c("NW1", "L1")) %>%
  group_by(level, trial, element, team) %>%
  mutate(total_score = sum(score),
         team_passed = case_when(
           level == "NW1" & total_score == 25 ~ 1,
           level == "NW1" & total_score != 25 ~ 0,
           level == "L1" & total_score == 100 ~ 1,
           level == "L1" & total_score != 100 ~ 0), time=time) %>%
  ungroup()

nw1l1_passing_teams_data <- nw1l1_data %>%
  filter(team_passed == 1)

nw1l1_pass_percentage_data <- nw1l1_data %>%
  group_by(level, trial, element) %>%
  summarize(total_teams = n(), total_passing_teams = sum(team_passed)) %>%
  ungroup() %>%
  group_by(level, element) %>%
  summarize(total_teams = sum(total_teams), total_passing_teams = sum(total_passing_teams)) %>%
  mutate(pass_percentage = 100 * total_passing_teams/total_teams) %>%
  ungroup() %>%
  arrange(level, desc(pass_percentage))
head(nw1l1_pass_percentage_data)

f_container_labels <- data.frame(
  level = c("L1", "NW1"),
  label = c(
    "approx. 50% of L1 teams found the\nContainer hide within 15 seconds",
    "approx. 25% of NW1 teams found the\nContainer hide within 15 seconds"
  )
)

plot1 <- ggplot(data = nw1l1_passing_teams_data, aes(x=time, y=element, fill=element)) +
  stat_density_ridges(
    geom="density_ridges_gradient",
    rel_min_height = 0.02,
    scale = 1,
    calc_ecdf=TRUE,
    quantiles=4,
    quantile_lines=TRUE,
    show.legend = TRUE,
    color="orange") +
  scale_fill_viridis(option="turbo", name="Quantiles", discrete=TRUE) +
  scale_x_continuous(
    breaks = as.duration(c(0, 15, 30, 45, 60, 90, 120, 150, 180)),
    labels = c("0", "15\nsec", "30\nsec", "45\nsec", "1\nmin", "1:30\nmin", "2\nmin", "2:30\nmin", "3\nmin")) +
  facet_wrap(~level) +
  annotate(geom="segment", x=15, y=1.5, xend=120, yend=1.5, size = 0.75, arrow = arrow(angle=10), color="brown") +
  geom_text(
    data= f_container_labels,
    x=125,
    y=1.5,
    aes(label = label),
    hjust = "left",
    family = "mono",
    size=4,
    inherit.aes=FALSE) +
  labs(title = "Time to Find Hide") + #,  subtitle = "Shorter the time the better") +
  theme_minimal()  +
  theme(
    legend.position = 'right',
    axis.title = element_blank(),
  )

plot2 <- ggplot(data= nw1l1_pass_percentage_data) +
  geom_col(mapping=aes(x=pass_percentage, y=element, fill=element), width=0.75) +
  coord_cartesian(xlim=c(0, 100)) +
  scale_fill_viridis(option="turbo", name="Element", discrete=TRUE) +
  scale_x_continuous(
    breaks = c(0, 20, 40, 60, 70, 80, 85, 100),
    labels = c("", "20%", "40%", "60%", "70%", "80%", "85%", "100%")) +
  facet_wrap(~level) +
  labs(title = "Pass Rate") +
  theme_minimal()  +
  theme(
    legend.position = 'right',
    axis.title = element_blank(),
  )

laidout_plot <- (plot_spacer() / plot1 / plot2) +
  plot_layout(heights = c(1, 8, 4), guides="collect")

annotated_plot <- getAnnotatedPlot(
  laidout_plot,
  title="Element Difficulty Compared",
  subtitle="As experienced by L1 and NW1 teams")
annotated_plot

ggsave("element_difficulty_nw1l1.png", plot=annotated_plot, path=".", width=6971, height=2997, units="px",
       bg="white")
