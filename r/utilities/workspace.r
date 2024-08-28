rm(list = ls())

# FIXME: change luggage combination
set.seed(12345)

if (!requireNamespace("pak")) {
  install.packages("pak")
}

core_deps <- c(
  "here",
  "data.table",
  "magrittr",
  "ggplot2",
  "patchwork"
)

pak::pak(core_deps)

here::i_am("scripts/utilities/workspace.r")
source(here::here("scripts", "themes.R"))

ggplot2::theme_set(
  # NOTE: defined in scripts/themes.R
  theme_dark_blue(base_family = "Maple Mono NF", base_size = 12) +
    theme(
      legend.position = "right",
      legend.title.position = "top",
      legend.direction = "vertical"
    )
)

# purely for convenience
gg <- function(w = 5, h = 5, f = "~/.last_plot.png") {
  ggplot2::ggsave(
    filename = f,
    width = w, height = h,
    units = "in", dpi = "retina"
  )
}
