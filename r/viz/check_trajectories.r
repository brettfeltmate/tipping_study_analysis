rm(list = ls())

source(here::here("r", "utilities", "workspace.r"))
load(file = here::here("data", "proc", "02_out.rdata"))

library(data.table)
library(ggplot2)
library(ggforce)

pid_count <- 5
tLoc <- "centre"
dLoc <- "left"
sUsed <- "back"
hUsed <- "left"

pids <- sample(dt$participant, pid_count)

tmp <- droplevels(
  dt[
    participant %in% pids &
      target_loc == tLoc &
      distractor_loc == dLoc &
      hand_used == hUsed &
      side_used == sUsed
  ]
)

tmp$hand_x_zeroed <- tmp$hand_x_zeroed * -1.0

tmp[,
  index := seq(0, 1, length.out = nrow(.SD)),
  by = .(trajectory)
]

tmp[,
  delta_z := hand_z - shift(hand_z, n = 5, type = "lag"),
  by = .(trajectory)
]

tmp[, frame_in_traj := seq_len(nrow(.SD)), by = .(trajectory)]

# Quintile the entire, uncut trajectory (for color-coding later)
tmp[, quintile := {
  N <- .N
  r <- frank(frame_in_traj, ties.method = "first")
  as.integer((r - 1) * 5L / max(1L, N)) + 1L
}, by = .(trajectory)]

tmp[, z_smooth := frollmean(hand_z, 5, align = "center", na.rm = TRUE)]

tmp[, apex_pos := {
  if (.N < 3) NA_integer_ else which.max(z_smooth)
}, by = .(trajectory)]

tmp[, apex_pos := ifelse(is.na(apex_pos), .N, apex_pos), by = .(trajectory)]
traj_cut <- tmp[frame_in_traj <= apex_pos]

circle_dat <- data.frame(x0 = 0, y0 = 300, r = 20)

ggplot(
  traj_cut,
  aes(
    x = hand_x,
    y = hand_z,
    colour = factor(quintile),
    group = 1
  )
) +
  geom_path() +
  scale_color_brewer(palette = "Set1", name = "Quintile") +
  scale_x_continuous(limits = c(-200, 200)) +
  scale_y_continuous(limits = c(0, 400)) +
  facet_wrap(~trajectory) +
  geom_circle(aes(x0 = x0, y0 = y0, r = r), data = circle_dat, inherit.aes = FALSE, fill = "wheat")
