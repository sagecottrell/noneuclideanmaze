extends Node3D

@export var starting_room_scenes: Array[PackedScene] = []
@export var all_room_scenes: Array[PackedScene] = []
@export var player_scene: PackedScene

var current_rooms: Array[BaseRoom] = []

var touching_new_room: BaseRoom
var current_room: BaseRoom

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	
	var maze = MazeSetup.setup(20, 4)
	var start_room_id = maze.keys().pick_random()
	
	var rooms: Dictionary[int, BaseRoom] = {}
	var player = player_scene.instantiate()
	add_child(player)
	
	for room_id in maze.keys():
		var scenes = all_room_scenes
		if room_id == start_room_id:
			scenes = starting_room_scenes
		var neighbors = maze[room_id]
		var new_room: BaseRoom = scenes.pick_random().instantiate()
		_setup_new_room(new_room)
		new_room.set_active_door_count(neighbors.size())
		rooms[room_id] = new_room
		if room_id == start_room_id:
			spawn_player.call_deferred(new_room, player)
	
	for room_id in maze.keys():
		for other_id in maze[room_id]:
			rooms[room_id].connect_room(rooms[other_id])
	
	var starting_room = rooms[start_room_id]
	starting_room.position.y = 0
	starting_room.process_mode = Node.PROCESS_MODE_INHERIT
	on_move_to_room(starting_room, player)

func spawn_player(room: BaseRoom, player: Player):
	on_hitbox_player_enter(room, player)
	on_move_to_room(room, player)
	room.spawn_player.call_deferred(player)

func on_hitbox_player_enter(room: BaseRoom, _player: Player):
	prints("hitbox enter", room.name)
	touching_new_room = room

func on_hitbox_player_exit(room: BaseRoom, player: Player):
	prints('hitbox exit', room.name)
	if room == touching_new_room or touching_new_room == null:
		return
	on_move_to_room(touching_new_room, player)

func on_move_to_room(room: BaseRoom, player: Player):
	var new_rooms: Array[BaseRoom] = [room]
	new_rooms.append_array(room.connections.values())
	for croom in current_rooms:
		if croom not in new_rooms:
			croom.position.y = player.position.y - 1000
			croom.process_mode = Node.PROCESS_MODE_DISABLED
	
	for conn: RoomConnector in room.connections:
		var other_room = room.connections[conn]
		var other_door: RoomConnector = other_room.connections.find_key(room)
		_add_child_room.call_deferred(other_room, other_door, conn)
		other_room.process_mode = Node.PROCESS_MODE_INHERIT
	
	room.process_mode = Node.PROCESS_MODE_INHERIT
	current_rooms = new_rooms
	current_room = room
	touching_new_room = null

func _add_child_room(other_room: BaseRoom, other_door: Node3D, conn: Node3D):
	other_room.global_transform = conn.global_transform.rotated_local(Vector3.DOWN, 3.1415) * (other_door.global_transform.affine_inverse() * other_room.global_transform)

func _setup_new_room(new_room: BaseRoom):
	new_room.find_doors()
	add_child(new_room)
	new_room.position.y = -1000
	new_room.process_mode = Node.PROCESS_MODE_DISABLED
	new_room.hitbox_player_enter.connect(on_hitbox_player_enter)
	new_room.hitbox_player_exit.connect(on_hitbox_player_exit)
