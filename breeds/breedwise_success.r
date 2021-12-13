install.packages("viridis")

library(viridis)

source("../utility_scripts/data_prep.r")
source("../utility_scripts/annotation_defaults.r")

get_breed_percentage_at_level <- function(levels_filter) {
  breed_percentages <- scent_data %>%
    filter(level %in% levels_filter) %>%
    select(breed, team) %>%
    distinct(team, .keep_all=TRUE) %>%
    mutate(total_dogs = n()) %>%
    group_by(breed) %>%
    summarize(number_of_dogs_this_breed = n(), total_dogs = total_dogs) %>%
    ungroup() %>%
    distinct(breed, .keep_all=TRUE) %>%
    mutate(percentage_this_breed = 100 * (number_of_dogs_this_breed / total_dogs)) %>%
    arrange(desc(percentage_this_breed))
}

summit_data <- get_breed_percentage_at_level("Summit") %>%
  select(breed, number_of_dogs_this_breed, percentage_this_breed)
summit_breeds <- summit_data$breed

nw1l1_data <- get_breed_percentage_at_level(c("NW1", "L1")) %>%
  filter(breed %in% summit_breeds) %>%
  select(breed, number_of_dogs_this_breed, percentage_this_breed) %>%
  filter(number_of_dogs_this_breed > 100)

data <- nw1l1_data %>%
  rename(number_of_dogs_this_breed_nw1l1 = number_of_dogs_this_breed,
         percentage_this_breed_nw1l1 = percentage_this_breed) %>%
  left_join(
    summit_data %>%
      rename(number_of_dogs_this_breed_summit = number_of_dogs_this_breed,
             percentage_this_breed_summit = percentage_this_breed, ),
    by="breed") %>%
  mutate(improved_percentage =
           100 * (percentage_this_breed_summit - percentage_this_breed_nw1l1)/percentage_this_breed_nw1l1) %>%
  filter(improved_percentage > 0) %>%
  mutate(percentage_achievers = 100 * number_of_dogs_this_breed_summit / number_of_dogs_this_breed_nw1l1) %>%
  arrange(desc(percentage_achievers)) %>%
  select(breed, number_of_dogs_this_breed_nw1l1, number_of_dogs_this_breed_summit, percentage_achievers)
write_csv(breed_percentage_data, "test.csv")

plot <- ggplot(data=data) +
  geom_col(mapping = aes(
    x = percentage_achievers,
    y = fct_reorder(breed, percentage_achievers, min),
    fill = fct_reorder(breed, percentage_achievers, min))) +
  scale_fill_viridis(option="turbo", name="Breed", discrete=TRUE) +
  coord_cartesian(xlim=c(0,6)) +
  scale_x_continuous(breaks = c(0, 1, 2, 3, 4, 5, 6), labels = c("", "1%", "2%", "3%", "4%", "5%", "6%")) +
  annotate(geom="curve", x=4.1, y=12, xend=4.8, yend =11.7, curvature =-0.6, arrow=arrow(angle=10), size = 0.75,
           color = "orange") +
  annotate(geom="curve", x=3.25, y=11, xend=4.1, yend =10, curvature = 0.1, arrow=arrow(angle=10), size = 0.75,
           color = "orange") +
  annotate(geom="text", x = 4.2, y = 10.4,
           label = paste("4% of all English Springer Spaniels\nthat entered L1/NW1 trials\nmade it to Summit level\n\nAs",
                         "compared to 3.2% of all\nLabrador Retrievers that entered\nL1/NW1 trials"),
           hjust = "left", family = "mono", size = 4) +
  annotate(geom="text", x = 3, y = 4,
           label = paste("The breeds shown are those that:\n(1) had 100+ dogs at the L1/NW1 level and\n(2) had 1+ dog(s)",
                         "at the Summit level and\n(3) rose above other breeds, i.e.\n    showed a net increase in",
                         "proportion of dogs\n    from that breed from L1/NW1 to Summit"),
           hjust = "left", family = "mono", size = 4) +
  theme_minimal() +
  theme(
    text = element_text("mono"),
    legend.position = 'none',
    legend.key.height = unit(1.2, "cm"),
    axis.title = element_blank(),
    axis.text = element_text(size = 9)
  )

annotated_plot <- getAnnotatedPlot(
  plot,
  title="Breed-wise Success",
  subtitle="Percentage of dogs from a given breed that made it to Summit level")
annotated_plot

ggsave("breedwise_success.png", plot=annotated_plot, path=".", width=4194, height=2621, units="px", bg="white")

