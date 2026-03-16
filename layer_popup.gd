extends CanvasLayer

const LAYER_NAMES = {
	1: "Shallow Seas",
	2: "Twilight Trench",
	3: "Arcane Abyss",
	4: "Eldritch Expanse",
}

const LAYER_DEPTHS = {
	1: "0m — 50m",
	2: "50m — 100m",
	3: "120m — 250m",
	4: "250m+",
}

var _overlay: ColorRect
var _content: Control
var _title_shadow: Label
var _title_label: Label
var _subtitle_label: Label
var _deco_top: Control
var _deco_bottom: Control
var _tween: Tween


func _ready() -> void:
	layer = 20
	visible = false
	_build_ui()
	call_deferred("show_layer", 1)


func _build_ui() -> void:
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Dark vignette — tweened separately so content can be brighter
	_overlay = ColorRect.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_overlay)

	# Content container — tweened independently of overlay
	_content = Control.new()
	_content.set_anchors_preset(Control.PRESET_FULL_RECT)
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.modulate = Color(1, 1, 1, 0)
	root.add_child(_content)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(center)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 14)
	center.add_child(vbox)

	# Top decoration line
	_deco_top = _make_decoration()
	vbox.add_child(_deco_top)

	# Title shadow label (offset, wide glow outline — rendered first so it's behind)
	_title_shadow = Label.new()
	_title_shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_shadow.add_theme_font_size_override("font_size", 72)
	_title_shadow.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 0.0))
	_title_shadow.add_theme_constant_override("outline_size", 22)
	_title_shadow.add_theme_color_override("font_outline_color", Color(0.9, 0.65, 0.1, 0.22))
	vbox.add_child(_title_shadow)

	# Title label (actual text, drawn on top)
	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 72)
	_title_label.add_theme_color_override("font_color", Color(0.96, 0.90, 0.68))
	_title_label.add_theme_constant_override("outline_size", 5)
	_title_label.add_theme_color_override("font_outline_color", Color(0.55, 0.35, 0.05, 1.0))
	_title_label.add_theme_color_override("font_shadow_color", Color(1.0, 0.75, 0.2, 0.45))
	_title_label.add_theme_constant_override("shadow_offset_x", 0)
	_title_label.add_theme_constant_override("shadow_offset_y", 0)

	# Lay the glow shadow directly under title using a MarginContainer trick:
	# instead we just stack them in the same VBox slot via a negative margin overlay
	# Simpler: use a single Control with two labels overlapping
	var title_stack = Control.new()
	title_stack.custom_minimum_size = Vector2(900, 90)
	_title_shadow.free()  # remove from vbox, will re-add into stack

	_title_shadow = Label.new()
	_title_shadow.set_anchors_preset(Control.PRESET_FULL_RECT)
	_title_shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_shadow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_shadow.add_theme_font_size_override("font_size", 72)
	_title_shadow.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 0.0))
	_title_shadow.add_theme_constant_override("outline_size", 24)
	_title_shadow.add_theme_color_override("font_outline_color", Color(1.0, 0.7, 0.1, 0.18))
	title_stack.add_child(_title_shadow)

	_title_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_stack.add_child(_title_label)
	vbox.add_child(title_stack)

	# Bottom decoration line
	_deco_bottom = _make_decoration()
	vbox.add_child(_deco_bottom)

	# Subtitle — depth range, cooler blue-white tone
	_subtitle_label = Label.new()
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.add_theme_font_size_override("font_size", 24)
	_subtitle_label.add_theme_color_override("font_color", Color(0.72, 0.88, 1.0, 0.9))
	_subtitle_label.add_theme_constant_override("outline_size", 3)
	_subtitle_label.add_theme_color_override("font_outline_color", Color(0.1, 0.3, 0.6, 0.9))
	_subtitle_label.add_theme_color_override("font_shadow_color", Color(0.3, 0.6, 1.0, 0.4))
	_subtitle_label.add_theme_constant_override("shadow_offset_x", 0)
	_subtitle_label.add_theme_constant_override("shadow_offset_y", 0)
	vbox.add_child(_subtitle_label)


func _make_decoration() -> Control:
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 10)

	var line_l = ColorRect.new()
	line_l.custom_minimum_size = Vector2(220, 1)
	line_l.color = Color(0.85, 0.68, 0.28, 0.85)

	var diamond = Label.new()
	diamond.text = "◆"
	diamond.add_theme_font_size_override("font_size", 13)
	diamond.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35, 1.0))
	diamond.add_theme_constant_override("outline_size", 3)
	diamond.add_theme_color_override("font_outline_color", Color(0.6, 0.35, 0.05, 0.8))

	var line_r = ColorRect.new()
	line_r.custom_minimum_size = Vector2(220, 1)
	line_r.color = Color(0.85, 0.68, 0.28, 0.85)

	hbox.add_child(line_l)
	hbox.add_child(diamond)
	hbox.add_child(line_r)
	return hbox


func show_layer(layer_num: int, current_depth: String = "") -> void:
	if not LAYER_NAMES.has(layer_num):
		return

	var depth_text = current_depth if current_depth != "" else LAYER_DEPTHS.get(layer_num, "")
	_title_label.text = LAYER_NAMES[layer_num]
	_title_shadow.text = LAYER_NAMES[layer_num]
	_subtitle_label.text = depth_text

	visible = true
	_overlay.color = Color(0, 0, 0, 0)
	_content.modulate = Color(1, 1, 1, 0)

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(true)

	# Fade in: overlay darkens, content brightens
	_tween.tween_property(_overlay, "color", Color(0, 0, 0, 0.6), 1.1) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_content, "modulate", Color(1, 1, 1, 1), 1.4) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# After hold, fade out (sequential chain)
	_tween.chain().tween_interval(2.4)
	_tween.chain().set_parallel(true)
	_tween.tween_property(_content, "modulate", Color(1, 1, 1, 0), 1.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.tween_property(_overlay, "color", Color(0, 0, 0, 0), 1.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.chain().tween_callback(func(): visible = false)
