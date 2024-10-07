# NOTE: Choice of which particpants to plot based off of ratio of plausible/implausible RTs as recorded by Klibs

klibs_files <- list.files(here::here("data", "raw", "klibs"), full.names = TRUE)

read_remake_pid <- function(file) {
  # file name leads w/ P#; grep for #, drop any following text
  pid <- gsub(".2024.*", "", basename(file))
  tmp <- fread(file)
  tmp$participant <- gsub("p", "", pid)
  setnames(tmp, "participant", "participant_id")
  return(tmp)
}

klibs <- rbindlist(lapply(klibs_files, read_remake_pid))

klibs <- klibs[practicing == FALSE]

# NOTE: klibs data contains all files (including dev testing)
klibs <- klibs[participant_id %in% unique(dt$participant_id)]

klibs[, participant_id := as.factor(participant_id)]

# NOTE: RTs are off by -7 orders of magnitude???
klibs[, response_time := response_time * 1e7]

ex <- klibs[, .(num_excessive = sum(response_time > 1)), participant_id]

nice_list <- ex[num_excessive < 10, participant_id]

dt_nice <- dt[participant_id %in% nice_list]

dt <- merge(
  dt,
  klibs[, c(1, 6, 7, 9:13)],
  by = colnames(klibs)[c(1, 6, 7, 9:12)],
  no.dups = TRUE
)

# Visual checks
select_props <- list(
  pid = 51,
  tnum = 10,
  bnum = 4, # NOTE: 2 for some, 4 for others (hand used was blocked)
  plotted_var = "acceleration"
)

trial <- get_trial(
  dt,
  select_props$pid,
  select_props$tnum,
  select_props$bnum
)

p <- ggplot(
  data = trial,
  aes(x = time, y = get(select_props$plotted_var))
) +
  geom_line() +
  labs(x = "time", y = select_props$plotted_var)
