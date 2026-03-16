extends Node

var oxygen = 100
var hasdonetutorial = false
var level = 0
var downmeters = 0
var knockback = 0
var shakeamount = 0
var damage = 30
var base_damage = 30
var swing_speed = 1.0
var speed_multiplier = 1.0
var damage_multiplier = 1.0
var active_timers: Dictionary = {}  # "Speed Potion" -> Timer, "Damage Potion" -> Timer
# Inventory: 1 weapon slot, 2 powerup slots
var weapon = null
var powerups = [null, null]
var colorpicked = Color(1, 1, 1, 1)
var world_environment_enabled: bool = true


# Always places the item into its slot. Returns the displaced item (or {} if slot was empty).
func swap_item(item_data: Dictionary) -> Dictionary:
	if item_data.type == "weapon":
		var old = weapon if weapon != null else {}
		weapon = item_data
		base_damage = item_data.get("damage", 30)
		damage = int(base_damage * damage_multiplier)
		swing_speed = item_data.get("swing_speed", 1.0)
		return old
	elif item_data.type == "powerup":
		# Fill an empty slot first
		for i in range(powerups.size()):
			if powerups[i] == null:
				powerups[i] = item_data
				return {}
		# Both slots full — swap slot 0
		var old = powerups[0]
		powerups[0] = item_data
		return old

	return {}


func activate_powerup(item_data: Dictionary) -> void:
	if item_data.name == "Oxygen Tank":
		oxygen = min(oxygen + 50, 100)
	elif item_data.name == "Speed Potion":
		speed_multiplier = 2.0
		_start_timer(15.0, "_on_speed_expire", "Speed Potion")
	elif item_data.name == "Damage Potion":
		damage_multiplier = 1.5
		damage = int(base_damage * damage_multiplier)
		_start_timer(15.0, "_on_damage_expire", "Damage Potion")


func _start_timer(duration: float, callback: String, potion_name: String) -> void:
	# Remove old timer if re-consuming the same potion
	if active_timers.has(potion_name):
		active_timers[potion_name].queue_free()
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(Callable(self, callback))
	timer.timeout.connect(func(): active_timers.erase(potion_name))
	add_child(timer)
	timer.start()
	active_timers[potion_name] = timer


func _on_speed_expire() -> void:
	speed_multiplier = 1.0


func _on_damage_expire() -> void:
	damage_multiplier = 1.0
	damage = base_damage
