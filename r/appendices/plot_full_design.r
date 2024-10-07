if (!requireNamespace("here")) install.packages("here")
source(here::here("r", "utilities", "workspace.r"))

library(data.table)

load(here::here("data", "proc", "02_out.rdata"))

dt[
  ,
  c("reach_num", "t_d", "h_s") :=
    .(
      as.numeric(paste0(block_num, trial_num)), # reach_num
      paste0("T:", target_loc, " | ", "D:", distractor_loc), # t_d
      paste0("H:", left_right_hand, " | ", "S:", palm_back_hand) # h_s
    )
]

# TODO:
# [ ] skip if file already exists
# [ ] make plots overlaying individual markers

for (pid in unique(dt$participant_id)) {
  for (target in c("Left", "Right", "Centre")) {
    for (distractor in c("Left", "Right", "Centre")) {
      message(
        "\n",
        "Participant: ",
        pid, ", Target: ",
        target, ", Distractor: ",
        distractor,
        "\n"
      )
      pid_data <- dt[participant_id == pid]
      pid_data <- pid_data[target_loc == target & distractor_loc == distractor]

      if (nrow(pid_data) > 0) {
        p <- ggplot(
          data = pid_data, aes(x = time, y = hand_z, group = reach_num)
        ) +
          geom_line(alpha = 0.1, color = "lemonchiffon") +
          labs(
            title = paste0(
              "Target: ", target,
              " | Distractor:", distractor,
              "\nP:", pid
            ),
            x = "Time", y = "Z (back/for)"
          ) +
          facet_wrap(~h_s, ncol = 2)

        ggplot2::ggsave(
          file = paste0(
            "p", pid, "_",
            target, "target_",
            distractor, "distractor.png"
          ),
          path = "./out/fig/target_by_distractor/z_pos", plot = p,
          width = 9, height = 9, units = "in", dpi = "retina"
        )
      }
    }
  }
}
