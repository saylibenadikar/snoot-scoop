install.packages("viridis")

library(viridis)

source("../utility_scripts/data_prep.r")
source("../utility_scripts/annotation_defaults.r")

# Top 10 popular names from all of time
all_time_top_names_data <- scent_data %>%
  select(dog_name, team) %>%
  distinct(team, .keep_all=TRUE) %>%
  group_by(dog_name) %>%
  summarize(number_of_dogs = n()) %>%
  ungroup() %>%
  slice_max(number_of_dogs, n=10)

plot1 <- ggplot(data=all_time_top_names_data) +
  geom_col(mapping = aes(y = fct_reorder(dog_name, number_of_dogs), x = number_of_dogs, fill = number_of_dogs)) +
  scale_fill_viridis(option="turbo") +
  scale_x_continuous(
    labels=c("", "20 dogs", "40 dogs", "50 dogs", "60 dogs", "75 dogs"),
    breaks = c(0, 20, 40, 50, 60, 75)) +
  ggtitle('All Time Popular Names') +
  theme_minimal()  +
  theme(
    legend.position = 'none',
    axis.title = element_blank()
  )

year_wise_top_names_data <- scent_data %>%
  select(year, dog_name, team) %>%
  group_by(year, dog_name) %>%
  distinct(team, .keep_all=TRUE) %>%
  summarize(number_of_dogs_this_name = n()) %>%
  slice_max(number_of_dogs_this_name, n=1) %>%
  ungroup() %>%
  arrange(year, desc(number_of_dogs_this_name))

all_time_top_names <- all_time_top_names_data$dog_name
year_wise_top_names <- unique(year_wise_top_names_data$dog_name)
popular_names <- unique(c(all_time_top_names, year_wise_top_names))

name_trends_data <- scent_data %>%
  filter(dog_name %in% popular_names) %>%
  group_by(year, dog_name) %>%
  distinct(team, .keep_all=TRUE) %>%
  summarize(number_of_dogs = n()) %>%
  ungroup()

plot2 <- ggplot(data = name_trends_data, mapping = aes(x = year, y = number_of_dogs)) +
  geom_line() +
  scale_x_continuous(breaks = seq(2009, 2021, 2)) +
  scale_y_continuous(breaks = seq(0, 40, 20)) +
  #scale_color_viridis(option="cividis", discrete = TRUE) +
  facet_wrap(~dog_name) +
  ggtitle("Trends In Popular Names") +
  theme_minimal()  +
  theme(
    legend.position = 'none',
    axis.title = element_blank()
  )

annotated_plot <- getAnnotatedPlot(
  plot1 / plot2,
  title="Popular Dog Names",
  subtitle="")
annotated_plot

ggsave("popular_names.png", plot=annotated_plot, path=".", width=4194, height=3226, units="px", bg="white")
