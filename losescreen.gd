extends CanvasLayer

var _triggered: bool = false


func _ready() -> void:
	visible = false

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float blur_strength : hint_range(0.0, 10.0) = 2.5;
uniform float darkness : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec2 ps = vec2(1.0) / vec2(textureSize(screen_texture, 0));
	vec4 col = vec4(0.0);
	for (int x = -3; x <= 3; x++) {
		for (int y = -3; y <= 3; y++) {
			col += texture(screen_texture, SCREEN_UV + vec2(float(x), float(y)) * ps * blur_strength);
		}
	}
	col /= 49.0;
	COLOR = vec4(col.rgb * (1.0 - darkness), 1.0);
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	bg.material = mat

	add_child(bg)
	move_child(bg, 0)


func _process(_delta: float) -> void:
	if UserInterface.oxygen <= 0 and not _triggered:
		_triggered = true
		visible = true
		get_tree().paused = true
		$highscore.text = "Score: " + str(UserInterface.downmeters) + "m"
		transition.stop_ambience()
		InventoryUI.visible = false
		PromptUI.hide_prompt()
		PromptUI.visible = false
		var scene := get_tree().current_scene
		if scene:
			var ui := scene.get_node_or_null("User Interface")
			if ui:
				ui.visible = false


func _on_button_pressed() -> void:
	_triggered = false
	UserInterface.oxygen = 100
	UserInterface.level = 0
	UserInterface.weapon = null
	UserInterface.powerups = [null, null]
	UserInterface.damage = 30
	UserInterface.base_damage = 30
	UserInterface.swing_speed = 1.0
	UserInterface.speed_multiplier = 1.0
	UserInterface.damage_multiplier = 1.0
	for child in UserInterface.get_children():
		if child is Timer:
			child.queue_free()
	UserInterface.active_timers.clear()
	InventoryUI.restart()
	transition.transition("res://scenes/level.tscn")
	visible = false
