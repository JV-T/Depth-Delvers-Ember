extends Area2D

const DAMAGE_PER_SECOND = 12.0
const BOB_SPEED = 3.0
const BOB_AMPLITUDE = 180.0
const DRIFT_SPEED = 0.5
const DRIFT_RANGE = 400.0

var _player_contact: bool = false
@export var enemyhealth = 100

var _origin: Vector2
var _time: float = 0.0  # added this
var _phase: float = 0.0
var _initialized: bool = false
var _drift_direction: float = 1.0


func _ready() -> void:
	enemyhealth = int(enemyhealth * pow(1.25, UserInterface.level))
	$ProgressBar.max_value = enemyhealth
	_phase = randf() * TAU
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if not _initialized:
		_origin = global_position
		_initialized = true

	_time += delta

	# Update origin's X to drift linearly, bouncing on contact
	_origin.x += _drift_direction * DRIFT_SPEED * delta * 60.0

	global_position.y = _origin.y + sin(_time * BOB_SPEED + _phase) * BOB_AMPLITUDE
	global_position.x = _origin.x  # X is now tracked via _origin directly
	$ProgressBar.value = enemyhealth
	if _player_contact and !$GPUParticles2D2.emitting and $Timer.is_stopped():
		UserInterface.knockback = -10
		$AudioStreamPlayer2.play()
		GlobalWorldEnvironment.get_node("zap").zapeffect()
		UserInterface.oxygen -= DAMAGE_PER_SECOND
		$Timer.start()
		$GPUParticles2D2.emitting = true


func _on_body_entered(body: Node2D) -> void:
	_drift_direction *= -1.0 
	if body.name == "miner":
		_player_contact = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == "miner":
		_player_contact = false


func _on_area_entered(area: Area2D) -> void:
	if area.name == "attackarea" or area.name == "crab_projectile":
		$AudioStreamPlayer3.play()
		$AnimationPlayer.play("hit")
		if area.name == "crab_projectile":
			enemyhealth -= area.damage if "damage" in area else 15
		else:
			enemyhealth -= UserInterface.damage
		UserInterface.shakeamount += 40
		$bloodeffect.emitting = true
		if enemyhealth <= 0:
			GlobalWorldEnvironment.get_node("zap").blood()
			$AudioStreamPlayer.play()
			$AnimationPlayer.play("death")
			UserInterface.shakeamount += 80
			UserInterface.oxygen += 20
			if UserInterface.oxygen > 100:
				UserInterface.oxygen = 100
