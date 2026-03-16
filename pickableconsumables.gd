extends Node2D

const ANIM_SHEET = preload("res://Power Ups/platformer items - free assets/animated_items.png")
const OXYGEN_TANK_TEX = preload("res://OxygenTankNew.png")
const STRENGTH_POTION_TEX = preload("res://StrengthPotionNew.png")

# Gold sparkle animation from animated_items.png, row 8 (y=256), 8 frames of 32x32
const SPEED_FRAMES = [
	Rect2(0, 256, 32, 32),
	Rect2(32, 256, 32, 32),
	Rect2(64, 256, 32, 32),
	Rect2(96, 256, 32, 32),
	Rect2(128, 256, 32, 32),
	Rect2(160, 256, 32, 32),
	Rect2(192, 256, 32, 32),
	Rect2(224, 256, 32, 32),
]
const SPEED_FRAME_RATE = 0.1  # 10 fps

const CONSUMABLES = [
	{"name": "Oxygen Tank", "type": "powerup"},
	{"name": "Speed Potion", "type": "powerup"},
	{"name": "Damage Potion", "type": "powerup"},
]

var item_data: Dictionary = {}
var player_in_range: bool = false
var speed_frame: int = 0
var speed_frame_timer: float = 0.0


func _make_speed_texture() -> AtlasTexture:
	var tex = AtlasTexture.new()
	tex.atlas = ANIM_SHEET
	tex.region = SPEED_FRAMES[speed_frame]
	return tex


func _apply_texture() -> void:
	match item_data.name:
		"Oxygen Tank":
			$"item sprite".texture = OXYGEN_TANK_TEX
		"Speed Potion":
			$"item sprite".texture = _make_speed_texture()
		"Damage Potion":
			$"item sprite".texture = STRENGTH_POTION_TEX
	item_data["texture"] = $"item sprite".texture


func _ready() -> void:
	item_data = CONSUMABLES[randi_range(0, CONSUMABLES.size() - 1)].duplicate()
	_apply_texture()
	$"item sprite".scale = Vector2(0.5, 0.5)
	$"item sprite/AnimationPlayer".play("open")

	var area = Area2D.new()
	area.name = "PickupArea"
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 40.0
	shape.shape = circle
	area.add_child(shape)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	add_child(area)


func _prompt_text() -> String:
	var already_have = (UserInterface.powerups[0] != null and UserInterface.powerups[0].name == item_data.name) \
		or (UserInterface.powerups[1] != null and UserInterface.powerups[1].name == item_data.name)
	var slot_full = UserInterface.powerups[0] != null and UserInterface.powerups[1] != null

	if already_have:
		return item_data.name + "  [Already have this]"
	elif slot_full:
		return item_data.name + "  —  Swap"
	else:
		return item_data.name + "  —  Pick Up"


func _already_have() -> bool:
	return (UserInterface.powerups[0] != null and UserInterface.powerups[0].name == item_data.name) \
		or (UserInterface.powerups[1] != null and UserInterface.powerups[1].name == item_data.name)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "miner":
		player_in_range = true
		PromptUI.show_prompt(_prompt_text())


func _on_body_exited(body: Node2D) -> void:
	if body.name == "miner":
		player_in_range = false
		PromptUI.hide_prompt()


func _process(delta: float) -> void:
	# Animate speed potion glow
	if item_data.get("name") == "Speed Potion":
		speed_frame_timer += delta
		if speed_frame_timer >= SPEED_FRAME_RATE:
			speed_frame_timer = 0.0
			speed_frame = (speed_frame + 1) % SPEED_FRAMES.size()
			$"item sprite".texture = _make_speed_texture()

	if player_in_range and Input.is_action_just_pressed("interact"):
		if _already_have():
			return
		var old_item = UserInterface.swap_item(item_data)
		InventoryUI.refresh()

		if old_item.is_empty():
			PromptUI.show_prompt("Press 1/2 to select slot, F to consume", false)
			$"item sprite".visible = false
			player_in_range = false
			queue_free()
		else:
			item_data = old_item
			speed_frame = 0
			speed_frame_timer = 0.0
			_apply_texture()
			PromptUI.show_prompt(_prompt_text())
