# Cumulative accuracy function
# bin RTs by binwidth, and returns mean accuracy (+ count) for bins
caf <- function(rt, acc, bw = 50) {
  df <- data.frame(rt = rt, acc = acc)
  bins <- ceiling(df$rt / bw) * bw
  df$bin <- bins

  out <- do.call(
    data.frame,
    aggregate(
      acc ~ bin,
      data = df,
      FUN = function(x) c(acc = mean(x, na.rm = TRUE), count = length(x))
    )
  )
  colnames(out) <- c("bin", "mean", "count")
  return(out)
}

# Two-tailed cutoffs of numeric vector
bounds <- function(x, prob = 0.95) {
  w <- (1 - prob) / 2
  quantile(x, c(w, 1 - w), names = FALSE)
}

# Bootstraps desired function, returns CI. If booties, returns all booted values
boot_ci <- function(
  vals,
  reps = 1000,
  prob = 0.95,
  func = mean,
  booties = FALSE
) {
  # Preallocate memory
  boots <- numeric(reps)
  # resample data
  for (i in seq(reps)) {
    # resample values
    s <- sample(vals, replace = TRUE)
    # store sample mean
    boots[i] <- func(s)
  }

  if (booties) {
    return(boots)
  }

  # Get bounds corresponding to desired CI probability
  bounds <- bounds(boots, prob)
  return(list(mean = mean(boots), lcl = bounds[1], ucl = bounds[2]))
}

# lifted as-is from k5 package
# as I didn't want a whole dependency for one function
# Anyway, this overrides the default truncated print that
# most print() overrides use.
print_all <- function(x, ask = TRUE) {
  max <- getOption("max.print", 1000)
  is_tbl <- tibble::is_tibble(x)
  is_df <- is.data.frame(x)
  n <- ifelse(is_tbl | is_df, nrow(x), length(x))
  if (n > max) {
    sure <- !ask
    if (ask && interactive()) {
      if (is_installed("usethis")) {
        sure <- usethis::ui_yeah(
          x = "Length exceedes {usethis::ui_code('getOption(\"max.print\")')}",
          yes = glue::glue(
            "Print {crayon::red('all')}: {prettyNum(n, big.mark = ',')}"
          ), # nolint: line_length_linter.
          no = glue::glue("Print max: {prettyNum(max, big.mark = ',')}")
        )
      } else {
        stop("Package \"usethis\" needed for confirmation", call. = FALSE)
      }
    }
    if (sure && is_tbl) {
      print(x, n = Inf)
      return(invisible(x))
    } else if (sure) {
      print(x, max = 99999L)
      return(invisible(x))
    }
  }
  if (is_tbl) {
    print(x, n = max)
  } else if (!is_tbl) {
    print(x, max = max * 2)
  }
}

# does what it says on the tin.
get_trial <- function(dt, participant, tnum, bnum) {
  required_columns <- c("participant", "trial_num", "block_num")
  missing_columns <- setdiff(required_columns, colnames(dt))
  if (length(missing_columns) > 0) {
    stop(
      paste(
        "The following columns are missing from the data frame:",
        paste(missing_columns, collapse = ", ")
      )
    )
  }
  trial <- dt[
    participant == participant & # nolint: object_usage_linter.
      trial_num == tnum & # nolint: object_usage_linter.
      block_num == bnum # nolint: object_usage_linter.
  ]
  return(trial)
}

# sum-to-zero contrast that's handy for dichotomous vars without a clear reference level
halfhelmert_contrasts <- function(...) {
  contr.helmert(...) * .5
}
