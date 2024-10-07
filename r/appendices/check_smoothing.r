# Plotting functions

# from supplied trial data, plots markers' positions about desired axis
# smoothed data is plotted when true

# conditionally extract trial data and pass to marker_plot()
# plot not drawn because quartz windows cause my WM to throw a fit
plot_trial <- function(dt, pid, trial, block, axis, smoothed = FALSE) {
  # get_trial() defined in utilities/functions.r
  trial_data <- get_trial(dt, pid, trial, block)
  plot_trial_internal(trial_data, axis, smoothed)
}

# HACK: use internal function to plot the trial data
# otherwise self-aborts due to recursion depth
plot_trial_internal <- function(trial, axis, smoothed = FALSE) {
  # base plot
  p <- ggplot(trial, aes(x = time))

  # add lines for desired markers
  for (i in 1:5) {
    col <- paste0("m", i, "_", axis)

    if (smoothed) col <- paste0(col, "_smooth")

    p <- p + geom_line(aes(y = get(col)), colour = palette[i])
  }

  # make context specific labels
  ylab <- paste0(axis, "-pos")

  if (smoothed) {
    ylab <- paste0(ylab, " (smoothed)")
  } else {
    ylab <- paste0(ylab, " (raw)")
  }

  p <- p + labs(x = "trial time", y = ylab)

  # use extreme  values to set common  axis  limits
  limits <- trial[,
    .(
      lower = unlist(min(.SD)),
      upper = unlist(max(.SD))
    ),
    .SDcols = patterns(paste0("_", axis))
  ]

  p <- p + ylim(c(limits$lower, limits$upper))

  return(p)
}

# Plot raw vs smooth

# short-hand
trial_props <- list(
  dt = dt,
  pid = unique(dt$participant_id)[11],
  trial = 40,
  block = 2,
  axis = NA,
  smoothed = FALSE
)

# create plot of raw data for each axis
for (axis in c("x", "y", "z")) {
  # set axis
  trial_props$axis <- axis
  assign(
    # variable name plot will be stored under
    x = paste0("p", axis, "_raw"),
    value = do.call(plot_trial, trial_props)
  )
}

# same, but smoothed data
trial_props$smoothed <- TRUE

for (axis in c("x", "y", "z")) {
  trial_props$axis <- axis
  assign(
    x = paste0("p", axis, "_smooth"),
    value = do.call(plot_trial, trial_props)
  )
}

# create plot composite
require(patchwork)

raw_patch <- px_raw + py_raw + pz_raw

smooth_patch <- px_smooth + py_smooth + pz_smooth

patched <- raw_patch / smooth_patch
