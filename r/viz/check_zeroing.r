rm(list = ls())

source(here::here("r", "utilities", "workspace.r"))

library(data.table)
library(ggplot2)
library(tidyfun)
library(shiny)

load(file = here::here("data/proc/02_after_smooth.rdata"))

raw_cols <- grep("_x$|_y$|_z$", colnames(dt), value = TRUE)
dt[, (raw_cols) := NULL]

# drop _smooth from smoothed
smoothed_cols <- grep("_smooth$", colnames(dt), value = TRUE)
setnames(dt, smoothed_cols, gsub("_smooth", "", smoothed_cols))

# create columns for zeroed axes
markers <- grep("_(x|y|z)", colnames(dt), value = TRUE)
dt[,
  (paste0(markers, "_zeroed")) := lapply(.SD, \(axis) axis <- axis - axis[1]),
  by = .(trajectory),
  .SDcols = markers
]

# create columns for hand axes, raw and zeroed
markers <- grep("_(x|y|z)", colnames(dt), value = TRUE)
raw <- grep("_(x|y|z)$", markers, value = TRUE)
zeroed <- grep("_zeroed$", markers, value = TRUE)

# average over markers to get hand pos along each axis
invisible(
  lapply(
    c("x", "y", "z"),
    \(axis) {
      # raw, uncentered data
      cols <- grep(paste0("_", axis, "$"), colnames(dt), value = TRUE)
      dt[, paste0("hand_", axis, "_raw") := rowMeans(.SD), .SDcols = cols]
      # centered at zero
      cols <- grep(paste0("_", axis, "_zeroed$"), colnames(dt), value = TRUE)
      dt[, paste0("hand_", axis, "_zeroed") := rowMeans(.SD), .SDcols = cols]
    }
  )
)

dt[, (grep("^m\\d", colnames(dt))) := NULL]

trajectories <- dt[
  frame >= go_frame,
  .(
    hand_x_raw = spline(seq_along(hand_x_raw), hand_x_raw, 1000)$y,
    hand_x_zeroed = spline(seq_along(hand_x_zeroed), hand_x_zeroed, 1000)$y
  ),
  by = .(trajectory, participant, target_loc, distractor_loc, hand_used, side_used)
] |>
  _[,
    .(
      hand_x_raw = hand_x_raw[seq(1, 1000, length.out = 100)],
      hand_x_zeroed = hand_x_zeroed[seq(1, 1000, length.out = 100)]
    ),
    by = .(trajectory, participant, target_loc, distractor_loc, hand_used, side_used)
  ] |>
  _[
    ,
    .(
      hand_x_raw = tfd(list(hand_x_raw)),
      hand_x_zeroed = tfd(list(hand_x_zeroed))
      # hand_x_raw = fifelse(hand_used == "left", list(-hand_x_raw), list(hand_x_raw)),
      # hand_x_zeroed = fifelse(hand_used == "left", list(-hand_x_zeroed), list(hand_x_zeroed)),
    ),
    by = .(trajectory, participant, target_loc, distractor_loc, hand_used, side_used)
  ]

participants <- sort(unique(trajectories$participant))

# plot ui
ui <- fluidPage(
  titlePanel("Trajectories by participant"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "participant", "Select Participant:",
        choices = participants, selected = participants[1]
      ),
    ),
    mainPanel(plotOutput("trajectory_plot", height = "600px"))
  )
)

# plot server
server <- function(input, output, session) {
  filtered_data <- reactive({
    trajectories[participant == input$participant]
  })
  output$trajectory_plot <- renderPlot({
    tf_ggplot(filtered_data(), aes(linetype = target_loc)) +
      geom_line(aes(tf = hand_x_zeroed, colour = "blue"), size = 1, alpha = 0.5) +
      geom_line(aes(tf = hand_x_raw, colour = "yellow"), size = 1, alpha = 0.5) +
      coord_flip() +
      facet_grid(hand_used ~ side_used) +
      labs(
        title = paste("Participant:", input$participant),
        x = "X (mm)", y = "Z (mm)", colour = "Target Location"
      )
  })
}

# Run plot in browser
shinyApp(ui = ui, server = server)
