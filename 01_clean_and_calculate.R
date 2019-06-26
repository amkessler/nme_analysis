library(tidyverse)
library(janitor)
library(readxl)
library(naniar)

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
write_csv(data_final, "output/method1_data_final.csv")



####  HERE WE'LL USE AN ALTERNATIVE METHOD  ####

#start with the original data file
orig_data 

#remove the existing calculated fields so we can remake them 
method2_data <- orig_data %>% 
  select(state, kind_pop, nme_perc, year)

head(method2_data)

# calculate change in nme pct using dplyr's lag()
method2_data <- method2_data %>% 
  mutate(
    nme_per1000 = nme_perc * 10,
    abs_change = nme_per1000 - lag(nme_per1000),
    relative_change_pct = round_half_up(((nme_per1000 - lag(nme_per1000)) / lag(nme_per1000))*100, 1) 
  )

head(method2_data)

# the above calculated for every row, which we don't want
# we'll remove values for 2014 rows with the naniar package's replace_with_na() 
method2_data_final <- method2_data %>% 
  mutate(
    abs_change = if_else(year==2018, abs_change, 9999),
    relative_change_pct = if_else(year==2018, relative_change_pct, 9999),
    ) %>% 
  naniar::replace_with_na(replace = list(abs_change = 9999,
                                 relative_change_pct = 9999
                                 ))
  

head(method2_data_final)

#save result to file
write_csv(method2_data_final, "output/method2_data_final.csv")