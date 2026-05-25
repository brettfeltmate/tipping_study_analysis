require(here)

# WARN: checks for and installs libraries
source(here::here("r/utilities/workspace.r"))

require(data.table)
require(tidyfun)
require(parallel)

local({
  # ----------------------------
  # HELPER FUNCTIONS
  # ----------------------------

  # File paths concatenations of factor levels for that trial
  extract_factors_from_path <- function(trial) {
    block_factors <- unlist(strsplit(dirname(trial), split = "/"))
    trial_factors <- unlist(strsplit(basename(trial), split = "_"))
    block <- unlist(strsplit(block_factors[3], split = "_"))
    list(
      participant = block_factors[1], block_num = block[2],
      hand_used = block[3], side_used = block[4],
      trial_num = trial_factors[2], target_loc = trial_factors[4],
      distractor_loc = gsub("\\.csv$", "", trial_factors[6])
    )
  }

  # set types
  convert_columns <- function(trial) {
    numerics <- c("pos_x", "pos_y", "pos_z", "frame_number")
    factors <- c(
      "hand_used", "side_used",
      "target_loc", "distractor_loc",
      "participant", "trial_num", "block_num"
    )
    trial[, (numerics) := lapply(.SD, as.numeric), .SDcols = numerics]
    trial[, (factors) := lapply(.SD, as.factor), .SDcols = factors]
    trial
  }

  # raw markers listed rowwise within each frame
  spread_markers <- function(trial) {
    marker_count <- 10
    trial[, marker_id := rep_len(1:marker_count, .N)]
    trial <- dcast(trial,
      frame_number + participant + block_num + hand_used +
        side_used + trial_num + target_loc +
        distractor_loc ~ marker_id,
      value.var = c("pos_x", "pos_y", "pos_z")
    )
    trial
  }

  # collapse down to single measure of hand position
  average_markers <- function(trial) {
    marker_cols <- grep("_[xyz]", names(trial), value = TRUE)
    trial[, hand_x := rowMeans(.SD), .SDcols = marker_cols[grep("x", marker_cols)]]
    trial[, hand_y := rowMeans(.SD), .SDcols = marker_cols[grep("y", marker_cols)]]
    trial[, hand_z := rowMeans(.SD), .SDcols = marker_cols[grep("z", marker_cols)]]
    trial[, (marker_cols) := NULL]
    trial
  }

  # pipeline
  read_and_preprocess <- function(trial) {
    factors <- extract_factors_from_path(trial)
    trial <- fread(here::here("data", "raw", "opti", trial))
    trial[, names(factors) := factors]
    trial <- convert_columns(trial)
    trial <- spread_markers(trial)
    trial <- average_markers(trial)
    # _io junk, frame redundant, hand_y/z uninteresting
    trial[, c("frame_number", "hand_y", "hand_z") := NULL]
    # make frame/time relative to trial start
    trial[, time := seq_len(.N) / 120]
    # coerce trajectory data into tidyfun objects
    trial[, traj_id := paste(participant, block_num, trial_num, sep = "_")]
    trial |>
      tf_nest(
        hand_x,
        .id = "traj_id",
        .arg = "time",
        evaluator = "tf_approx_spline"
      ) |>
      setDT()
  }

  # My attempt at parallelization
  process_files <- function(files) {
    # leave two cores because electron apps happen
    ncores <- max(1, detectCores() - 2)
    message(
      sprintf(
        "Processing %d files using %d cores...",
        length(files),
        ncores
      )
    )
    cl <- makeCluster(ncores)
    on.exit(stopCluster(cl))
    # Export necessary functions and packages to cluster
    clusterEvalQ(cl, {
      require(data.table)
      require(here)
      require(tidyfun)
    })
    clusterExport(cl, c(
      "read_and_preprocess", "extract_factors_from_path",
      "convert_columns", "spread_markers", "average_markers"
    ),
    envir = environment()
    )
    result <- clusterApplyLB(cl, files, read_and_preprocess)
    cat(
      "File processing took: ",
      round(
        difftime(Sys.time(),
          start,
          units = "secs"
        ),
        digits = 2
      ), " seconds.\n"
    )
    result
  }

  # ----------------------------
  # READ FILES
  # ----------------------------

  trials <- list.files(
    path = here::here("data", "raw", "opti"),
    recursive = TRUE
  )

  dt <- rbindlist(process_files(trials[!grepl("practice", trials)]))

  setkey(dt, "traj_id")

  save(dt, file = here::here("data/proc/01_out.rdata"))
})
