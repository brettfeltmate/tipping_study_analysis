if (!requireNamespace("here")) install.packages("here")
source(here::here("r", "utilities", "workspace.r"))

library(data.table)
library(tidyfun)
library(refund)
library(mgcv)

load(here::here("data", "proc", "04_out.rdata"))

terms <- colnames(dt)[c(1:6, 8)]

dt$hand_z <- NULL

pids <- sample(unique(dt$participant), 3)

model_data <- dt[participant %in% pids]

model_def <- hand_x ~
  c(distractor_side) *
    c(hand_used) *
    c(side_used) *
    s(participant, trajectory, bs = "re")

model_data$trajectory <- as.factor(model_data$trajectory)

formula_m1 <- hand_x ~
  distractor_side * hand_used * side_used +
  s(index, trajectory, distractor_side, hand_used, side_used, by = participant, bs = "re")

m1 <- gam(formula_m1, data = model_data)
summary(m1)
