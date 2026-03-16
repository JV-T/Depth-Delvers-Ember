extends CanvasLayer
const SLOT_SIZE = 80
const MARGIN = 20
const SPACING = 10
const NORMAL_BORDER = Color(0.2, 0.85, 0.35, 1.0)
const SELECTED_BORDER = Color(1.0, 0.85, 0.0, 1.0)

var weapon_icon: TextureRect
var powerup_icons: Array = []
var powerup_panels: Array = []
var powerup_vboxes: Array = []
var arrow_label: Label
var timer_container: VBoxContainer
var timer_labels: Dictionary = {}  # potion_name -> Label
var selected_slot: int = 0
var _f_was_pressed: bool = false

func _ready() -> void:
	layer = 10
	var container = HBoxContainer.new()
	container.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	container.position = Vector2(MARGIN, -(MARGIN + SLOT_SIZE + 28))
	container.add_theme_constant_override("separation", SPACING)
	add_child(container)
	var weapon_vbox = _make_slot("WEAPON", Color(0.25, 0.5, 1.0, 1.0))
	container.add_child(weapon_vbox)
	weapon_icon = weapon_vbox.get_meta("icon")
	for i in range(2):
		var pu_vbox = _make_slot("ITEM " + str(i + 1), NORMAL_BORDER, str(i + 1), 20)
		container.add_child(pu_vbox)
		powerup_icons.append(pu_vbox.get_meta("icon"))
		powerup_panels.append(pu_vbox.get_meta("panel"))
		powerup_vboxes.append(pu_vbox)

	# Timer display above inventory
	timer_container = VBoxContainer.new()
	timer_container.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	timer_container.position = Vector2(MARGIN, -(MARGIN + SLOT_SIZE + 70))
	timer_container.add_theme_constant_override("separation", 4)
	add_child(timer_container)

	# Arrow indicator above the selected slot
	arrow_label = Label.new()
	arrow_label.text = "↓"
	arrow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow_label.add_theme_font_size_override("font_size", 18)
	arrow_label.add_theme_color_override("font_color", SELECTED_BORDER)
	add_child(arrow_label)
	_update_highlight()

func _make_slot(label_text: String, border_color: Color, keybind: String = "", icon_padding: int = 8) -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	var label = Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(label)
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.88)
	style.border_color = border_color
	style.set_border_width_all(3)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	panel.add_theme_stylebox_override("panel", style)
	var icon = TextureRect.new()
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.offset_left = icon_padding
	icon.offset_top = icon_padding
	icon.offset_right = -icon_padding
	icon.offset_bottom = -icon_padding
	panel.add_child(icon)
	vbox.add_child(panel)
	if keybind != "":
		var key_label = Label.new()
		key_label.text = "[" + keybind + "]"
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key_label.add_theme_font_size_override("font_size", 12)
		key_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
		vbox.add_child(key_label)
	vbox.set_meta("icon", icon)
	vbox.set_meta("panel", panel)
	return vbox


func _process(_delta: float) -> void:
	if get_tree().paused:
		return
	if Input.is_action_just_pressed("select_slot_1"):
		selected_slot = 0
		_update_highlight()
	elif Input.is_action_just_pressed("select_slot_2"):
		selected_slot = 1
		_update_highlight()
	var f_down = Input.is_key_pressed(KEY_F)
	if f_down and not _f_was_pressed:
		_consume_selected()
	_f_was_pressed = f_down
	_update_timers()


func _update_highlight() -> void:
	for i in range(powerup_panels.size()):
		var panel = powerup_panels[i]
		var style = panel.get_theme_stylebox("panel") as StyleBoxFlat
		if i == selected_slot:
			style.border_color = SELECTED_BORDER
		else:
			style.border_color = NORMAL_BORDER
	# Position the arrow above the selected slot
	if arrow_label and powerup_vboxes.size() > selected_slot:
		await get_tree().process_frame
		var vbox = powerup_vboxes[selected_slot]
		var panel = powerup_panels[selected_slot]
		var panel_center_x = vbox.global_position.x + panel.position.x + SLOT_SIZE / 2.0
		arrow_label.position = Vector2(panel_center_x - 10, vbox.global_position.y - 22)


func _update_timers() -> void:
	# Add labels for new active timers
	for potion_name in UserInterface.active_timers:
		if not timer_labels.has(potion_name):
			var label = Label.new()
			label.add_theme_font_size_override("font_size", 14)
			label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))
			label.add_theme_constant_override("outline_size", 2)
			label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
			timer_container.add_child(label)
			timer_labels[potion_name] = label
	# Update or remove labels
	var to_remove: Array = []
	for potion_name in timer_labels:
		if UserInterface.active_timers.has(potion_name):
			var timer = UserInterface.active_timers[potion_name]
			var secs = ceil(timer.time_left)
			timer_labels[potion_name].text = potion_name + "  " + str(int(secs)) + "s"
		else:
			timer_labels[potion_name].queue_free()
			to_remove.append(potion_name)
	for key in to_remove:
		timer_labels.erase(key)


func _consume_selected() -> void:
	if UserInterface.powerups[selected_slot] != null:
		var item = UserInterface.powerups[selected_slot]
		UserInterface.activate_powerup(item)
		UserInterface.powerups[selected_slot] = null
		refresh()
		PromptUI.show_prompt(item.name + " activated!", false)
		await get_tree().create_timer(1.5).timeout
		PromptUI.hide_prompt()


func refresh() -> void:
	if UserInterface.weapon != null:
		weapon_icon.texture = load(UserInterface.weapon.texture_path)
	else:
		weapon_icon.texture = null

	for i in range(2):
		if UserInterface.powerups[i] != null:
			var item = UserInterface.powerups[i]
			if item.has("texture"):
				powerup_icons[i].texture = item["texture"]
			elif item.has("texture_path"):
				powerup_icons[i].texture = load(item.texture_path)
		else:
			powerup_icons[i].texture = null


func restart() -> void:
	weapon_icon.texture = null
	for icon in powerup_icons:
		icon.texture = null
	for label in timer_labels.values():
		label.queue_free()
	timer_labels.clear()
