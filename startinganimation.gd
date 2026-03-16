extends CanvasLayer

@onready var settings_menu: Control = $"settings menu"
var world_environment_checkbox: CheckButton

func _ready() -> void:
	Parallax2d.visible = false
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.frame = 0

func _on_settings_pressed() -> void:
	settings_menu.visible = true
	$Button.hide()
	$Button2.hide()
	$Button3.hide()
	$Button4.hide()
	$ColorPicker.hide()


func _on_settings_back() -> void:
	settings_menu.visible = false
	$Button.show()
	$Button2.show()
	$Button3.show()
	$Button4.show()


func _on_world_env_toggled(toggled_on: bool) -> void:
	if UserInterface:
		UserInterface.world_environment_enabled = toggled_on
	else:
		push_error("UserInterface autoload not found")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	Parallax2d.visible = true
	transition.transition("res://scenes/level.tscn")
	LayerPopup.show_layer(1)


func _on_button_pressed() -> void:
	$buttonclick.play()
	$AnimatedSprite2D.play("default")
	$persononsanmd.play()
	$AnimatedSprite2D/AnimationPlayer.play("startinganimation")


func _on_button_2_pressed() -> void:
	$buttonclick.play()
	$ColorPicker.visible = !$ColorPicker.visible


func _on_color_picker_color_changed(color: Color) -> void:
	var adjusted_color = color
	var brightness = (color.r + color.g + color.b) / 3.0
	if brightness < 0.1:
		adjusted_color = Color(0.15, 0.15, 0.15, color.a)
	
	UserInterface.colorpicked = adjusted_color
	$AnimatedSprite2D.modulate = adjusted_color
