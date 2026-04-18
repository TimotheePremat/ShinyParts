# shiny::runApp()
server <- function(input, output, session) {
#Increase mx size for file upload
options(shiny.maxRequestSize=1024^3)   # 1 GB = 1024^3 bytes

  # --- 1. File selection and data loading ---
  # (UI handled in ui.r)

  # 2.1 Load background data
  background_data <- reactive({
    req(input$background)
    df <- read.csv(input$background$datapath, sep = "\t", quote = "")
    # fname <- basename(input$background$name)
    # fname <- sub("\\.[cCtT][sS][vV]$", "", fname) # remove .csv or .tsv (case-insensitive)
    df$type <- "background"
    df %>%
      dplyr::select(-ContexteGauche, -ContexteDroit) %>%
      dplyr::rename(form = Pivot) %>%
      dplyr::mutate(across(everything(), ~ trimws(as.character(.))))
  })

  # 2.2 Load environment data
  env_data <- reactive({
    req(input$env_files)
    dfs <- lapply(seq_len(nrow(input$env_files)), function(i) {
      df <- read.csv(input$env_files$datapath[i], sep = "\t", quote = "")
      fname <- basename(input$env_files$name[i])
      fname <- sub("\\.[cCtT][sS][vV]$", "", fname) # remove .csv or .tsv (case-insensitive)
      df$type <- fname
      df
    })
    bind_rows(dfs) %>%
      dplyr::select(-ContexteGauche, -ContexteDroit) %>%
      dplyr::rename(form = Pivot)
  })

  # 3. Parse first column by comma for env_data
  parsed_env_data <- reactive({
    req(env_data())
    df <- env_data()
    first_col <- df[[1]]
    split_mat <- do.call(rbind, strsplit(as.character(first_col), ","))
    split_df <- as.data.frame(split_mat, stringsAsFactors = FALSE)
    if (ncol(df) > 1) {
      cbind(split_df, df[,-1, drop=FALSE])
    } else {
      split_df
    }
  })

  # 3b. Parse first column by comma for background_data
  parsed_background_data <- reactive({
    req(background_data())
    df <- background_data()
    first_col <- df[[1]]
    split_mat <- do.call(rbind, strsplit(as.character(first_col), ","))
    split_df <- as.data.frame(split_mat, stringsAsFactors = FALSE)
    if (ncol(df) > 1) {
      cbind(split_df, df[,-1, drop=FALSE])
    } else {
      split_df
    }
  })

  # Deal with multiple columns selection for type
    # Dynamically generate one selectInput per column
    output$col_select_ui <- renderUI({
      req(input$ncols)
      df <- renamed_env_data()
      n <- input$ncols
      colnames_df <- colnames(df)

    # Generate a list of selectInput elements
    select_inputs <- lapply(1:n, function(i) {
      selectInput(
        inputId = paste0("col_", i),
        label = paste("Select column for type of depth", i),
        choices = colnames_df
      )
    })

    do.call(tagList, select_inputs)
  })

  # Generate vars for conditional UI
  output$background_loaded <- reactive({
    !is.null(background_data())
  })
  outputOptions(output, "background_loaded", suspendWhenHidden = FALSE)

  output$env_data_loaded <- reactive({
    !is.null(env_data())
  })
  outputOptions(output, "env_data_loaded", suspendWhenHidden = FALSE)

  output$merged_generated <- reactive({
    !is.null(env_data_merged())
  })
  outputOptions(output, "merged_generated", suspendWhenHidden = FALSE)

  # Reactive: gather selected columns
  selected_cols <- reactive({
    req(input$ncols)
    sapply(1:input$ncols, function(i) input[[paste0("col_", i)]])
  })

    # helper: replace literal "null" (case-insensitive) with NA
    replace_null_with_na <- function(x) {
      x <- as.character(x)
      x <- trimws(x)
      x[tolower(x) == "null"] <- NA_character_
      x
    }

  # Step 3: Collapse the chosen columns when the user clicks "go"
  collapsed_data <- eventReactive(input$go, {
    df <- env_data_merged()
    cols <- selected_cols()
    req(cols)

    # Ensure the columns exist
    cols <- intersect(cols, names(df))

    # replace "null" with NA in selected columns
    df <- df %>% mutate(across(all_of(cols), replace_null_with_na))

    # pick rightmost non-NA value (example using dplyr::coalesce on reversed cols)
    df <- df %>%
      mutate(across(all_of(cols), ~na_if(., ""))) %>%   # "" → NA
      mutate(type = do.call(dplyr::coalesce, select(., all_of(rev(cols))))) %>%
      mutate(type = ifelse(is.na(type) | type == "", "background", type)) %>%
      select(-all_of(cols))

    # Drop the original source columns used for collapsing
    # df <- df %>% select(-all_of(cols))

    df
  })


  # working_df picks collapsed_data() if it exists, otherwise merged_data_env()
  working_df <- reactive({
    # data <- req(collapsed_data()
    if (input$deal_with_nested) {
      df <- collapsed_data()
    } else {
      df <- env_data_merged()
    }
    df
  })

  # Step 4: render the resulting table
  output$working_df_preview <- renderDT({
    datatable(
      working_df(),
      options = list(pageLength = 10, scrollX = TRUE, autoWidth = TRUE),
      rownames = FALSE
    )
  })

  # Create renamed df based on col sel
  renamed_env_data <- reactive({
    df <- parsed_env_data()
    # df <- df %>%
    # #   rename(date = input$year_col_select) %>%
    # #   rename(text = input$text_id_col_select) %>%
    #   rename(tokenN = input$position_col)
    df
  })

  renamed_background_data <- reactive({
    df <- parsed_background_data()
    # df <- df %>%
    # #   rename(date = input$year_col_select) %>%
    # #   rename(text = input$text_id_col_select) %>%
    #   rename(tokenN = input$position_col)
    df
  }) 

  # 4. Prompt user to name new columns for env_data
  # output$colname_inputs <- renderUI({
  #   req(parsed_env_data())
  #   n <- ncol(parsed_env_data())
  #   colnames_now <- colnames(parsed_env_data())
  #   lapply(seq_len(n), function(i) {
  #     textInput(paste0("colname_", i), paste("Name for column", i), value = colnames_now[i])
  #   })
  # })

  # 5. Rename columns in data frame for env_data
  # renamed_env_data <- reactive({
  #   df <- parsed_env_data()
  #   n <- ncol(df)
  #   new_names <- sapply(seq_len(n), function(i) input[[paste0("colname_", i)]] %||% paste0("V", i))
  #   colnames(df) <- new_names
  #   df
  # })

  # 5b. Rename columns in data frame for background_data
  # renamed_background_data <- reactive({
  #   df <- parsed_background_data()
  #   n <- ncol(df)
  #   new_names <- sapply(seq_len(n), function(i) input[[paste0("colname_", i)]] %||% paste0("V", i))
  #   colnames(df) <- new_names
  #   df
  # })

  # 6. Preview renamed environment data (no metadata selection)
  output$env_preview <- renderTable({
    head(renamed_env_data(), n = 5L)
  })

  # 6b. Preview renamed background data
  output$bg_preview <- renderTable({
    head(renamed_background_data(), n = 5L)
  })

  output$bg_preview_ui <- renderUI({
    if (is.null(input$background)) {
      # Show message if data not loaded
      tags$p(
        style = "display: flex; align-items: center;",
        tags$i(class = "bi bi-arrow-left-square-fill", style = "margin-right:5px;"),
        "Load background data (all words of the corpus), using the 'Background CSV' selector."
      )
    } else {
      # Show table if data exists
      tableOutput("bg_preview")
    }
  })

  output$env_preview_ui <- renderUI({
    if (is.null(input$env_files)) {
      # Show message if data not loaded
      tags$p(
        style = "display: flex; align-items: center;",
        tags$i(class = "bi bi-arrow-left-square-fill", style = "margin-right:5px;"),
        "Load envs data (tokens that match one of the envs), using the 'Environment(s) CSV' selector."
      )
    } else {
      # Show table if data exists
      tableOutput("env_preview")
    }
  })

  # 7. UI for selecting columns for anti_join (after renaming columns)

  # 7.1 UI: Select which column is year
  output$year_col_select <- renderUI({
    req(renamed_env_data())
    selectInput("year_col",
      label = tooltip(
        trigger = list(
          "Date:",
          bs_icon("info-circle")
        ),
        HTML("ShinyParts needs a col. with date (YYYY, DD-MM-YYYY, DD/MM/YYYY, YYYY-MM-DD or YYYY/MM/DD).<br/>You can supply a fake date col. (by inserting it in your data)
        and ignore the longitudinal graphs if needed.")
      ),
      choices = names(renamed_env_data()),
      selected = names(renamed_env_data())[3])
  })

  # 7.2 UI: Select which column is position (number in text)
  output$position_col_select <- renderUI({
    req(renamed_env_data())
    selectInput("position_col",
      label = tooltip(
        trigger = list(
          "Token n:",
          bs_icon("info-circle")
        ),
        HTML("ShinyParts needs a col. with token ID (ordinal location of token in text, usually <i>n</i>)")
      ),
    choices = names(renamed_env_data()),
    selected = names(renamed_env_data())[2])
  })

  # 7.3 UI: Select which column is text_id
  output$text_id_col_select <- renderUI({
    req(renamed_env_data())
    selectInput("text_id_col",
      label = tooltip(
        trigger = list(
          "Text-ID:",
          bs_icon("info-circle")
        ),
        HTML("ShinyParts needs a col. with unique text-ID<br/>This is also the col. that will be used for printing text labels.")
      ),
      choices = names(renamed_env_data()),
      selected = names(renamed_env_data())[1])
  })

  # 7.3 UI: Select which column is type
  # output$text_type_col_select <- renderUI({
  #   req(renamed_env_data())
  #   selectInput("type_col",
  #     label = tooltip(
  #       trigger = list(
  #         "Type:",
  #         bs_icon("info-circle")
  #       ),
  #       HTML("If type information is contained into one of the cols. If not (if type = input file), set this to 'type'. If several cols. contain
  #       type information (in case of nesting), ignore this setting and use the option for dealing with nested envs below (it will override this setting).")
  #     ),
  #     choices = names(renamed_env_data()),
  #     selected = names(renamed_env_data())[ncol(renamed_env_data())])
  # })

  # change df if df for depth of env created
  data_env_conditional <- reactive({
    if (!is.null(collapsed_data())) {
      df <- req(renamed_env_data)
    } else {
      df <- req(collapsed_data())
    }
    df
  })

  # Use it: anti-join background_data and renamed_env_data by user-selected columns
  env_data_merged <- reactive({
      req(renamed_background_data(), renamed_env_data(), input$text_id_col, input$position_col, input$year_col)
      # Create a new collision column in both dataframes
      bg <- renamed_background_data()
      env <- renamed_env_data()
      bg$join_id <- paste0(trimws(bg[[input$text_id_col]]), "_", trimws(bg[[input$position_col]]))
      env$join_id <- paste0(trimws(env[[input$text_id_col]]), "_", trimws(env[[input$position_col]]))
      # Keep all rows from env, and only bg rows not duplicated in env
      bg_only <- dplyr::anti_join(bg, env, by = "join_id")
      df <- dplyr::bind_rows(env, bg_only)
      # Add std_date column based on year_col
          # simple parser for three formats: "YYYY", "DD-MM-YYYY", "DD/MM/YYYY"
          raw_col <- df[[input$year_col]]
          # if it's already Date/POSIX, use it directly
          if (inherits(raw_col, "Date") || inherits(raw_col, "POSIXt")) {
            df$std_date <- as.Date(raw_col)
          } else {
          # normalize to character
          raw <- as.character(raw_col)
          raw <- trimws(raw)
          # prepare output vector
          parsed <- rep(as.Date(NA), length(raw))
          # detect formats
          is_year      <- grepl("^\\d{4}$", raw)
          is_dmy_dash  <- grepl("^\\d{1,2}-\\d{1,2}-\\d{4}$", raw)
          is_dmy_slash <- grepl("^\\d{1,2}/\\d{1,2}/\\d{4}$", raw)
          is_ymd_dash  <- grepl("^\\d{4}-\\d{1,2}-\\d{1,2}$", raw)
          is_ymd_slash <- grepl("^\\d{4}/\\d{1,2}/\\d{1,2}$", raw)
          # parse each group
          if (any(is_year, na.rm = TRUE)) {
            parsed[is_year] <- as.Date(paste0(raw[is_year], "-01-01"))
          }
          if (any(is_dmy_dash, na.rm = TRUE)) {
            parsed[is_dmy_dash] <- as.Date(raw[is_dmy_dash], format = "%d-%m-%Y")
          }
          if (any(is_dmy_slash, na.rm = TRUE)) {
            parsed[is_dmy_slash] <- as.Date(raw[is_dmy_slash], format = "%d/%m/%Y")
          }
          if (any(is_ymd_dash, na.rm = TRUE)) {
            parsed[is_ymd_dash] <- as.Date(raw[is_ymd_dash], format = "%Y-%m-%d")
          }
          if (any(is_ymd_slash, na.rm = TRUE)) {
            parsed[is_ymd_slash] <- as.Date(raw[is_ymd_slash], format = "%Y/%m/%d")
          }
          # fail gracefully if anything else is present
          if (any(is.na(parsed) & nzchar(raw))) {
            bad_examples <- unique(head(raw[is.na(parsed) & nzchar(raw)], 5))
            validate(need(FALSE,
              paste0("Could not parse some date values (examples: ", paste(bad_examples, collapse = ", "), 
                    "). Acceptable formats: YYYY, DD-MM-YYYY, DD/MM/YYYY. Select a column containing accepted date information using the Date selector.")
            ))
          }
          }
      df$std_date <- parsed
      df <- df %>%
        rename(date = input$year_col) #%>%
        # rename(textID = input$text_id_col) %>%
        # rename(tokenID = input$position_col)
        # rename(type2 = input$text_type_col_select)
      df
    })

  # env_data_merged <- reactive({
  #   df <- req(env_data_merged_1())
  #   # col_id <- input$text_id_col
  #   # df <- df %>% rename(textID = all_of(col_id))
  #   df
  # })
  
#   observe({
#   print(head(env_data_merged()))
# })

  # observe({print(input$text_id_col)})
    # output$env_data_merged_preview <- renderTable({
    #   head(env_data_merged())
    # })

    output$env_data_merged_preview <- DT::renderDataTable({
      working_df()  # or any data frame you want to display
    })


 



# ------------------------------------------------------------
# Time Series 
# ------------------------------------------------------------
  # Df for times series (updated by user filtering)
  data_time_filtered <- reactive({
    req(filtered_data_time_series_2())
    df <- filtered_data_time_series_2() %>%
      group_by(std_date, type) %>%
      summarise(n = n(), .groups = "drop_last") %>%
      group_by(std_date) %>%
      mutate(percentage = n / sum(n))
  })

  # FILTERING 1 (omit)
  # Filter data based on user selection of types to omit
  filtered_data_time_series <- reactive({
    df <- working_df()
    if (!is.null(input$omit_types) && length(input$omit_types) > 0) {
      df <- df[!df$type %in% input$omit_types, ]
    }
    df
  })
  # Populate checkboxes dynamically
  observe({
    df <- working_df()
    updateCheckboxGroupInput(
      session,
      "omit_types",
      choices = sort(unique(df$type)),
      selected = NULL
    )
  })

  # FILTERING 2 (merge with bg)
  # Filter data based on user selection of types to omit
  filtered_data_time_series_2 <- reactive({
    df <- filtered_data_time_series()
    if (!is.null(input$merge_w_bg) && length(input$merge_w_bg) > 0) {
      df$type[df$type %in% input$merge_w_bg] <- "background"
    } else {
      df <- filtered_data_time_series()
    }
    df
  })
  # Populate checkboxes dynamically
  observe({
    df <- working_df()
    updateCheckboxGroupInput(
      session,
      "merge_w_bg",
      choices = sort(unique(df$type)),
      selected = NULL
    )
  })

  output$data_time_preview <- DT::renderDataTable({
    data_time_filtered()  # or any data frame you want to display
  })

  # Deal with regression variables
  reg_var <- reactive({
    list(
      regression_se = if ("regression_se" %in% names(input) && input$regression_se == "Yes") TRUE else FALSE,
      regression_method = if ("regression_method" %in% names(input)) input$regression_method else "NULL",
      regression_ON_OFF = if ("regression_ON_OFF" %in% names(input)) input$regression_ON_OFF else FALSE
    )
  })

  all_types_time <- reactive({
    req(data_length_list())
    dats <- data_length_list()
    types <- unique(unlist(lapply(dats, function(d) as.character(d$type))))
    sort(types)
  })

#   observe({
#   print(paste("Selected type:", all_types_time()))
# })

  # Prepare color scale (same logic as maps)
  global_colors_time <- reactive({
    types <- req(all_types_time())
    if (tolower(input$color_scale_time) == "viridarchivu") {
      cols <- viridis::viridis(n = length(types), option = "D", begin = 0, end = 0.8)
    } else {
      cols <- viridis::viridis(n = length(types), option = tolower(input$color_scale_time))
    }
    cols_named <- setNames(cols, types)
    
    # ---- Override a specific type (i.e., "background") ----
    if (tolower(input$color_scale_time) == "viridarchivu") {
      special_type <- "background"
      special_color <- "gray"

      # If the type already exists, just override it
      if (special_type %in% names(cols_named)) {
        cols_named[special_type] <- special_color

      # If the type does NOT exist in the palette yet (rare but possible),
      # add it at the front so that scale_color_manual sees it.
      } else {
        cols_named <- c(setNames(special_color, special_type), cols_named)
      }
    
    }

    cols_named
  })

  # ---- PLOT IT ---- #
  time_series_plot <- reactive({
    req(data_time_filtered(),
      input$color_scale_time,
      cols <- global_colors_time())

    #Deal with regression variables
    regression_se <- reg_var()$regression_se
    regression_method <- reg_var()$regression_method
    regression_ON_OFF <- reg_var()$regression_ON_OFF

    df <- data_time_filtered()
    # df$date <- as.Date(df$date)
    df$percentage <- as.numeric(df$percentage)

    p <- ggplot(df, aes(x=std_date, y=percentage, fill=type)) +
      geom_area(position = "fill") +
	    theme_classic() +
	    theme(legend.position = "bottom") +
	    scale_x_date(labels = scales::date_format("%Y")) +
      scale_y_continuous(labels = scales::percent_format(accuracy = 1))

      p <- p + scale_fill_manual(values = cols)

      p <- p +
      ggtitle(input$plot_title) +
      labs(y = input$y_title, x = input$x_title)

      if (input$regression_ON_OFF) {
        # if (!is.null(input$regression_ON_OFF) && input$regression_ON_OFF == "True") {
        p <- p +
          geom_smooth(mapping = aes(x=std_date,
                                    y=percentage,
                                    colour = type),
                      method = regression_method,
                      se = regression_se,
                      data = df[df$type %in% input$types_for_regression, ],
                      show.legend = TRUE,
                      # colour = "white"
                      )
      } else {
        p <- p
      }

      p
    })

  # Display handler
  output$time_series_plot_preview <- renderPlot({
    p <- req(time_series_plot())
    p
  })

  # Download handler
  output$download_plot_time_series <- downloadHandler(
    filename = function() {
      paste0("time_series_", Sys.Date(), ".png")
    },
    content = function(file) {
      p <- req(time_series_plot())
      ggsave(file, plot = p, width = 8, height = 5, dpi = 600)
    }
  )

  # UI stuff for regression lines (select category)
  observe({
    req(data_time_filtered())

    categories <- unique(data_time_filtered()$type)

    updateCheckboxGroupInput(
      session,
      "types_for_regression",
      choices = categories,
      selected = categories   # optional
    )
  })


# ------------------------------------------------------------
# Corpus description: qty type # -----------------------------
# ------------------------------------------------------------

  # Number of words per type
  qty_plot <- reactive({
    req(working_df())
    df <- working_df()

    # Precompute counts & percentages
    tbl <- df %>%
      count(type) %>%
      arrange(desc(n)) %>%                     # order by count
      mutate(
        type = factor(type, levels = type),   # preserve order in plot
        pct  = scales::percent(n / sum(n), accuracy = 1)
      )
    
    if (input$qty_labels == "Raw number") {
      qty_label <- tbl$n
    } else {
      qty_label <- tbl$pct
    }

    # Small x offset so labels sit just right of the y-axis
    x_offset <- max(tbl$n, na.rm = TRUE) * 0.01

    # Plot (horizontal bars)
    p <- ggplot(tbl, aes(y = type, x = n)) +
      # geom_col() +
      theme_classic() +
      ggtitle(input$plot_title_qty) +
      labs(y = input$y_title_qty, x = input$x_title_qty) +
      scale_x_continuous(expand = expansion(mult = c(0, 0.03))) # small right padding

    # Labels on the left of the bars
    if (input$qty_labels == "Raw number" || input$qty_labels == "Rate (%)") {
      p <- p +
        geom_text(
          data = tbl,
          aes(y = type, label = qty_label),
          x = x_offset,         # fixed x position just to the right of axis
          inherit.aes = FALSE,  # use the mapping we supply here
          hjust = 0,            # left-align text at x
          colour = "black"
        )
      p <- p + geom_col()
      p <- p +
        geom_text(
          data = tbl,
          aes(y = type, label = qty_label),
          x = x_offset,         # fixed x position just to the right of axis
          inherit.aes = FALSE,  # use the mapping we supply here
          hjust = 0,            # left-align text at x
          colour = "white",
          alpha=0.8
        )
    } else {
      p <- p + geom_col()
    }

    p
  })

  # Display handler
  output$qty_plot_preview <- renderPlot({
    p <- req(qty_plot())
    p
  })

  # Download handler
  output$download_qty_plot <- downloadHandler(
    filename = function() {
      paste0("qty_plot_", Sys.Date(), ".png")
    },
    content = function(file) {
      p <- req(qty_plot())
      ggsave(file, plot = p, width = 8, height = 5, dpi = 600)
    }
  )

# ------------------------------------------------------------
# Corpus description: text size # ----------------------------
# ------------------------------------------------------------

  # Second : number of words per text
    # Summarize counts per text
    counts_size <- reactive({
      text_id_col <- req(input$text_id_col)
      req(working_df())
      df <- working_df()

      # Trim leading spaces in the selected column
      df[[text_id_col]] <- sub("^\\s+", "", df[[text_id_col]])

      df <- df %>%
        group_by(std_date, .data[[text_id_col]]) %>%
        summarise(n = n(), .groups="drop")

      df
    })

    observe({
  df <- counts_size()     # triggers when counts_size() changes
  req(df)

  df
})

  # Plot it!
  size_plot <- reactive({
    label_col <- req(input$qty_2_labels)
    req(counts_size())
    df <- counts_size()
    p <- ggplot(df, aes(x=std_date, y = n)) +
      # geom_col() +
      theme_classic() +
      ggtitle(input$plot_title_size) +
      labs(y = input$y_title_size, x = input$x_title_size)

    # Conditionally add labels
    if (input$qty_2_labels != "None") {
      p <- p + geom_label(aes(label = .data[[input$qty_2_labels]], y=0.5),
                        position = position_stack(0.9),
                        vjust = 0.5,
                        hjust = 0,
                        angle = 90,
                        size = 3,
                        text.color="black",
                        fill = NA,
                        colour = NA)
      p <- p + geom_col(color="white")
      p <- p + geom_label(aes(label = .data[[input$qty_2_labels]], y=0.5),
                        position = position_stack(0.9),
                        vjust = 0.5,
                        hjust = 0,
                        angle = 90,
                        size = 3,
                        text.colour=alpha("white", 0.7),
                        fill = NA,
                        colour = NA)
      # expand y-axis so labels don't get cut off
      # scale_y_continuous(expand = expansion(mult = c(0, 0.2)))  # 10% extra on top
    } else {
      p <- p + geom_col(color="white")
    }

    # p <- p + geom_col()
  
  p
  })

  # Display handler
  output$size_plot_preview <- renderPlot({
    p <- req(size_plot())
    p
  })

  # Download handler
  output$download_size_plot <- downloadHandler(
    filename = function() {
      paste0("size_plot_", Sys.Date(), ".png")
    },
    content = function(file) {
      p <- req(size_plot())
      ggsave(file, plot = p, width = 8, height = 5, dpi = 600)
    }
  )

  observe({
    req(counts_size())  # wait until df() exists

    updateSelectInput(
      session,
      "qty_2_labels",
      choices = c("None", colnames(counts_size())),
      selected = "None"
    )
  })

# ------------------------------------------------------------
# Mapping by text: textograms # ------------------------------
# ------------------------------------------------------------

  # Prepare data
  # 1. Split df in one df per text
  split_dfs <- reactive({
    req(working_df(), input$text_id_col)
    df <- working_df()
    
    # Use the selected column name
    col <- input$text_id_col
    
    # Split into list of dataframes
    dfs_list <- split(df, df[[col]])
    
    return(dfs_list)
  })

  # 2. Apply data_for_length + compute_length to each split df
  data_length_list <- reactive({
    dfs <- split_dfs()
    req(dfs, input$position_col)
    # preserve names so we can label outputs
    l <- lapply(dfs, function(d) {
      d1 <- data_for_length(d, input$position_col)
      compute_length(d1, input$position_col)
    })
    # ensure it's a named list (split should already name it)
    if (is.null(names(l))) names(l) <- seq_along(l)
    l
  })

  # --------- UI stuff: rendering tables ---------
    # 1. Update dropdown choices dynamically
    observe({
      dats <- data_length_list()
      req(dats)
      updateSelectInput(
        session,
        "selected_group",
        choices = names(dats),
        selected = names(dats)[1]
      )
    })

    # 2. Render the selected DT table
    output$length_table <- DT::renderDT({
      req(input$selected_group)
      dats <- data_length_list()
      tbl <- dats[[input$selected_group]]
      req(tbl)
      
      DT::datatable(
        tbl,
        options = list(
          pageLength = 10,
          lengthMenu = c(5, 10, 25, 50),
          scrollX = TRUE,
          autoWidth = TRUE
        ),
        rownames = FALSE,
        selection = "single",
        filter = "top"
      ) %>%
        if ("length" %in% names(tbl)) DT::formatRound(., columns = "length", digits = 3) else .
    })

  # Populate UI for col for labels
  output$label_col_ui <- renderUI({
    df <- counts_size()      # call reactive

    selectInput(
      "label_col",
      "Column for labels:",
      choices = names(df)
    )
  })
    # ------------------------------------------

# 1) global set of types
all_types <- reactive({
  req(data_length_list())
  dats <- data_length_list()
  types <- unique(unlist(lapply(dats, function(d) as.character(d$type))))
  sort(types)
})

# 2) fixed named color vector
#   if (tolower(input$color_scale_map) == "viridarchivu") {
  # p <- p + scale_fill_manual(values = c("background" = "gray",
  #     setNames(viridis_pal(end = 0.8)(length(unique(df$type))),
  #     unique(df$type))))
# } else {
#   # Standard viridis palette
#   p <- p + scale_fill_viridis_d(option = tolower(input$color_scale))
# }


global_colors <- reactive({
  types <- all_types()
  if (tolower(input$color_scale_map) == "viridarchivu") {
    cols <- viridis::viridis(n = length(types), option = "D", begin = 0, end = 0.8)
  } else {
    cols <- viridis::viridis(n = length(types), option = tolower(input$color_scale_map))
  }
  cols_named <- setNames(cols, types)
  
  # ---- Override a specific type (i.e., "background") ----
  if (tolower(input$color_scale_map) == "viridarchivu") {
    special_type <- "background"
    special_color <- "gray"

    # If the type already exists, just override it
    if (special_type %in% names(cols_named)) {
      cols_named[special_type] <- special_color

    # If the type does NOT exist in the palette yet (rare but possible),
    # add it at the front so that scale_color_manual sees it.
    } else {
      cols_named <- c(setNames(special_color, special_type), cols_named)
    }
  }

  cols_named
})

# 3) plots_list uses same mapping for all plots
maps_list <- reactive({
  req(data_length_list())
  dats <- data_length_list()
  types <- all_types()

    # ---- compute dates first, for ordering multi-plot ----
    get_std_date <- function(d) {
      if (!"std_date" %in% names(d)) return(as.Date(NA))
      v <- d$std_date[1]
      if (is.null(v) || is.na(v)) return(as.Date(NA))
      if (inherits(v, "Date")) return(v)
      if (inherits(v, "POSIXt")) return(as.Date(v))
      if (is.numeric(v)) return(as.Date(v, origin = "1970-01-01"))
      parsed <- lubridate::parse_date_time(as.character(v),
                                          orders = c("Ymd HMS","Ymd HM","Ymd","ymd","dmy","mdy",
                                                      "Y-m-d","d/m/Y","m/d/Y","d-b-Y"),
                                          quiet = TRUE)
      if (all(is.na(parsed))) return(as.Date(NA))
      as.Date(parsed)
    }

      dates <- vapply(dats, get_std_date, FUN.VALUE = as.Date(NA))
      ord <- order(dates, na.last = TRUE, decreasing = FALSE)
      names_ordered <- names(dats)[ord]
  
  ml <- lapply(names_ordered, function(name) {
    df <- dats[[name]]
    
    # Add dummy rows for missing types
    missing_types <- setdiff(types, df$type)
    if (length(missing_types) > 0) {
      dummy <- df[rep(1, length(missing_types)), , drop = FALSE]
      dummy[] <- NA
      dummy$type <- missing_types
      dummy$first_index <- 0
      dummy$length <- 0
      df <- rbind(df, dummy)
    }
    
    # Force factor levels
    df$type <- factor(df$type, levels = types)
    
    ggplot(df, aes(y = 1, fill = type)) +
      geom_rect(aes(
        xmin = first_index,
        xmax = first_index + length,
        ymin = 0,
        ymax = 1
      ), color = "#FFFFFF50", linewidth = 0.1) +
      scale_x_continuous("Texte") +
      scale_y_continuous(limits = c(0, 1)) +
      ggtitle(name) +
      theme_void() +
      theme(legend.position = "none")
  })
  
  names(ml) <- names_ordered
  ml
})


# Reactive for the currently displayed map
current_map <- reactive({
  req(maps_list(), input$selected_map, global_colors())
  ml <- maps_list()
  cols <- global_colors()
  legend_breaks <- names(cols)
  legend_breaks <- legend_breaks[legend_breaks != ""]

  if (identical(input$selected_map, "All")) {
    patchwork::wrap_plots(ml, ncol = 1) +
      patchwork::plot_layout(guides = "collect") &
      scale_fill_manual(values = cols, breaks = legend_breaks, drop = FALSE) &
      theme(legend.position = "bottom")
  } else {
    req(input$selected_map %in% names(ml))
    ml[[input$selected_map]] +
      scale_fill_manual(values = cols, breaks = legend_breaks, drop = FALSE) &
      theme(legend.position = "bottom")
  }
})

# Render map in UI
output$selected_map_plot <- renderPlot({
  req(current_map())
  print(current_map())
})

# Download button
output$download_map <- downloadHandler(
  filename = function() {
    if (is.null(input$selected_map) || input$selected_map == "All") {
      paste0("map_all_", Sys.Date(), ".png")
    } else {
      paste0("map_", input$selected_map, "_", Sys.Date(), ".png")
    }
  },
  content = function(file) {
    req(current_map())
    p <- current_map()
    # For multiple maps combined with patchwork, explicitly open a PNG device
    if (identical(input$selected_map, "All")) {
      n_maps <- length(maps_list())
      png(file, width = 2000, height = 150 * n_maps, res = 300)
      print(p)   # explicitly print the patchwork object to the device
      dev.off()
    } else {
      ggsave(file, plot = p, width = 10, height = 3, dpi = 300)
    }
  }
)

# Dynamic selectInput for maps
observe({
  ml <- maps_list()
  req(ml)
  choices <- c("All", names(ml))
  selected <- if (!is.null(input$selected_map) && input$selected_map %in% choices) {
    input$selected_map
  } else {
    "All"
  }
  updateSelectInput(
    session,
    "selected_map",
    choices = choices,
    selected = selected
  )
})

#Populate drop down button
observe({
  ml <- maps_list()   # reactive
  req(ml)
  
  choices <- c("All", names(ml))
  selected <- if (!is.null(input$selected_map) && input$selected_map %in% choices) {
    input$selected_map
  } else {
    "All"
  }
  
  updateSelectInput(
    session,
    "selected_map",
    choices = choices,
    selected = selected
  )
})

}
