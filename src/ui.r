ui <- page_navbar(
  useShinyjs(),
  title = HTML("ShinyParts"),
  id = "tabselected",
  # title = HTML("ShinyParts: ✨mapping parts of texts✨"),
  # tags$div(style = "text-align: left; color: #888; font-size: 12px; margin-bottom: 10px;",
  #   "Timothée Premat (UPEC, Céditec & MoDyCo), ArchivU project, 2025"
  # ),

  tags$head(
    tags$link(
      rel = "stylesheet",
      href = "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"
    )
  ),

  # sidebarLayout(
  #   sidebarPanel(
    sidebar = accordion(
      id = "accordions_data",
      open = "Data",
        conditionalPanel(
        condition="input.tabselected == 'upload_tab'",
          accordion_panel(
            title = "Load data",
            id = "accordion_load_data",
            fileInput("background",
              label = tooltip(
                trigger = list(
                  "Background CSV",
                  bs_icon("info-circle")
                ),
                HTML("Select a single dataframe containing all words of all texts (used to compute background to your envs)")
              ),
              accept = c(".csv", ".tsv")),
            fileInput("env_files",
              label = tooltip(
                trigger = list(
                  "Environment(s) CSV",
                  bs_icon("info-circle")
                ),
                HTML("Select one or several dataframe(s) containing words belonging to the envs you want to plot")
              ),
              accept = c(".csv", ".tsv"),
              multiple = TRUE),
            ),
          conditionalPanel(
            condition = "output.background_loaded && output.env_data_loaded",
            accordion_panel(
              title = "Set columns",
              id = "accordion_set_cols",
              # p("YYYY, DD-MM-YYYY and DD/MM/YYYY accepted"),
              uiOutput("text_id_col_select"), # Select text-ID column
              uiOutput("position_col_select"), # Select position column
              uiOutput("year_col_select"), # Select year column
              # uiOutput("text_type_col_select"), # Select year column
            ),
            conditionalPanel(
              condition = "output.merged_generated",
              accordion_panel(
                title = "Type selection and nested envs",
                id = "accordion_nested_ens",
                input_switch("deal_with_nested", "Manually set type"),
                # radioButtons("deal_with_nested", "Do you need to deal with nested environments?", choices = c("Yes", "No"), selected = "No"),
                conditionalPanel(
                  condition = "input.deal_with_nested",
                  numericInput("ncols",
                    label = tooltip(
                      trigger = list(
                        "How many columns contain type information?",
                        bs_icon("info-circle")
                      ),
                      HTML("If type information is contained into one col., simply set it to 1. If type information is contained into
                      several cols to represent nesting, set to the number of cols. If several cols. are given, clicking on 'Set type(s)' below will flatten
                      nesting by only keeping the smallest value for each nested env.")
                    ),
                    value = 1, min = 1),
                  uiOutput("col_select_ui"),   # dynamic UI for column selections
                  DTOutput("DT_nesting_depth"),
                  # radioButtons("nesting_strategy", "Select strategy for dealing with nested envs",
                  #   choices = c(
                  #     "Favour depth",
                  #     "Favour surface"),
                  #     selected = "Favour depth (default)"),
                  # helpText("'Favour depth' keeps the deepest non-null level, ignoring higher levels.
                  # 'Favour surface' keeps the highest non-null level."),
                  actionButton("go", "Set type(s)"),
                  # p(HTML("<em>Dealing with nested envs requires you to know the structure of your data.</em>"))
                ),
              ),
            ),
          ),
        ),
    

  div(
    class = "accordion-item",
    div(
      class = "accordion-body",
      conditionalPanel(
        condition="input.tabselected == 'qty_tab'",
          h6("Plot (1): size of envs"),
          textInput("plot_title_qty", "Plot Title", value = "Distribution of types"),
          textInput("x_title_qty", "Horizontal axis title", value = "Size (number of words)"),
          textInput("y_title_qty", "Vertical axis title", value = "Type"),
          # checkboxInput("show_labels_qty", "Show Labels", value = TRUE),
          selectInput("qty_labels",
            "Labels",
            choices = c("Rate (%)", "Raw number", "None"),
            selected = "Rate (%)"
          ),
          downloadButton("download_qty_plot", "Save Plot"),
      ),
      conditionalPanel(
        condition="input.tabselected == 'qty_tab'",
          hr(),
          h6(HTML("Plot (2): size of texts")),
          textInput("plot_title_size", "Plot Title:", value = "Length of texts"),
          textInput("x_title_size", "Horizontal axis title", value = "Year"),
          textInput("y_title_size", "Vertical axis title", value = "Number of words"),
          # checkboxInput("show_labels_size", "Show Labels", value = TRUE),
          #   conditionalPanel(
          #     condition = "input.show_labels_size == true && input.tabselected == 'qty_tab'",
          #     uiOutput("label_col_ui")
          #   ),
          selectInput("qty_2_labels",
            label = "Labels",
            choices = NULL, #Choices are provided by updateSelectInput in server
            selected = "None"
          ),
          downloadButton("download_size_plot", "Save Plot"),
      ),
    )
  ),





    #     accordion_panel(
    #       title = "Plot (1) settings",
    #       id = "qty1",
    #       textInput("plot_title_qty", "Plot Title:", value = "Distribution of types"),
    #       textInput("x_title_qty", "Horizontal axis title", value = "Size (number of words)"),
    #       textInput("y_title_qty", "Vertical axis title", value = "Type"),
    #       checkboxInput("show_labels_qty", "Show Labels", value = TRUE),
    #       downloadButton("download_qty_plot", "Save Plot"),
    #     ),
    #     accordion_panel(
    #       title = "Plot (2) settings",
    #       id = "qty2",
    #       textInput("plot_title_size", "Plot Title:", value = "Length of texts"),
    #       textInput("x_title_size", "Horizontal axis title", value = "Year"),
    #       textInput("y_title_size", "Vertical axis title", value = "Number of words"),
    #       checkboxInput("show_labels_size", "Show Labels", value = TRUE),
    #         conditionalPanel(
    #           condition = "input.show_labels_size == true && input.tabselected == 'qty_tab'",
    #           uiOutput("label_col_ui")
    #         ),
    #       downloadButton("download_size_plot", "Save Plot"),
    #     )     
    # ),

    conditionalPanel(
      condition="input.tabselected == 'time_series_tab'",
        accordion_panel(
          title = "Graphics",
          open = TRUE,
          selectInput("color_scale_time",
            "Color Scale:",
            choices = c("ViridArchivU", "Viridis", "Plasma", "Inferno", "Magma", "Cividis"),
            selected = "ViridArchivU"
          ),
          textInput("plot_title", "Plot Title:", value = "Distribution of types over time"),
          textInput("x_title", "Horizontal axis title", value = "date"),
          textInput("y_title", "Vertical axis title", value = "rate (%)"),
        ),
        accordion_panel(
          title = "Omit/merge types",
          # open = FALSE,
          checkboxGroupInput(
            "omit_types",
            "Omit types:",
            choices = NULL,   # we’ll populate dynamically
            selected = NULL
          ),
          checkboxGroupInput(
            "merge_w_bg",
            "Merge types with background:",
            choices = NULL,   # we’ll populate dynamically
            selected = NULL
          ),
        ),
        accordion_panel(
          title = "Regression",
          # open = FALSE,
          input_switch("regression_ON_OFF", "Add regression line(s)"),
          # selectInput("regression_ON_OFF",
          #   "Add regression line?",
          #   choices = c("No", "Yes"),
          #   selected = "No"),
          conditionalPanel(
            condition = "input.regression_ON_OFF",
              selectInput("regression_method",
                "Regression method:",
                choices = c("lm", "glm", "gam", "loess"),
                selected = "lm"),
              selectInput("regression_se",
                "Show confidence intervals:",
                choices = c("No", "Yes"),
                selected = "No"),
              checkboxGroupInput("types_for_regression", "Fit a line for:", choices = NULL)
          ),
        ),
    ),


    # conditionalPanel(
    #   condition="input.tabselected == 'mapping_tab'",
    #       selectInput("selected_map", "Select map:", choices = "All", selected = "All" ),
    #       downloadButton("download_map", "Save plot"),
    # ),


    div(
      class = "accordion-item",
      div(
        class = "accordion-body",
        conditionalPanel(
          condition="input.tabselected == 'time_series_tab'",
          downloadButton("download_plot_time_series", "Save Plot"),
        ),
        conditionalPanel(
          condition="input.tabselected == 'mapping_tab'",
          selectInput("color_scale_map",
            "Color Scale:",
            choices = c("ViridArchivU", "Viridis", "Plasma", "Inferno", "Magma", "Cividis"),
            selected = "ViridArchivU"
          ),
          selectInput("selected_map", "Select text:", choices = "All", selected = "All" ),
          downloadButton("download_map", "Save plot"),
        ),
      )
    ),
  ),

  # --------- MAIN PANELS -------- #

  nav_panel("Load Data", value="upload_tab",
    # h4("Preview"),
    # DTOutput("DT_nesting_depth"),
    # tags$b("Background Data"),
    card(
      card_header("Background data",
        tooltip(
          bs_icon("info-circle"),
          "This is a preview of the data used as background (i.e.,
          every token of the corpus, independant of wether it is in an env)"
        ),
      ),
      # conditionalPanel(
      #   condition = "bg_preview_exists == null",
      #   p("Load background data (all words of the corpus), using the 'Background CSV' selector.")
      # ),
      # conditionalPanel(
      #   condition = "bg_preview_exists == true",
      #   tableOutput("bg_preview")
      # ),
      uiOutput("bg_preview_ui"),
    ),
    card(
      card_header("Environment(s) data",
        tooltip(
          bs_icon("info-circle"),
          "This is a preview of the data used for your environments
          (i.e., every token of the corpus that will be substracted
          from background and mapped as an env data)"
        ),
      ),
        uiOutput("env_preview_ui"),
    ),
    card(
      card_header("Merged data",
        tooltip(
          bs_icon("info-circle"),
          "This is the data for your whole corpus (i.e., with background
          and env status for each token) "
        ),
      ),
    # tags$b("Merged data (env + background) with flattened nesting"),
      DTOutput("working_df_preview"),
      full_screen = TRUE
    )
    # tags$b("Division Data (may be empty)"),
    # tableOutput("div_preview")
  ),
  nav_panel("Corpus description", value="qty_tab",
    # h4("Number of words per type"),
    card(
      card_header("Plot (1): Size of each environment in the whole corpus"),
      plotOutput("qty_plot_preview"),
    ),
    card(
      card_header("Plot (2): Size of each text in the whole corpus"),
      plotOutput("size_plot_preview"),
      card_footer("In case of stacking (if several texts have identical date), labels might not be displayed properly."),
    ),
  ),
  nav_panel("Time Series", value="time_series_tab",
    # h4("Rate of type by text-date"),
    card(
      card_header("Distribution of types in the corpus"),
      plotOutput("time_series_plot_preview")
    ),
  ),
  nav_panel("Textogram(s)", value="mapping_tab",
    card(
      card_header("Textogram(s)"),
      plotOutput("selected_map_plot", height = "500px", width = "100%"),
      card_footer("Depending on the size of your corpus, loading all textograms can take a while.")
    ),
    # downloadButton("download_map", "Save plot"),
    # h5("Warning: check for overlaps"),
    # p("Please check for overlap (bars stacked on bars in a given plot) in the graphs above.
    # Overlap means that some data belong to several types; in this case, scores of computations
    # might be higher than 100%."),
    # p("This is a default warning, it does not mean there are overlaps in your data."),
    # p("A simple way to avoid overlaps is to make sure your initial queries are exclusive from one another.
    # Background cannot overlap (ShinyParts deleates overlapping line in background)")
  ),
  nav_panel("Explore datasets", value="preview_tab",
    accordion(
      open = "General data",
      accordion_panel(
        "Background and envs tokens",
        DT::dataTableOutput("env_data_merged_preview"),
        p("This table contains all the data of the corpus. Each row corresponds to a token.")
      ),
      accordion_panel(
        "Number of token per type and per text.",
        DT::dataTableOutput("data_time_preview"),
        p("This data is updated following merge/omit filters in the Time Series tab."),
      ),
      accordion_panel(
        "Size of envs per text",
        selectInput(
          "selected_group",
          "Select text:",
          choices = NULL  # will update dynamically in server
        ),
        DT::DTOutput("length_table"),
        p("This table represents every envs for a text, with its length given in the last col.")
      )
    )
  ),
  nav_panel("References", value="ref_tab",
    card(
      h4("References"),
      p(HTML("ShinyParts is an R tool designed to facilitate the study of the location 
  and size of textual sequences — referred to as <em>environments</em> (or 
  <em>envs</em>) — within individual texts or corpora. It provides a graphical 
  user interface (GUI) through Shiny, and runs locally on your computer.<br/>
  ShinyParts was developed by Timothée Premat for the ArchivU project.")),
      p(HTML("To cite ShinyParts, please use the following reference. You may also 
  consider citing the paper in which it was first used (Lethier, Née and Premat 2026).
  <ul>
    <li>Premat, Timothée (2026). <em>ShinyParts: An R tool to map the distribution 
    of environments in texts</em>. 
    <a href='https://github.com/TimotheePremat/ShinyParts' target='_blank'>
    https://github.com/TimotheePremat/ShinyParts</a></li>
    <li>Lethier, Virginie, Émilie Née and Timothée Premat (2026). Des dynamiques 
    entre un genre de discours et un agencement textuel : le cas de la liste dans 
    les rapports d'activité de laboratoire (1970-2018). In <em>Proceedings of the 
    Congrès Mondial de Linguistique Française (CMLF) 2026</em>, Arras.</li>
  </ul>")),
      
      h5("Types of plots"),
      p(HTML("ShinyParts produces the following plots:
  <ul>
    <li>Descriptive corpus-level plots:
      <ul>
        <li>Relative quantity of tokens per environment,</li>
        <li>Size of each text, suitable for longitudinal corpora.</li>
      </ul>
    </li>
    <li>A time series plot showing the evolution of the relative size of 
    environments over time (for longitudinal corpora),</li>
    <li>A <em>textogram</em>: a plot representing the position and size of 
    environments across the length of a text or collection of texts.</li>
  </ul>
  The textogram represents a text as a succession of textual or discursive 
  elements, characterised by their type, location, and length.")),
      
      h5("Background"),
      p(HTML("ShinyParts was developed for the ArchivU project, a collective research 
  enterprise studying administrative records produced in French universities from 
  the 1970s to the present. The ArchivU project was supported by the LabEx 
  <em>Les passés dans le présent</em> (ANR-11-LABX-0026-01). Timothée Premat 
  was a postdoctoral researcher in NLP and corpus linguistics within the project, 
  funded by Université Paris-Est Créteil.<br/>
  ShinyParts originated from the need to visualise the position and extent of 
  lists as discursive devices in laboratory reports, and was designed in 
  collaboration with Virginie Lethier and Émilie Née.")),
      
      h4("Short documentation"),
      h5("Input files"),
      p(HTML("ShinyParts accepts <code>.csv</code> or <code>.tsv</code> (tab-separated) 
  files with the following requirements:")),
      HTML("
  <ul>
    <li>One row per token (typically, one word),</li>
    <li>One column containing a unique text identifier,</li>
    <li>One column containing the position of the token within its text 
    (i.e. its ordinal number),</li>
    <li>One column containing date metadata — if only a year is provided, 
    ShinyParts defaults to January 1st for plotting purposes,</li>
    <li>At least one column containing the environment type of the token.</li>
  </ul>"),
      p(HTML("If the corpus contains nested environments, each level of nesting should 
  be encoded in a separate column (e.g. <code>colA</code> for the type of 
  non-nested environments, <code>colB</code> for the first level of nesting, 
  and so on). ShinyParts can flatten this nested structure by retaining only 
  the deepest available type for each token — so that a token belonging to a 
  <code>typeB</code> environment nested within a <code>typeA</code> environment 
  will be associated with <code>typeB</code> only.")),
      
      h6("Producing input files with TXM"),
      p(HTML("ShinyParts' input format is designed with TXM in mind, one of the standard 
  platforms for (French) textometry. To produce the background and environment 
  dataframes, use the concordancer with an empty query (<code>[]</code>) to 
  retrieve all tokens. Add the relevant metadata to the <code>Reference</code> 
  column, and clear the left and right context fields to reduce file size.<br/>
  For nested environments, include one column per nesting level. Note that TXM 
  (via CWB) appends integers to structural attribute names to indicate nesting 
  depth, but does not append anything to the surface level. For an environment 
  with three nesting levels, the columns should therefore be named 
  <code>env_type</code>, <code>env_type1</code>, and <code>env_type2</code>."))
    )
  ),

theme = bslib::bs_theme(),
  
)
