extends CanvasLayer

func _ready() -> void:
	_update_visibility()
	
	# If UserInterface is available, listen for changes
	if UserInterface:
		# We'll check the setting in _process to ensure it updates when changed
		pass

func _process(_delta: float) -> void:
	# Check if the setting has changed and update visibility
	_update_visibility()

func _update_visibility() -> void:
	if UserInterface:
		visible = UserInterface.world_environment_enabled
		
		
