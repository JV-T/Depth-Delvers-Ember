extends CanvasLayer

var _pause_overlay: ColorRect
var _click_player: AudioStreamPlayer

func _ready() -> void:
	_click_player = AudioStreamPlayer.new()
	_click_player.stream = load("res://freesound_community-item-equip-6904.mp3")
	_click_player.volume_db = -5.0
	add_child(_click_player)

	_pause_overlay = ColorRect.new()
	_pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pause_overlay.visible = false

	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float blur_strength : hint_range(0.0, 10.0) = 2.5;
uniform float darkness : hint_range(0.0, 1.0) = 0.4;

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
	_pause_overlay.material = mat

	add_child(_pause_overlay)
	move_child(_pause_overlay, $Control.get_index())


func transition(scenepath: String) -> void:
	$Control.visible = false
	get_tree().paused = false
	_set_overlay(false)
	InventoryUI.visible = true
	PromptUI.visible = false
	PromptUI.hide_prompt()

	$GPUParticles2D.emitting = true
	$AnimationPlayer.play("fadein")
	await $AnimationPlayer.animation_finished
	$AudioStreamPlayer2.playing = true
	get_tree().change_scene_to_file(scenepath)
	$AnimationPlayer.play_backwards("fadein")
	$AudioStreamPlayer.play()
	if scenepath == "res://scenes/level.tscn":
		LayerPopup.show_layer(1)


func _set_overlay(show: bool) -> void:
	_pause_overlay.visible = show


func stop_ambience() -> void:
	$AudioStreamPlayer.stop()


func _set_paused(paused: bool) -> void:
	_click_player.play()
	get_tree().paused = paused
	$Control.visible = paused
	_set_overlay(paused)

	var scene := get_tree().current_scene
	if paused:
		$AudioStreamPlayer.stop()
		InventoryUI.visible = false
		PromptUI.hide_prompt()
		PromptUI.visible = false
		if scene:
			var ui := scene.get_node_or_null("User Interface")
			if ui:
				ui.visible = false
	else:
		$AudioStreamPlayer.play()
		InventoryUI.visible = true
		PromptUI.visible = false
		PromptUI.hide_prompt()
		if scene:
			var ui := scene.get_node_or_null("User Interface")
			if ui:
				ui.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		var scene := get_tree().current_scene
		if scene and scene.scene_file_path.begins_with("res://scenes/"):
			_set_paused(!get_tree().paused)


func _on_texture_button_pressed() -> void:
	_set_paused(!get_tree().paused)


func _on_button_pressed() -> void:
	_set_paused(false)


func _on_button_2_pressed() -> void:
	transition("res://startinganimation.tscn")
