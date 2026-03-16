extends CanvasLayer

# Screen-space prompt shown when near interactable objects.
# Call show_prompt / hide_prompt from any world node.

var _container: HBoxContainer
var _key_label: Label
var _text_label: Label


func _ready() -> void:
	layer = 15
	visible = false
	_build_ui()


func _build_ui() -> void:
	_container = HBoxContainer.new()
	_container.add_theme_constant_override("separation", 10)

	# Anchor horizontally centred, near the bottom of the screen
	_container.anchor_left = 0.5
	_container.anchor_right = 0.5
	_container.anchor_top = 1.0
	_container.anchor_bottom = 1.0
	_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_container.offset_top = -190
	_container.offset_bottom = -148
	add_child(_container)

	# Key box
	var key_bg = Panel.new()
	key_bg.custom_minimum_size = Vector2(42, 42)

	var key_style = StyleBoxFlat.new()
	key_style.bg_color = Color(0.12, 0.12, 0.18, 0.95)
	key_style.border_color = Color(0.8, 0.8, 0.8, 1.0)
	key_style.set_border_width_all(2)
	key_style.corner_radius_top_left = 6
	key_style.corner_radius_top_right = 6
	key_style.corner_radius_bottom_left = 6
	key_style.corner_radius_bottom_right = 6
	key_bg.add_theme_stylebox_override("panel", key_style)

	_key_label = Label.new()
	_key_label.text = "E"
	_key_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_key_label.add_theme_font_size_override("font_size", 20)
	_key_label.add_theme_color_override("font_color", Color.WHITE)
	key_bg.add_child(_key_label)
	_container.add_child(key_bg)

	# Action text
	_text_label = Label.new()
	_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text_label.add_theme_font_size_override("font_size", 20)
	_text_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))
	_text_label.add_theme_constant_override("outline_size", 3)
	_text_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_container.add_child(_text_label)

	# Pill background behind the whole container
	var bg = Panel.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.offset_left = -14
	bg.offset_right = 14
	bg.offset_top = -6
	bg.offset_bottom = 6
	bg.z_index = -1

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.06, 0.06, 0.10, 0.82)
	bg_style.corner_radius_top_left = 10
	bg_style.corner_radius_top_right = 10
	bg_style.corner_radius_bottom_left = 10
	bg_style.corner_radius_bottom_right = 10
	bg.add_theme_stylebox_override("panel", bg_style)
	_container.add_child(bg)


func show_prompt(text: String, show_key: bool = true) -> void:
	_text_label.text = text
	_key_label.get_parent().visible = show_key
	visible = true


func hide_prompt() -> void:
	visible = false
