extends Node2D

var p1_shots = 0
var p2_shots = 0
var p1_total = 0
var p2_total = 0

var p_turn = 0
signal turn_end

func _ready():
	Master.mode = "mp"
	$AnimationPlayer.play("intro")
	$Player1.move = false
	$Player2.move = false
	$SFX.rect_scale.x = 0
	$SFX2.rect_scale.x = 0
	$CanvasLayer/Label.visible = true
	$CanvasLayer/shots1/slash1.visible = false
	$CanvasLayer/shots2/slash2.visible = false


func _process(delta):
	if $SFX.died:
		$CanvasLayer/Label.text = "Player 2 Wins!"
		$AnimationPlayer.play("win")
	if $SFX2.died:
		$CanvasLayer/Label.text = "Player 1 Wins!"
	if int($Timer.time_left) >= 10:
		$CanvasLayer/Label2.text = "00:" + str(int($Timer.time_left))
	elif int($Timer.time_left) > 0:
		$CanvasLayer/Label2.text = "00:0" + str(int($Timer.time_left))
	else:
		$CanvasLayer/Label2.text = "00:00"
		
	if $Player1.global_position.y > $Player2.global_position.y:
		$Player1.z_index = 3
		$Player2.z_index = 2
	else:
		$Player2.z_index = 3
		$Player1.z_index = 2
	if p_turn > 2:
		if p1_shots >= 10:
			$CanvasLayer/shots1.text = str(p1_shots)
		else:
			$CanvasLayer/shots1.text = "0" + str(p1_shots)
		if p2_shots >= 10:
			$CanvasLayer/shots2.text = str(p2_shots)
		else:
			$CanvasLayer/shots2.text = "0" + str(p2_shots)


func _turn():
	$AnimationPlayer.play("play")
	yield($AnimationPlayer, "animation_finished")
	$CanvasLayer/Label.visible = false
	$CanvasLayer/Label2.visible = true
	$Timer.start()
	while $Timer.time_left > 0:
		randomize()
		$CanvasLayer/Input._show((randi()%5+3))
		yield($CanvasLayer/Input, "word_found")
		if p_turn == 1:
			p1_shots += 1
		elif p_turn == 2:
			p2_shots += 1
		$CanvasLayer/Input._hide()
		yield(get_tree().create_timer(0.5), "timeout")
	emit_signal("turn_end")


func _on_play_pressed():
	$click.play()
	$CanvasLayer/play.visible = false
	$CanvasLayer/instructions.visible = false
	$AnimationPlayer.play("one")
	yield($AnimationPlayer, "animation_finished")
	p_turn = 1
	_turn()
	yield(self, "turn_end")
	$CanvasLayer/Label.text = ""
	$AnimationPlayer.play("two")
	$CanvasLayer/Label.visible = true
	yield($AnimationPlayer, "animation_finished")
	p_turn = 2
	_turn()
	yield(self, "turn_end")
	print(p2_shots)
	p_turn = 3
	$CanvasLayer/Label2.visible = false

	p1_total = p1_shots
	p2_total = p2_shots

	$AnimationPlayer.play("start")
	if p1_total >= 10:
		$CanvasLayer/shots12.text = str(p1_total)
	else:
		$CanvasLayer/shots12.text = "0" + str(p1_total)
	if p2_shots >= 10:
		$CanvasLayer/shots22.text = str(p2_total)
	else:
		$CanvasLayer/shots22.text = "0" + str(p2_total)
#	$CanvasLayer/shots1.visible = true
#	$CanvasLayer/shots12.visible = true
#	$CanvasLayer/shots2.visible = true
#	$CanvasLayer/shots22.visible = true
	yield($AnimationPlayer, "animation_finished")
	$CanvasLayer/Label.visible = false
	$Player1.move = true
	$Player2.move = true


func _on_Timer_timeout():
	$CanvasLayer/Input._end(p_turn)


func _on_instructions_pressed():
	$click.play()
	$CanvasLayer/Label.visible = false
	$CanvasLayer/play.visible = false
	$CanvasLayer/instructions.visible = false
	$CanvasLayer/instr.visible = true
	$CanvasLayer/back.visible = true


func _on_back_pressed():
	$click.play()
	$CanvasLayer/instr.visible = false
	$CanvasLayer/back.visible = false
	$CanvasLayer/Label.visible = true
	$CanvasLayer/play.visible = true
	$CanvasLayer/instructions.visible = true


func _on_back_mouse_entered():
	$AnimationPlayer2.play("backhover")


func _on_back_mouse_exited():
	$AnimationPlayer2.play("RESET")


func _on_back_button_down():
	$AnimationPlayer2.play("backd")
