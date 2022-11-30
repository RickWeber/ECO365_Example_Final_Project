# load libraries
library(tidyverse)
library(rvest)
library(polite)
# start session
session <- bow('https://www.allredcipes.com', force = TRUE)
# load functions
source('01_functions.R')
#
