# All Recipes ingredient comparison tool


## What it is
This project uses the `rvest` library to scrape recipe ingredients from
AllRecipes.com and allow the user to compare the ingredients of different
recipes. 

The Shiny app takes a list of urls (it only works with AllRecipes.com so far)
and creates a sortable table of ingredients allowing for side-by-side
comparisons of the ingredients used in different ingredients. For example, by
including different recipes for apple cake, you can get an idea of the typical
ratios (e.g. the ratio of flour to eggs) and avoid getting unexpected results
by using weird recipes.

## How to use it
Either run the Shiny app on your own computer (using `arr.R` in the `allRecipes`
subfolder), or at [ShinyApps.io](https://rickweber.shinyapps.io/allRecipes/).
Paste in the urls of different recipes on AllRecipes.com (each on a separate
line), give the computer a few seconds to fetch and process the data, and when
it's done, you'll have a table of ingredients where each column represents one
of your chosen recipes and each row represents a particular ingredient.

## Rough Edges
This project is just a starting point. Here are some of the issues I would like
to solve in the future:

1. Allow the user to enter a search term and have the app pull the top search
   results directly from AllRecipes without having to copy individual URLs. 
2. Standardize ingredient names so that it's easy to compare "3 onions, diced"
   in one recipe with "1 diced onion" in another. Right now, this is the biggest
   sticking point with this version, but fixing it will involve lots of little
   fiddly bits of code.
3. And of course it would be nice if it worked for other recipe websites as
   well. 
   

## Where to find the code and app
You can find the code in this repository and use the tool via this [Shiny app](https://rickweber.shinyapps.io/allRecipes/).


