extends CanvasLayer

var tutorialstep = 1
var _can_progress_tutorial = false

func _ready() -> void:
	if has_node("tutorial1"):
		$tutorial1.modulate.a = 0
	
	if !UserInterface.hasdonetutorial:
		await get_tree().create_timer(5.0).timeout
		if !UserInterface.hasdonetutorial: # Double-check in case state changed
			_can_progress_tutorial = true
			if has_node("tutorial1"):
				var t = create_tween()
				t.tween_property($tutorial1, "modulate:a", 1.0, 0.5)

func _input(event: InputEvent) -> void:
	if !UserInterface.hasdonetutorial and _can_progress_tutorial:
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			if tutorialstep == 1:
				tutorialstep = 2
				$AnimationPlayer.play("step1finished")
		if Input.is_action_just_pressed("interact"):
			if tutorialstep == 2:
				tutorialstep = 3
				$AnimationPlayer.play("step2finished")
		if Input.is_action_just_pressed("select_slot_2"):
			if tutorialstep == 3:
				tutorialstep = 4
				$AnimationPlayer.play("step3finished")
		if Input.is_action_just_pressed("attack"):
			if tutorialstep == 4:
				tutorialstep = 5
				UserInterface.hasdonetutorial = true
				$AnimationPlayer.play("step4finished")
