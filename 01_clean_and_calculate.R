library(tidyverse)
library(janitor)
library(readxl)

#import the data file
orig_data <- read_excel("processed_data/vaccines_AK_June25.xlsx")

#remove the existing calculated fields so we can remake them 
data <- orig_data %>% 
  select(state, kind_pop, nme_perc, year)
