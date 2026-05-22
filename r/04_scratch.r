if (!requireNamespace("here")) install.packages("here")
source(here::here("r", "utilities", "workspace.r"))

library(data.table)
library(tidyfun)
library(refund)

load(here::here("data", "proc", "03_out.rdata"))

dt <- droplevels(dt[participant %in% levels(participant)[1:5]])

xdt <- dt[, 1:11]
