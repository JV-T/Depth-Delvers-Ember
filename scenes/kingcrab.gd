extends CharacterBody2D

const SPEED = 110.0

var _player_contact: bool = false
var _player=null
var maxhealth = 100
@export var enemyhealth = 100

func _ready() -> void:
	
	maxhealth = (UserInterface.level * 200) + 100
	enemyhealth = maxhealth
	$ProgressBar.max_value = enemyhealth
	# Randomise start time and direction so each stingray feels independent
	$HurtArea.body_entered.connect(_on_body_entered)
	$HurtArea.body_exited.connect(_on_body_exited)
	
func _process(delta: float) -> void:
	$ProgressBar.value = enemyhealth
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "miner":
		_player_contact = true
		_player = body
		
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
