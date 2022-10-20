library(tidyverse)
library(rvest)

example_url <- "https://www.allrecipes.com/recipe/143069/super-delicious-zuppa-toscana/"

get_ingredient_list <- function(url){
  read_html(url) %>%
    html_elements(".mntl-structured-ingredients__list") %>%
    html_text2 %>%
    strsplit("\n\n") %>%
    unlist
}

parse_ingredient_list <- function(ingredients){

}
