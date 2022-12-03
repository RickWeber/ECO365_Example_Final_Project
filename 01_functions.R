units_of_measure <- c(
  "tablespoon", "tablespoons",
  "teaspoon", "teaspoons",
  "cup", "cups", "slices", "slice",
  "pound", "ounce", "lb", "oz", "pounds",
  "ounces", #"egg", "eggs", "egg,", "eggs,",
  "grams", "gram", "kilogram", "kilograms",
  "bunch", "bunches", "large", "medium", "small",
  "stalk", "stalks", "can", "cans", "container", "package", "packages"
)
# scrape a specific page
get_page <- function(url){
  nod(session, url) %>%
    scrape()
}
# pull the ingredient list from a specific page
get_ingredient_list <- function(page){
  page %>%
    html_elements(".mntl-structured-ingredients__list") %>%
    html_text2 %>%
    strsplit("\n\n") %>%
    unlist
}
# convert fraction characters to numerics
convert_fraction <- function(num){
  if(!is.character(num)){
    num <- as.character(num)
  }
  ind <- utf8ToInt(num) %>% as.character
  if(length(ind) > 1){
    return(as.numeric(num))
  }
  fraction_codes <- list(
    "188" = 1/4, "189" = 1/2, "190" = 3/4, "8528" = 1/7, "8529" = 1/9,
    "8530" = 1/10, "8531" = 1/3, "8532" = 2/3, "8533" = 1/5, "8534" = 2/5,
    "8535" = 3/5, "8536" = 4/5, "8537" = 1/6, "8538" = 5/6, "8539" = 1/8,
    "8540" = 3/8, "8541" = 5/8, "8542" = 7/8
  )
  ifelse(!is.null(fraction_codes[[ind]]),
         fraction_codes[[ind]],
         as.numeric(num))
}
# convenience wrapper
tokenize_list_item <- function(ingredient_list_item){
  strsplit(ingredient_list_item, " ") %>% unlist
}
# extract the quantity from a list item
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
    left <- tokens[as.numeric(tokens) %in% 1:10000]
    if(length(left) > 0){
      left <- left %>% sapply(as.numeric)
    } else {
      left <- 0
    }
  }
  sum(left)
}

# extract ingredient name from list item
get_name <- function(ingredient_list_item){
  tokens <- tokenize_list_item(ingredient_list_item)
  unit_index <- which(tokens %in% units_of_measure)
  if(length(unit_index) < 1){
    unit_index <- 1
  }
  right <- tokens[(unit_index + 1):length(tokens)]
  right %>% paste(collapse = " ")
}
# special parser for ingredients involving cans
can_parser <- function(ingredient_list_item){
  # If the ingredient_list_item has "can" or "cans" in it,
  # look for the size of the can in parentheses between the quantity and the
  # word "can"
  tokens <- tokenize_list_item(tolower(ingredient_list_item))
  if(!str_detect(tokens, "^can[s)]*")){
    return(ingredient_list_item)
  }
  can_size <- str_extract(ingredient_list_item, "\\(.*\\)")
  unit_index <- which(tokens %in% units_of_measure)
  paste(can_size, tokens[unit_index])
}
# extract ingredient quantity unit
get_unit <- function(ingredient_list_item){
  # check if can is there, if so return call to `can_parser`
  can_unit <- can_parser(ingredient_list_item)
  if(can_unit != ingredient_list_item){
    return(can_unit)
  }
  # if there's no can...
  tokens <- tokenize_list_item(ingredient_list_item)
  unit_index <- which(tokens %in% units_of_measure)
  # Should also get anything to the left that isn't captured by get_quantity.
  if(length(unit_index) > 0){
    out <- tokens[unit_index] %>% paste(collapse = " ")
  } else {
    out <- "units"
  }
  out
}
# put it all together for an individual ingredient
parse_ingredient_item <- function(ingredient_list_item){
  tibble(
    ingredient = get_name(ingredient_list_item),
    unit = get_unit(ingredient_list_item),
    quantity = get_quantity(ingredient_list_item)
  )
}
# apply it to a complete list of ingredients
parse_ingredient_list <- function(ingredient_list){
  map_df(ingredient_list, parse_ingredient_item) %>%
    arrange(ingredient) # I might not want to discard the order...
}
# get a recipe's title
get_title <- function(page){
  page %>%
    html_elements("title") %>%
    html_text()
}
# apply it to a bare url
parse_url <- function(url){
  p <- get_page(url)
  p %>%
    get_ingredient_list %>%
    parse_ingredient_list %>%
    mutate(recipe = get_title(p))
}
# get many urls
parse_urls <- function(url_list){
  map_df(url_list, parse_url)
}
# ingredient table
comparison_table <- function(ingredient_table){
  ingredient_table %>%
    pivot_wider(
      names_from = recipe,
      values_from = quantity
    )
}
# handle partial urls
partial_url <- function(url_string){
 url_base <- "https://www.allrecipes.com/recipe/"
 # if it ain't broke...
 if(substr(tolower(url_string), 1, nchar(url_base)) == url_base){
   return(url_string)
 }
 if(substr(url_string, 1, 1) == "/"){ # drop leading /
   url_string <- substr(url_string, 2, nchar(url_string))
 }
 paste0(url_base, url_string)
}

