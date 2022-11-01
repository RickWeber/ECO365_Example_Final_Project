rm(list=ls())
source('00_functions.R') # pull in the functions that we know work,
                         # start up the session, and let us get to work

ex_url <- "https://www.allrecipes.com/recipe/143069/super-delicious-zuppa-toscana/"
ex_page <- get_page(ex_url)
ex_list <- get_ingredient_list(ex_page)
ex_quantities <- sapply(ex_list, get_quantity)

units_of_measure <- c(
  "tablespoon", "tablespoons",
  "teaspoon", "teaspoons",
  "cup", "cups", "slices", "slice",
  "pound", "ounce", "lb", "oz",
  "grams", "gram", "kilogram", "kilograms",
  "bunch", "bunches", "large",
  "stalk", "stalks", "can", "cans", "container", "package"
)


parse_ingredient_item <- function(ingredient_list_item){
  # Return a quantity, a unit, and an ingredient
  # Incoming format "3 cups stuff"
  # Output c("3", "cups", "stuff")
  ingredient_list_item = ingredient_list_item %>% tolower
  quantity <- get_quantity(ingredient_list_item)
  tokens <- tokenize_list_item(ingredient_list_item)
  # quantity <- ""
  # for(i in 1:length(tokens)){
  #   token <- tokens[i]
  #   if(token %in% units_of_measure){
  #     unit <- token
  #     ingredient <- tokens[(i+1):length(tokens)]
  #     break
  #   }
  #   quantity <- paste0(quantity, token)
  # }
  if(!exists("ingredient")){
    # print(ingredient_list_item)
    out <- potato_parser(ingredient_list_item)
  } else {
    out <- data.frame(
      quantity = quantity,
      unit = unit,
      ingredient = paste(ingredient, collapse = " ")
    )
  }
  out
}

potato_parser <- function(ingredient_list_item){
  # If we get something like "6 potatoes, sliced/etc."
  unit <- "units"
  tokens <- strsplit(ingredient_list_item, " ") %>% unlist
  quantity <- ""
  for(i in 1:length(tokens)){
    token <- tokens[i]
    if(is.na(as.numeric(token))){ # this might break on 1/3, etc.
      ingredient <- tokens[(i):length(tokens)]
      break
    }
    quantity <- paste0(quantity, token)
  }
  data.frame(
    quantity = quantity,
    unit = unit,
    ingredient = paste(ingredient, collapse = " "))
}

parse_ingredient_list <- function(ingredients){
  map_df(ingredients, parse_ingredient_item) %>%
    arrange(ingredient)
}


# example_item <- get_ingredient_list(example_url)[5]
# example_url %>% get_ingredient_list %>% parse_ingredient_list
