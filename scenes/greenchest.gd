extends Node2D

var playertouching = false
var opened = false
var pickableitem = preload("res://pickableconsumables.tscn")


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
		$AnimatedSprite2D.play("chest_open")
		opened = true
		PromptUI.hide_prompt()
		$GPUParticles2D.emitting = true
		var pickableinstance = pickableitem.instantiate()
		add_child(pickableinstance)
