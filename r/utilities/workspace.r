# make clean slate
rm(list = ls())

# FIXME: luggage combination
set.seed(12345)

# Loaded within scripts on as-needed basis
packages <- c(
  "data.table",
  "emmeans", # post-hocs
  # "gsignal", # signal filtering
  "ggplot2",
  "ggthemes",
  # "mgcv",
  "patchwork", # plot composites
  "plotly", # 3d plotting
  "refund", # model functional data
  "tidyfun" # wrangle functional data
)

# # package manager (handles deps better)
# if (!requireNamespace("pak")) {
#   install.packages("pak")
# }
# pak::pak(packages)

# sets working directory
here::i_am("r/utilities/workspace.r")

source(here::here("r/utilities/themes"))

# set default plot theme
ggplot2::theme_set(
  # see themes.R for full details
  theme_dark_grey(base_family = "Times New Roman", base_size = 14) +
    theme(
      legend.position = "right",
      legend.title.position = "top",
      legend.direction = "vertical"
    )
)
