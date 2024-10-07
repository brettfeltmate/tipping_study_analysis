get_trial <- function(dt, pid, tnum, bnum) {
  required_columns <- c("participant_id", "trial_num", "block_num")
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
    participant_id == pid & # nolint: object_usage_linter.
      trial_num == tnum & # nolint: object_usage_linter.
      block_num == bnum # nolint: object_usage_linter.
  ]
  return(trial)
}
