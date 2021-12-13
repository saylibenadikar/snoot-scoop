install.packages(c("gganimate", "viridis"))

library(gganimate)
library(viridis)

source("../utility_scripts/data_prep.r")
source("../utility_scripts/annotation_defaults.r")

get_breed_percentage_at_level <- function(levels_filter, levels_string, levels_order) {
  breed_percentages <- scent_data %>%
    filter(level %in% levels_filter) %>%
    select(breed, team) %>%
    distinct(team, .keep_all=TRUE) %>%
    mutate(total_dogs = n()) %>%
    group_by(breed) %>%
    summarize(number_of_dogs_this_breed = n(), total_dogs=total_dogs) %>%
    ungroup() %>%
    distinct(breed, .keep_all=TRUE) %>%
    mutate(
      breed_percentage = 100 * number_of_dogs_this_breed / total_dogs,
      level = levels_string,
      levels_order = levels_order) %>%
    arrange(desc(breed_percentage))
}

summit_top_data <- get_breed_percentage_at_level("Summit", "Summit", 5) %>%
  slice_max(breed_percentage, n=5) %>%
  select(breed, level, levels_order, breed_percentage)
summit_top_breeds <- summit_top_data$breed

elite_data <- get_breed_percentage_at_level("Elite", "Elite", 4) %>%
  filter(breed %in% summit_top_breeds) %>%
  select(breed, level, levels_order, breed_percentage)

nw3l3_data <- get_breed_percentage_at_level(c("NW3", "L3"), "L3-NW3", 3) %>%
  filter(breed %in% summit_top_breeds) %>%
  select(breed, level, levels_order, breed_percentage)

nw2l2_data <- get_breed_percentage_at_level(c("NW2", "L2"), "L2-NW2", 2) %>%
  filter(breed %in% summit_top_breeds) %>%
  select(breed, level, levels_order, breed_percentage)

nw1l1_data <- get_breed_percentage_at_level(c("NW1", "L1"), "L1-NW1", 1) %>%
  filter(breed %in% summit_top_breeds) %>%
  select(breed, level, levels_order, breed_percentage)

breed_percentage_data <- bind_rows(
  nw1l1_data,
  nw2l2_data,
  nw3l3_data,
  elite_data,
  summit_top_data) %>%
  mutate(
    breed_order = case_when(
      breed == "Labrador Retriever" ~ 1,
      breed == "Australian Shepherd" ~ 2,
      breed == "Golden Retriever" ~ 3,
      breed == "German Shepherd Dog" ~ 4,
      breed == "Border Collie" ~ 5,
      TRUE ~ 6
    )) %>%
  mutate(breed = str_replace_all(breed, " ", "\n"))
write_csv(breed_percentage_data, "test.csv")

plot <- ggplot(data = breed_percentage_data) +
  geom_col(
    mapping = aes(x = breed_percentage, y = fct_reorder(breed, breed_order, .desc=TRUE), fill = breed),
    color = "grey85",
    width = 0.7) +
  scale_fill_viridis(option="turbo", name="Breed", discrete=TRUE) +
  coord_cartesian(xlim=c(0,15)) +
  scale_x_continuous(
    breaks = c(0, 5, 7, 10, 15),
    labels = c("", "5% of all\ndogs that\nlevel", "7% of all\ndogs that\nlevel", "10% of all\ndogs that\nlevel",
               "15% of all\ndogs that\nlevel")) +
  annotate(geom="curve", x=7, y=5, xend=9.5, yend =4.5, curvature =0.6, arrow=arrow(angle=10), size = 0.75,
           color = "orange") +
  annotate(geom="text", x = 10, y = 4.4,
           label = "Labrador Retrievers grew in proportion from\n7% of all NW1/L1 competing dogs to\n14% of all Summit level dogs",
           hjust = "left", family = "mono", size = 7) +
  annotate(geom="segment", x=5, y=1, xend=9.5, yend = 1, arrow=arrow(angle=10), size = 0.75, color = "orange") +
  annotate(geom="text", x = 10, y = 1,
           label = "The proportion of Border Collies\nremained fairly constant between\n5% and 6% of competing dogs\nacross the levels of competition",
           hjust = "left", family = "mono", size = 7) +
  theme_minimal() +
  theme(
    text = element_text("mono"),
    legend.position = 'none',
    legend.key.height = unit(1.2, "cm"),
    axis.title = element_blank(),
    axis.text = element_text(size = 16),
    plot.title = element_text(size = 24),
    plot.subtitle = element_text(size = 22)
  ) +
  labs(
    title = "Breed Proportions at Various Competition Levels",
    subtitle = 'Competition Level: {closest_state}',
    caption = getCaption()
  ) +
  transition_states(
    fct_reorder(level, levels_order, min),
    transition_length = 2,
    state_length = 1
  ) +
  enter_fade() +
  exit_shrink() +
  ease_aes("sine-in-out")

animation <- animate(annotated_plot, width = 1920, height = 1080, bg="white")
anim_save(filename = "breed_proportions_at_levels.gif", animation = animation, path = ".")
