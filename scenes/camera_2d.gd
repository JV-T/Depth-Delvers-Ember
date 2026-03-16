extends Camera2D

# --- CONFIGURATION ---
@export var offset_factor: float = 0.7  # How far the camera moves toward the cursor (0 = player, 1 = cursor)
@export var smoothing_speed: float = 10.0  # Higher = faster camera movement

# --- REFERENCE ---
@export var player: NodePath  # Drag your player node here in the inspector
var player_node: Node2D

func _ready():
	if player:
		player_node = get_node(player)
	else:
		push_error("Camera2D script: Player node not assigned!")

func _process(delta):
	if not player_node:
		return
	UserInterface.shakeamount *= 0.9
	offset.x += randf_range(-UserInterface.shakeamount, UserInterface.shakeamount)
	offset.y += randf_range(-UserInterface.shakeamount, UserInterface.shakeamount)
	offset.x *= 0.9
	offset.y *= 0.9
	# Get positions
	var player_pos = player_node.global_position
	var mouse_pos = get_global_mouse_position()
	
	# Compute target camera position
	var target_pos = player_pos.lerp(mouse_pos, offset_factor)
	
	# Smoothly move camera toward target
	global_position = global_position.lerp(target_pos, smoothing_speed * delta)


func _on_nextlevel_2_body_entered(body: Node2D) -> void:
	$"../../AnimationPlayer".play("bossfight")
