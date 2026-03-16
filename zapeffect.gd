extends ColorRect

func zapeffect() -> void:
	$AnimationPlayer.play("flash")
	
func blood():
	$AnimationPlayer.play("blood")
