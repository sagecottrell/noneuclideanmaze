class_name BallSpawn
extends Node3D

func remove_ball() -> Ball:
	var ball = $Ball
	remove_child(ball)
	return ball

func has_ball() -> bool:
	return find_child("Ball", false) != null
