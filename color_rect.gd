extends ColorRect

func _process(delta: float) -> void:
	var alpha_value = abs(UserInterface.downmeters) / 100
	if alpha_value > 0.5:
		alpha_value = 0.5
	material.set_shader_parameter("alpha", alpha_value)
