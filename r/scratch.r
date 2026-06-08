# -------------------------------------------------
# examples lifted from tf's documentation
# -------------------------------------------------

library(tidyfun)

x <- 1:3 * tfd(data = 0:10, arg = 0:10)
plot(x)

# []'s 2nd argument is quite overloaded -- you can:

# 1. Simply extract elements from the vector if no second arg is given:
x[1]

x[c(TRUE, FALSE, TRUE)]

x[-(2:3)]

# 2. Use the second argument and optional additional arguments to
# extract specific function evaluations in a number of formats:

# returns a matrix of function evaluations
x[1:2, c(1, 2)]

# NA for arg-values not in the original data
x[1:2, c(4.5, 9), interpolate = FALSE]

# list of data.frames for each function
x[-3, seq(1, 9, by = 2), matrix = FALSE]

# 3. use a 2-column matrix to extract specific (function, arg) pairs:

# one value per function
x[cbind(1:3, c(0, 5, 10))]

# 4. use matrix= with a missing j to evaluate on the default arg grid:

# same as x[1:2, tf_arg(x), matrix = FALSE]
x[1:2, , matrix = FALSE]

# in order to evaluate a set of observed functions on a new grid and
# save them as a functional data vector again, use `tfd` or `tfb` instead:
tfd(x, arg = seq(0, 10, by = 0.01))
tfd(x, arg = seq(3, 7, by = 1))

as.data.frame(x)
as.data.frame(x, unnest = TRUE)
as.matrix(x)

fun <- as.function(x)
# oh that's cool
fun(c(0, 0.5, 1))

x <- tf_rgp(3)
layout(t(1:3))
plot(x, col = 1:3)

# clamp each function's values to [0,1]:
x_clamp <- (x - tf_fmin(x)) / (tf_fmax(x) - tf_fmin(x))
plot(x_clamp, col = 2:4)

# standardize each function to have mean / integral 0 and sd 1:
x_std <- (x - tf_fmean(x)) / tf_fsd(x)
tf_fvar(x_std) == c(1, 1, 1)
plot(x_std, col = 1:3)

# Custom functions:

# 80%-tiles of each function's values:
tf_fwise(x, \(.x) quantile(.x$value, 0.8)) |> unlist()

# minimal value of each function for t > 0.5
tf_fwise(x, \(.x) min(.x$value[.x$arg > 0.5])) |> unlist()

tf_crosscor(x, -x)
tf_crosscov(x, x) == tf_fvar(x)

in_range(1:10, c(3, 7))
1:10 %inr% c(3, 7)

f <- tf_rgp(3, arg = seq(0, 1, length.out = 11))

tf_evaluate(f) |> str()

tf_evaluate(f, arg = 0.5) |> str()

# equivalent, as matrix:
f[, 0.5]

new_grid <- seq(0, 1, length.out = 6)

tf_evaluate(f, arg = new_grid) |> str()

# equivalent, as matrix:
f[, new_grid]

lin <- 1:4 * tfd(seq(-1, 1, length.out = 11), seq(-1, 1, length.out = 11))

tf_where(lin, value %inr% c(-1, 0.5))

tf_where(lin, value %inr% c(-1, 0.5), "range")

a <- 1

tf_where(lin, value > a, "first")

tf_where(lin, value < a, "last")

tf_where(lin, value > 2, "any")

tf_anywhere(lin, value > 2)

f <- tf_rgp(5, 11)

plot(f, pch = as.character(1:5), points = TRUE)

tf_where(f, value == max(value))

# where is the function increasing/decreasing?
tf_where(f, value > dplyr::lag(value, 1, value[1]))

tf_where(f, value < dplyr::lead(value, 1, tail(value, 1)))

# where are the (interior) extreme points (sign changes of `diff(value)`)?
tf_where(
  f,
  sign(c(diff(value)[1], diff(value))) !=
    sign(c(diff(value), tail(diff(value), 1)))
)

# where in its second half is the function positive?
tf_where(f, arg > 0.5 & value > 0)

# does the function ever exceed?
tf_anywhere(f, value > 1)

x <- tf_rgp(10)

plot(x)

# Brett: this'll likely come in handy
tf_zoom(x, 0.5, 0.9)

tf_zoom(x, 0.5, 0.9) |> lines(col = "red")

tf_zoom(x, seq(0, 0.5, length.out = 10), seq(0.5, 1, length.out = 10)) |>
  lines(col = "blue", lty = 3)


# -------------------------------------------------
# Now with our data & intents
# -------------------------------------------------

if (!requireNamespace("here")) install.packages("here")
source(here::here("r", "utilities", "workspace.r"))

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
  facet_wrap(target_loc ~ distractor_loc, ncol = 2, nrow = 3)
