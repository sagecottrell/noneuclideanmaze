@tool
class_name RoomConnector
extends Node3D

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		DebugDraw3D.draw_arrowhead(global_transform.translated(basis * Vector3.FORWARD), Color.RED)
