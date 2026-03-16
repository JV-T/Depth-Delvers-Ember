extends CanvasLayer

func _ready() -> void:
	_update_visibility()
	
	if UserInterface:
		pass

func _process(_delta: float) -> void:
	_update_visibility()

func _update_visibility() -> void:
	if UserInterface:
		visible = UserInterface.world_environment_enabled
		
		
