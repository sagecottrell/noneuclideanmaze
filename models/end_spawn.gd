class_name EndSpawn
extends Node3D

var balls_collected: Array[Ball] = []

func _format_progress(p: int):
	return "{0}/{1}\norbs placed".format([p, GlobalSignals.MAX_BALLS])

func _ready() -> void:
	GlobalSignals.on_ball_in_pedestal.connect(on_ball_in_pedestal)
	$ExitConditionsDisplay.text = _format_progress(0)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player and balls_collected.size() >= GlobalSignals.MAX_BALLS:
		GlobalSignals.player_exit(body)

func on_ball_in_pedestal(ball: Ball):
	if ball not in balls_collected:
		balls_collected.append(ball)
	
	$ExitConditionsDisplay.text = _format_progress(balls_collected.size())
