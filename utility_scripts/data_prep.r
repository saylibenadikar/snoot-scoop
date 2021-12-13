install.packages(c("janitor", "lubridate", "tidyverse"))

library(janitor)
library(lubridate)
library(tidyverse) # `dplyr`, `ggplot2`, `tidyr`

# Import the data
scent_imported_data = read_csv("../data/nacsw_nw1_nw2_nw3_elite_summit_L123.csv")

# Clean the data and add some columns
scent_data <- scent_imported_data %>%  
  clean_names() %>%
  replace_na(list(breed = "Other: Unknown")) %>%
  mutate(breed = str_to_title(str_squish(breed))) %>%
  mutate(handler_name = str_to_title(str_squish(handler_name))) %>%
  mutate(dog_name = str_to_title(str_squish(dog_name))) %>%
  mutate(team = paste(str_replace_all(dog_name, " ", ""), sep="-", str_replace_all(handler_name, " ", ""))) %>%
  mutate(date = ymd(date)) %>%
  mutate(year = year(date), month = month(date, label=TRUE)) %>%
  mutate(time = dseconds(time)) %>%
  mutate(trial = ifelse(level %in% c("L1", "L2", "L3"), paste(date, city, state, level, element, sep="-"), paste(date, city, state, level, sep="-")))
    
# Examine the data
glimpse(scent_data)
head(scent_data)
tail(scent_data)