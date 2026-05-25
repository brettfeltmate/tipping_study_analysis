# FIXME: luggage combination
set.seed(12345)

# Loaded within scripts on as-needed basis
packages <- c(
  "data.table",
  "emmeans", # post-hocs
  "ggplot2",
  "ggthemes",
  "parallel",
  "patchwork", # plot composites
  "plotly", # 3d plotting
  "refund", # model functional data
  "tidyfun" # wrangle functional data
)

if (!requireNamespace("pak")) {
  install.packages("pak")
}
pak::pak(packages)

rm(packages)

# sets working directory
here::i_am("r/utilities/workspace.r")

source(here::here("r/utilities/themes.r"))

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
