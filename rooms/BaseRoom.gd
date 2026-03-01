class_name BaseRoom
extends Node3D

signal hitbox_player_enter(room: BaseRoom, player: Player)
signal hitbox_player_exit(room: BaseRoom, player: Player)

var doors: Array[RoomConnector] = []
var connections: Dictionary[RoomConnector, BaseRoom] = {}

func find_doors() -> void:
	for child in find_children("RoomConnector"):
		if child is Node3D:
			doors.append(child)

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body is Player:
		hitbox_player_enter.emit(self, body)

func _on_hitbox_body_exited(body: Node3D) -> void:
	if body is Player:
		hitbox_player_exit.emit(self, body)


func spawn_player(player: Node3D):
	var spawn = find_child("spawn", false)
	if spawn is Node3D:
		player.global_transform = spawn.global_transform
