@tool
class_name Ball
extends Node3D

func _ready() -> void:
	$ColorDisplay.material = StandardMaterial3D.new()
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
	var mat: StandardMaterial3D = $ColorDisplay.material
	mat.albedo_color = c
