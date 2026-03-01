@tool
class_name BallUI
extends Control

func _ready() -> void:
	_update_color(color)

@export var color: Color:
	set(value):
		color = value
		_update_color(value)
	get:
		return color

func _update_color(c: Color):
	if not is_inside_tree():
		return
	%Ball.color = c
