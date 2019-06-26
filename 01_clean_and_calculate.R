library(tidyverse)
library(janitor)
library(readxl)

#import the data file
orig_data <- read_excel("processed_data/vaccines_AK_June25.xlsx")

#remove the existing calculated fields so we can remake them 
data <- orig_data %>% 
  select(state, nme_perc, year)

head(data)

#reshape to put nme pcts going across for each state
data <- data %>% 
  spread(year, nme_perc) %>% 
  clean_names()

head(data)

#calculate fields for per 1000 from raw pct, absolute and relative change
data_final <- data %>% 
  mutate(
    nme_2014_per1000 = x2014 * 10,
    nme_2018_per1000 = x2018 * 10,
    absolute_change = nme_2018_per1000 - nme_2014_per1000,
    relative_change_pct = round_half_up((absolute_change/nme_2014_per1000)*100, 1)
  )

head(data_final)

#save result to file
write_csv(data_final, "output/data_final.csv")