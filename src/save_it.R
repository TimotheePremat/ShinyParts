# Save plots
ggsave(longit_plot,
    file = paste0("../graphs/", prefix, "_longit_plot.png"),
    width=20,
    height=5,
    units="cm",
    dpi=1000)
ggsave(pop_plot,
    file = paste0("../graphs/", prefix, "_pop_plot.png"),
    width=15,
    height=15,
    units="cm",
    dpi=1000)

ggsave(time_series,
    file = paste0("../graphs/", prefix, "time_series.png"),
    width=30,
    height=15,
    units="cm",
    dpi=1000)

ggsave(time_series_noNA,
    file = paste0("../graphs/", prefix, "time_series_noNA.png"),
    width=30,
    height=15,
    units="cm",
    dpi=1000)

ggsave(time_series_noNA_lm,
    file = paste0("../graphs/", prefix, "time_series_noNA_lm.png"),
    width=30,
    height=15,
    units="cm",
    dpi=1000)

ggsave(time_series_noNA_loess,
    file = paste0("../graphs/", prefix, "time_series_noNA_loess.png"),
    width=30,
    height=15,
    units="cm",
    dpi=1000)

# Save data
write.csv(data,
    file = paste0("../tables/", prefix, "_data_all.csv"))
write.csv(data_length,
    file = paste0("../tables/", prefix, "_data_all_length.csv"))
