rm(list=ls())
source('00_functions.R')

example_urls <- readLines('example_urls.txt')

ex_table <- parse_urls(example_urls)
ex_comparison <- comparison_table(ex_table)

ex1 <- example_urls[1]
parse_url(ex1)
p1 <- get_page(ex1)
get_ingredient_list(p1)[5]



# orphaned code from Dropbox mis-sync

# stacks recipes' ingredients side by side
multi_recipe_compare <- function(urls_vect){
  pages <- lapply(urls_vect, get_page)
  titles <- lapply(pages, function(p){
    p %>% html_elements("title") %>% html_text()
  })
  ingredients <- lapply(pages, function(p){
    p %>% get_ingredient_list %>% parse_ingredient_list
  })
  out <- tibble(ingredient = character(),
                unit = character(),
                quantity = double())
  for(recipe in 1:length(urls_vect)){
    out <- full_join(out,
                     ingredients[[recipe]],
                     by="ingredient",
                     suffix = c("", paste0("_", titles[[recipe]])))
  }
  out %>% select(-unit, -quantity)
}

# recursively retrieve all recipes linked to from a page
get_from_list <- function(url){
  page <- get_page(url)
  links <- page %>%
    html_elements("a") %>%
    html_attr("href")
  link_pattern <- "https://www.allrecipes.com/recipe/[0-9]+"
  links_index <- links %>%
    grep(pattern=link_pattern)
  recipe_links <- links[links_index]
  pages <- lapply(recipe_links, get_page)
  recipes <- map_df(recipe_links, function(url){
    p <- get_page(url)
    title <- p %>%
      html_elements("title") %>%
      html_text()
    l <- get_ingredient_list(p)
    parse_ingredient_list(l) %>% mutate(title = title, url = url)
  })
  recipes
}

# search for a term
# find out why this isn't working
search_url <- function(search_term){
  search_term <- gsub(" ","+",search_term)
  paste0("https://www.allrecipes.com/search?q=",
         search_term)
}
# get a search page and get any recipes linked to on that page
search <- function(search_term){
  get_from_list(search_url(search_term))
}
