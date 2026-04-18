longit_plot <- ggplot(data_length, aes(x = first_index, y = 1, fill = type))

if (var_div %in% c("Y", "y", "yes", "Yes", "O", "o", "Oui", "oui")) {
	longit_plot <- longit_plot +
	geom_vline(data = div_data,
		aes(xintercept = form_id, color=type),
		# color = "gray",
		linewidth = 0.5,
		alpha=0.75)
}

longit_plot <- longit_plot +
	scale_color_grey() +
	geom_bar(stat = "identity", width = data_length$length, just = 0,
	         color = "#FFFFFF50", linewidth = 0.1) +  # HEX with alpha for line color
	scale_x_continuous("Texte") +
	theme_void() +
	theme(legend.position = "bottom") +
    scale_fill_manual(values = c("background" = "gray",
        setNames(viridis_pal(end = 0.8)(length(unique(data_length$type))),
        unique(data_length$type))))
	# geom_vline(data = div1,
	# 	aes(xintercept = form_id),
	# 	color = "black",
	# 	linewidth = 1,
	# 	alpha = 0.5) +
	# scale_fill_manual(values = c("indianred", "palevioletred2", "steelblue"))
	# scale_fill_manual(values = c("indianred", "steelblue"))

# data_reordered <- with(data, reorder(type, median))
pop_plot <- ggplot(data, aes(y = fct_infreq(factor(type)))) +  # Order by count
	geom_bar(fill = "steelblue") +
	geom_text(aes(label = scales::percent((..count..)/sum(..count..), accuracy = 1)),
		stat = "count",
		hjust = 1.5,
		colour = "white") +
	theme_classic() +
	scale_y_discrete("Type") +
	scale_x_continuous("Nb. mots")

# For time-series
selected_types <- c("liste-horiz", "liste-vert")  # Replace with the types you want lines for
time_series <- ggplot(data_time, aes(x=date, y=percentage, fill=type)) +
    geom_area(position = "fill") +
	theme_classic() +
	theme(legend.position = "bottom") +
    scale_fill_manual(values = c("background" = "gray",
        setNames(viridis_pal()(length(unique(data_length$type))),
        unique(data_length$type)))) +
	scale_x_date(breaks = scales::date_breaks("1 year"), labels = scales::date_format("%Y"))

time_series_noNA <- ggplot(data_time_noNA, aes(x=date, y=percentage, fill=type)) +
    geom_area(position = "fill") +
	theme_classic() +
	theme(legend.position = "bottom") +
    scale_fill_manual(values = c("background" = "gray",
        setNames(viridis_pal()(length(unique(data_length$type))),
        unique(data_length$type)))) +
	scale_x_date(breaks = scales::date_breaks("1 year"), labels = scales::date_format("%Y"))

time_series_noNA_lm <- ggplot(data_time_noNA, aes(x=date, y=percentage, fill=type)) +
    geom_area(position = "fill") +
  	geom_smooth(
    	data = filter(data_time_noNA, type %in% selected_types),
    	aes(x = date, y = percentage, color = type, group = type),
    	method = "lm", se = FALSE, inherit.aes = FALSE
  	) +
	theme_classic() +
	theme(legend.position = "bottom") +
    scale_fill_manual(values = c("background" = "gray",
        setNames(viridis_pal()(length(unique(data_length$type))),
        unique(data_length$type)))) +
	scale_x_date(breaks = scales::date_breaks("1 year"), labels = scales::date_format("%Y"))

time_series_noNA_loess <- ggplot(data_time_noNA, aes(x=date, y=percentage, fill=type)) +
    geom_area(position = "fill") +
  	geom_smooth(
    	data = filter(data_time_noNA, type %in% selected_types),
    	aes(x = date, y = percentage, color = type, group = type),
    	method = "loess", se = FALSE, inherit.aes = FALSE
  	) +
	theme_classic() +
	theme(legend.position = "bottom") +
    scale_fill_manual(values = c("background" = "gray",
        setNames(viridis_pal()(length(unique(data_length$type))),
        unique(data_length$type)))) +
	scale_x_date(breaks = scales::date_breaks("1 year"), labels = scales::date_format("%Y"))
