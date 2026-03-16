extends ProgressBar

var _value_label: Label


func _ready() -> void:
	show_percentage = false
	min_value = 0.0
	max_value = 100.0

	# Tank body — dark navy with a blue border
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.05, 0.08, 0.16, 0.93)
	bg_style.border_color = Color(0.28, 0.52, 0.82, 1.0)
	bg_style.set_border_width_all(3)
	bg_style.corner_radius_top_left = 10
	bg_style.corner_radius_top_right = 10
	bg_style.corner_radius_bottom_left = 10
	bg_style.corner_radius_bottom_right = 10
	add_theme_stylebox_override("background", bg_style)

	# Oxygen fill — bright cyan-blue, left-aligned rounded
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.12, 0.52, 1.0, 0.88)
	fill_style.corner_radius_top_left = 8
	fill_style.corner_radius_top_right = 8
	fill_style.corner_radius_bottom_left = 8
	fill_style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("fill", fill_style)

	# Centred integer label over the bar
	_value_label = Label.new()
	_value_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_value_label.add_theme_font_size_override("font_size", 22)
	_value_label.add_theme_color_override("font_color", Color.WHITE)
	_value_label.add_theme_constant_override("outline_size", 3)
	_value_label.add_theme_color_override("font_outline_color", Color(0.0, 0.08, 0.28, 1.0))
	add_child(_value_label)

	# Small O₂ label above the bar
	var header = Label.new()
	header.text = "O\u2082"
	header.add_theme_font_size_override("font_size", 13)
	header.add_theme_color_override("font_color", Color(0.65, 0.82, 1.0, 0.9))
	header.add_theme_constant_override("outline_size", 2)
	header.add_theme_color_override("font_outline_color", Color(0.0, 0.05, 0.2, 0.8))
	header.position = Vector2(4, -20)
	add_child(header)


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	UserInterface.oxygen -= 1.0 * delta
	UserInterface.oxygen = clampf(UserInterface.oxygen, 0.0, 100.0)
	value = UserInterface.oxygen
	_value_label.text = str(int(UserInterface.oxygen))
