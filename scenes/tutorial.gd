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
			_start_auto_advance(1, 10.0)

func _advance_step(from_step: int) -> void:
	if tutorialstep != from_step:
		return
	match from_step:
		1:
			tutorialstep = 2
			$AnimationPlayer.play("step1finished")
			_start_auto_advance(2, 10.0)
		2:
			tutorialstep = 3
			$AnimationPlayer.play("step2finished")
			_start_auto_advance(3, 10.0)
		3:
			tutorialstep = 4
			$AnimationPlayer.play("step3finished")
			_start_auto_advance(4, 10.0)
		4:
			tutorialstep = 5
			$AnimationPlayer.play("step4finished")
			await get_tree().create_timer(4.0).timeout
			tutorialstep = 6
			$AnimationPlayer.play("step5finished")
			await get_tree().create_timer(4.0).timeout
			tutorialstep = 7
			UserInterface.hasdonetutorial = true
			$AnimationPlayer.play("step6finished")

func _start_auto_advance(step: int, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	_advance_step(step)

func _input(event: InputEvent) -> void:
	if !UserInterface.hasdonetutorial and _can_progress_tutorial:
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			_advance_step(1)
		if Input.is_action_just_pressed("interact"):
			_advance_step(2)
		if Input.is_action_just_pressed("select_slot_2"):
			_advance_step(3)
		if Input.is_action_just_pressed("attack"):
			_advance_step(4)
