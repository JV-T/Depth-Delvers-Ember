extends ColorRect

func _process(delta: float) -> void:
	var vhseffect = UserInterface.level
	if vhseffect > 2:
		vhseffect = 2
	material.set_shader_parameter("vhs_intensity", vhseffect)
