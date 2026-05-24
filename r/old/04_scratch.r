if (!requireNamespace("here")) install.packages("here")
source(here::here("r", "utilities", "workspace.r"))

library(data.table)
library(magrittr)
library(tidyr)
library(dplyr)
library(purrr)
library(tidyfun)
library(refund)

load(here::here("data", "proc", "03_out.rdata"))

ss <- levels(dt$participant)

dat <- droplevels(dt[participant %in% ss[1] & trial_num == 1 & block_num == 2])

dat <- dat[, c(2:9, 11)]

dat <- dat |> tf_nest(hand_x, .id = participant, .arg = frame)

# okay so for multiple ss...

dat <- droplevels(dt[participant %in% ss[1:3] & trial_num == 1 & block_num == 2])

dat <- dat[, c(2:9, 11)]

dat <- dat |> tf_nest(hand_x, .id = participant, .arg = frame)

# nope that didn't work

dat <- droplevels(dt[participant %in% ss[1:3] & block_num == 2])

tst <- dat[, c(2:9, 11)] |>
  # fuck yeah motherfucker
  _[, traj_id := paste(participant, trial_num, sep = "_")] |>
  tf_nest(hand_x, .id = traj_id, .arg = frame, evaluator = "tf_approx_spline") |>
  setDT()

tst |>
  filter(hand_used == "right") |>
  tf_ggplot(aes(colour = side_used, group = trial_num)) +
  geom_line(aes(tf = hand_x), alpha = 0.5) +
  coord_flip() +
  scale_y_continuous(limits = c(-40, 40)) +
  facet_wrap(target_loc ~ distractor_loc, ncol=2, nrow=3)
