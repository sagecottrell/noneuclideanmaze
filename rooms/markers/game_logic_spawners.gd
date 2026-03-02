class_name GameLogicSpawners
extends Node3D

func set_elements(ball: Color, ped: Color):
	if ball == Color.BLACK:
		remove_child($BallSpawn)
	else:
		$BallSpawn/Ball.color = ball
	if ped == Color.BLACK:
		remove_child($BallPedestal)
	else:
		$BallPedestal.color = ped

func _on_ball_interactable_area_entered(area: Area3D) -> void:
	if area.name == "PlayerInteraction" and $BallSpawn.has_ball():
		GlobalSignals.look_at_ball($BallSpawn)

func _on_ball_interactable_area_exited(area: Area3D) -> void:
	if area.name == "PlayerInteraction" and $BallSpawn.has_ball():
		GlobalSignals.look_away_ball($BallSpawn)

func _on_pedestal_interactable_area_entered(area: Area3D) -> void:
	if area.name == "PlayerInteraction" and not $BallPedestal.has_ball():
		GlobalSignals.look_at_ped($BallPedestal)

func _on_pedestal_interactable_area_exited(area: Area3D) -> void:
	if area.name == "PlayerInteraction" and not $BallPedestal.has_ball():
		GlobalSignals.look_away_ped($BallPedestal)
