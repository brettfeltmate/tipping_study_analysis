# make clean slate
rm(list = ls())

# FIXME: luggage combination
set.seed(12345)

# betteR package manager
if (!requireNamespace("pak")) {
  install.packages("pak")
}

# Loaded within scripts on as-needed basis
packages <- c(
  "data.table", # data manipulation
  "gsignal", # signal filtering
  "ggplot2",
  "patchwork", # multi-plot composites
  "plotly" # 3d plotting
)

# package installation
pak::pak(packages)

# set working directory (OS-agnostic)
here::i_am("r/utilities/workspace.r")

# read in utility files
source(here::here("r", "utilities", "themes.R")) # plot themes
source(here::here("r", "utilities", "functions.R")) # proj-specific functions

# set default plot theme
ggplot2::theme_set(
  # see themes.R for full details
  theme_dark_blue(base_family = "Maple Mono NF", base_size = 12) +
    theme(
      legend.position = "right",
      legend.title.position = "top",
      legend.direction = "vertical"
    )
)
