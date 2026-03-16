extends Node2D

var playertouching = false
var opened = false
var pickableitem = preload("res://pickableitems.tscn")
@export var forced_weapon: String = ""


func _ready() -> void:
	$AnimatedSprite2D.frame = 0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "miner":
		playertouching = true
		if not opened:
			PromptUI.show_prompt("Open Chest")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "miner":
		playertouching = false
		PromptUI.hide_prompt()


func _process(_delta: float) -> void:
	if playertouching and Input.is_action_just_pressed("interact") and not opened:
		$AudioStreamPlayer.play()
		var length = $AudioStreamPlayer.stream.get_length()
		if length > 2.0:
			get_tree().create_timer(length - 2.0).timeout.connect($AudioStreamPlayer.stop)
		$AnimatedSprite2D.play("default")
		opened = true
		UserInterface.shakeamount += 50
		PromptUI.hide_prompt()
		$GPUParticles2D.emitting = true
		var pickableinstance = pickableitem.instantiate()
		if forced_weapon != "":
			pickableinstance.forced_weapon_name = forced_weapon
		add_child(pickableinstance)
