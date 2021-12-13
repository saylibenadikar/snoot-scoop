install.packages(c("ggfittext", "statebins", "viridis"))

library(ggfittext)
library(statebins)
library(viridis) 	

source("../utility_scripts/data_prep.r")
source("../utility_scripts/annotation_defaults.r")

data <- scent_data %>%
  select(year, month, trial) %>%
  distinct(trial, .keep_all=TRUE) %>%
  group_by(year, month) %>%
  summarize(number_of_trials = n()) %>%
  ungroup() %>%
  arrange(desc(number_of_trials))
head(data)  

plot <- ggplot(
  data=data, mapping=aes(x=year, y=month, fill=number_of_trials, label = number_of_trials)) + 
  geom_tile() +
  geom_fit_text(contrast=TRUE) +
  scale_fill_viridis(option="turbo", name="Number\nof\ntrials") +
  scale_x_continuous(breaks=seq(2009, 2021, 1)) +
  theme_statebins() + 
  theme(
    legend.position = 'right',
    legend.key.height = unit(1.2, "cm"),
    axis.title.x = element_blank(),
    axis.text = element_text(size = 12)
  )
  
annotated_plot <- getAnnotatedPlot(plot, 
  title="Number of NACSW Trials over Time", 
  subtitle="Trends in trial count over years, seasons and through a pandemic")
  
annotated_plot

ggsave("trials_over_time.png", plot=annotated_plot, path=".", width=4194, height=3226, units="px", bg="white")
