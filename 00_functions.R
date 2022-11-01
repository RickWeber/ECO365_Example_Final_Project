library(tidyverse)
library(rvest)
library(polite)

# set up session to politely scrape their site.
# probably overkill, but might as well practice being a nice Internet denizen.
session <- bow("https://www.allrecipes.com", force = TRUE)

get_page <- function(url){
  nod(session, url) %>%
    scrape()
}

get_ingredient_list <- function(page){
    page %>%
    html_elements(".mntl-structured-ingredients__list") %>%
    html_text2 %>%
    strsplit("\n\n") %>%
    unlist
}

convert_fraction <- function(num){
  if(!is.character(num)){
    num <- as.character(num)
  }
  ind <- utf8ToInt(num) %>% as.character
  if(length(ind) > 1){
    return(as.numeric(num))
  }
  fraction_codes <- list(
    "188" = 1/4,
    "189" = 1/2,
    "190" = 3/4,
    "8528" = 1/7,
    "8529" = 1/9,
    "8530" = 1/10,
    "8531" = 1/3,
    "8532" = 2/3,
    "8533" = 1/5,
    "8534" = 2/5,
    "8535" = 3/5,
    "8536" = 4/5,
    "8537" = 1/6,
    "8538" = 5/6,
    "8539" = 1/8,
    "8540" = 3/8,
    "8541" = 5/8,
    "8542" = 7/8
  )
  ifelse(!is.null(fraction_codes[[ind]]),
         fraction_codes[[ind]],
         as.numeric(num))
}

tokenize_list_item <- function(ingredient_list_item){
  strsplit(ingredient_list_item, " ") %>% unlist
}

get_quantity <- function(ingredient_list_item){
  tokens <- tokenize_list_item(ingredient_list_item)
  any_fractions <- "UTF-8" %in% sapply(tokens, function(x){
    as.character(x) %>% Encoding
  })
  if(any_fractions){
    # grab the fraction plus anything to the left
    first_frac <- which(sapply(tokens, function(x){
      (as.character(x) %>% Encoding) == "UTF-8"
    }))
    left <- tokens[1:first_frac] %>%
      sapply(convert_fraction)
  } else {
    left <- tokens[as.numeric(tokens) %in% 1:10000] %>% # That should cover a wide range of options... for now.
      sapply(as.numeric)
  }
  sum(left)
}
