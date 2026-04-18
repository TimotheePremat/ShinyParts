# 2025-11-06 Timothée Premat
# Université Paris Est Créteil, Céditec lab.
# ArchivU project: https://archivu.hypotheses.org

# Delivered under GNU-GPL 3 license

folders <- c("../data", "../graphs", "../tables")
sapply(folders, dir.create, showWarnings = FALSE, recursive = TRUE)

source("packages.R")
source("functions.r", local = FALSE)
source("ui.r")
source("server.r")

shiny::runApp(list(ui = ui, server = server))
