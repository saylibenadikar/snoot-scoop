install.packages(c("ggmap", "viridis"))

library(ggmap)
library(viridis)

source("../utility_scripts/data_prep.r")
source("../utility_scripts/annotation_defaults.r")

trials_per_city <- scent_data %>%
  select(state, city, trial) %>%
  mutate(name = paste(city, state, sep=" ")) %>%
  distinct(trial, .keep_all=TRUE) %>%
  group_by(state, city, name) %>%
  summarize(number_of_trials = n()) %>%
  ungroup() %>%
  select(state, city, name, number_of_trials) %>%
  arrange(number_of_trials)

# Limit of ~2K geocode api requests per day, so use cached values where available and only query google apis for the new
# cities since the last time the map was generated
cached_cities_data_lat_lon <- read_csv("cities_data.csv")
cities_data_lat_lon <- trials_per_city %>%
  left_join(cached_cities_data_lat_lon, by="name")
new_cities_data_lat_lon <- cities_data_lat_lon %>%
  filter(is.na(lat))
if (nrow(new_cities_data_lat_lon) > 0) {
  old_cities_data_lat_lon <- cities_data_lat_lon %>%
    filter(!is.na(lat))
  new_cities_data_lat_lon <- cities_data_lat_lon %>%
    filter(is.na(lat)) %>%
    mutate(lat=NULL, lon=NULL) %>%
    mutate_geocode(name)
  cities_data_lat_lon <- bind_rows(old_cities_data_lat_lon, new_cities_data_lat_lon)
  write_csv(cities_data_lat_lon %>% select(name, lat, lon), "cities_data.csv")
} else {
  print("Did not need to query for lat/long of any new cities")
}

plot <- ggmap(get_map(location = "Oklahoma", zoom=4, maptype="terrain", color="color")) +
  #plot <- ggmap(get_map(location = "Hawaii", zoom=4, maptype="roadmap", color="color")) +
  #plot <- ggmap(get_map(location = "Alaska", zoom=4, maptype="terrain", color="color")) +
  geom_point(
    data=cities_data_lat_lon,
    mapping = aes(x=lon, y=lat, size=number_of_trials, fill=number_of_trials), alpha=0.7, shape=21, color="grey35") +
  scale_size_continuous(
    name = "Number of trials",
    trans = "log",
    range=c(0, 10),
    breaks = c(1, 2, 4, 8, 16, 32),
    labels=c("1", "2", "4", "8", "16", "32")) +
  scale_fill_viridis(
    option="turbo",
    name = "Number of trials",
    trans="log",
    breaks=c(1, 2, 4, 8, 16, 32),
    labels=c("1", "2", "4", "8", "16", "32")) +
  guides(fill=guide_legend(), size = guide_legend()) +
  theme_void()  +
  theme(
    legend.position = 'bottom',
    axis.title = element_blank()
  )

annotated_plot <- getAnnotatedPlot(
  plot,
  title="NACSW Trial Location Hubs",
  subtitle="A map showing trial location density across the continental United States")
annotated_plot

ggsave("trial_sites_usa.png", plot=annotated_plot, path=".", width=4194, height=3226, units="px", bg="white")
