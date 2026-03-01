class_name BaseRoom
extends Node3D

signal hitbox_player_enter(room: BaseRoom, player: Player)
signal hitbox_player_exit(room: BaseRoom, player: Player)

var doors: Array[RoomConnector] = []
var connections: Dictionary[RoomConnector, BaseRoom] = {}

func logic_spawners() -> GameLogicSpawners:
	return $GameLogicSpawners

func find_doors() -> void:
	for child in find_children("RoomConnector"):
		if child is Node3D:
			doors.append(child)

func connect_room(room: BaseRoom):
	for door in doors:
		if door not in connections:
			connections[door] = room
			return

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

func set_active_door_count(count: int):
	doors.shuffle()
	while doors.size() > count:
		var extra_door = doors.pop_front()
		var csg = extra_door.get_parent()
		csg.get_parent().remove_child(csg)
