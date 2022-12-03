library(shiny)
source("00_setup.R")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("A-RICK: All-Recipes Ingredient Comparison Kit"),


    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(

          # Description
          helpText("Welcome! This tool is meant to help you compare recipes
                    from AllRecipes.com. When you paste the URLs to recipes
                    you're interested in, it downloads the ingredients from
                    those recipes and lets you compare the quantities
                    side-by-side. Please be aware that it takes a little
                    while to process, so give it some time to do its thing."),
          textAreaInput("urls",
                    "Please enter each recipe URL on separate lines:",
                    value="https://www.allrecipes.com/recipe/221149/chef-johns-chili-chocolate-cookies/\nhttps://www.allrecipes.com/recipe/263749/chef-johns-panettone/",
                    width = "100%",
                    height = "250px")
        ),

        # Display ingredients in a table
        mainPanel(
          dataTableOutput("ingredient_table")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$ingredient_table <- renderDataTable({
      # parse input
      str_split(input$urls, "\n|,") %>%
        unlist() %>%
        map_chr(str_trim) %>%
        parse_urls() %>%
        comparison_table()
    }, options = list(pageLength = 50))
}

# Run the application
shinyApp(ui = ui, server = server)
