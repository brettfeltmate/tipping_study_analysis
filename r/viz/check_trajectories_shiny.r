rm(list = ls())

source(here::here("r", "utilities", "workspace.r"))
load(file = here::here("data", "proc", "02_out.rdata"))

library(data.table)
library(shiny)
library(ggplot2)

# Get unique participants for dropdown
participants <- sort(unique(dt$participant))

# plot ui
ui <- fluidPage(
  titlePanel("Trajectories by participant"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "participant",
        "Select Participant:",
        choices = participants,
        selected = participants[1]
      ),
      hr(),
      h4("Plot Information"),
    ),
    mainPanel(
      plotOutput("trajectory_plot", height = "600px")
    )
  )
)

# plot server
server <- function(input, output, session) {
  # Reactive data filtered by selected participant
  filtered_data <- reactive({
    dt[participant == input$participant]
  })
  # Create the plot
  output$trajectory_plot <- renderPlot({
    ggplot(
      filtered_data(),
      aes(y = hand_z_zeroed, colour = target_loc)
    ) +
      geom_path(aes(x = hand_x_zeroed), alpha = 0.5) +
      scale_x_continuous(limits = c(-300, 300)) +
      # scale_y_continuous(limits = c(0, 350)) +
      facet_grid(hand_used ~ side_used) +
      labs(
        title = paste("Participant:", input$participant),
        x = "X (mm)", y = "Z (mm)",
        colour = "Target Location"
      )
  })
}

# Run plot in browser
shinyApp(ui = ui, server = server)
