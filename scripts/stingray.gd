extends CharacterBody2D

const SPEED = 110.0
const DAMAGE_PER_SECOND = 8.0
const VERTICAL_AMPLITUDE = 30.0
const VERTICAL_SPEED = 0.7

var _direction: float = 1.0
var _time: float = 0.0
var _player_contact: bool = false
var _player=null
@export var enemyhealth = 100

func _ready() -> void:
	
	enemyhealth = int(enemyhealth * pow(1.25, UserInterface.level))
	$ProgressBar.max_value = enemyhealth
	# Randomise start time and direction so each stingray feels independent
	_time = randf() * TAU
	_direction = 1.0 if randf() > 0.5 else -1.0
	$Sprite2D.flip_h = _direction < 0.0
	$HurtArea.body_entered.connect(_on_body_entered)
	$HurtArea.body_exited.connect(_on_body_exited)
func _on_body_entered(body: Node2D) -> void:
	if body.name == "miner":
		_player_contact = true
		_player = body
		
func _physics_process(delta: float) -> void:
	_time += delta
	# Gliding horizontal patrol with gentle sine-wave vertical drift
	var drift = sin(_time * VERTICAL_SPEED) * VERTICAL_AMPLITUDE
	velocity = Vector2(_direction * SPEED, drift)
	move_and_slide()

	# Reverse on wall hit
	if is_on_wall():
		_direction *= -1
		$Sprite2D.flip_h = _direction > 0.0

func _process(delta: float) -> void:
	$ProgressBar.value = enemyhealth
	if _player_contact and !$GPUParticles2D2.emitting and $Timer.is_stopped():
		$GPUParticles2D2.emitting = true
		$Timer.start()
		GlobalWorldEnvironment.get_node("zap").zapeffect()
		$AudioStreamPlayer2.play()
		UserInterface.shakeamount += 50
		UserInterface.knockback = -10
		UserInterface.oxygen -= DAMAGE_PER_SECOND
		
func _on_body_exited(body: Node2D) -> void:
	if body.name == "miner":
		_player_contact = false


func _on_hurt_area_area_entered(area: Area2D) -> void:
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
			UserInterface.oxygen += 20
			UserInterface.shakeamount += 80
			$AnimationPlayer.play("death")
			if UserInterface.oxygen > 100:
				UserInterface.oxygen = 100
