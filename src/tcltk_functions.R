get_naming_prefix <- function() {
  tt <- tktoplevel()
  tkwm.title(tt, "File naming")

  var <- tclVar("")

  tkgrid(tklabel(tt, text = "Enter a prefix for file naming:"))
  entry <- tkentry(tt, textvariable = var)
  tkgrid(entry)

  done <- tclVar(0)

  on_ok <- function() {
    tclvalue(done) <- 1
  }

  ok_button <- tk2button(tt, text = "OK", command = on_ok)
  tkgrid(ok_button)

  tkfocus(entry)

  # Wait until the OK button is pressed
  tkwait.variable(done)

  result <- tclvalue(var)
  tkdestroy(tt)

  return(result)
}

prefix <- get_naming_prefix()
