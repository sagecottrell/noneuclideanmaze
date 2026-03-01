extends Node3D

@export var starting_room_scenes: Array[PackedScene] = []
@export var all_room_scenes: Array[PackedScene] = []
@export var player_scene: PackedScene

var current_rooms: Array[BaseRoom] = []

var touching_rooms: Array[BaseRoom] = []

var balls_carried: Array[Ball] = []
var ball_uis: Dictionary[Ball, BallUI] = {}
var looking_at_ball: BallSpawn
var looking_at_ped: BallPedestal

@export var colors: Array[Color] = []

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	%Hint.text = ""
	GlobalSignals.on_look_at_ball.connect(on_look_at_ball)
	GlobalSignals.on_look_away_ball.connect(on_look_away_ball)
	GlobalSignals.on_look_at_ped.connect(on_look_at_ped)
	GlobalSignals.on_look_away_ped.connect(on_look_away_ped)

	await get_tree().create_timer(0.5).timeout
	
	_on_text_chat_text_submitted("")
	
	var maze = MazeSetup.setup(20, 4)
	
	var special_room_candidates = maze.keys()
	special_room_candidates.shuffle()
	var start_room_id = special_room_candidates.pop_front()
	var end_room_id = special_room_candidates.pop_front()
	
	var ball_rooms = {}
	var ped_rooms = {}
	
	for i in range(GlobalSignals.MAX_BALLS):
		ball_rooms[special_room_candidates.pop_front()] = colors.get(i)
		ped_rooms[special_room_candidates.pop_front()] = colors.get(i)
	
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
		else:
			var logic = new_room.logic_spawners()
			if logic != null:
				logic.set_elements(room_id == end_room_id, ball_rooms.get(room_id, Color.BLACK), ped_rooms.get(room_id, Color.BLACK))
	
	for room_id in maze.keys():
		for other_id in maze[room_id]:
			rooms[room_id].connect_room(rooms[other_id])
	
	var starting_room = rooms[start_room_id]
	starting_room.position.y = 0
	starting_room.process_mode = Node.PROCESS_MODE_INHERIT

func spawn_player(room: BaseRoom, player: Player):
	on_hitbox_player_enter(room, player)
	on_move_to_room(room, player)
	room.spawn_player(player)

func on_hitbox_player_enter(room: BaseRoom, _player: Player):
	prints("hitbox enter", room.name)
	if room not in touching_rooms:
		touching_rooms.append(room)

func on_hitbox_player_exit(room: BaseRoom, player: Player):
	prints('hitbox exit', room.name)
	if room in touching_rooms:
		touching_rooms.erase(room)
	if touching_rooms.size() == 1:
		on_move_to_room(touching_rooms[0], player)

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

func _add_child_room(other_room: BaseRoom, other_door: Node3D, conn: Node3D):
	other_room.global_transform = conn.global_transform.rotated_local(Vector3.DOWN, 3.1415) * (other_door.global_transform.affine_inverse() * other_room.global_transform)

func _setup_new_room(new_room: BaseRoom):
	new_room.find_doors()
	add_child(new_room)
	new_room.position.y = -1000
	new_room.process_mode = Node.PROCESS_MODE_DISABLED
	new_room.hitbox_player_enter.connect(on_hitbox_player_enter)
	new_room.hitbox_player_exit.connect(on_hitbox_player_exit)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_chat"):
		%TextChatContainer.visible = !%TextChatContainer.visible
		if %TextChatContainer.visible:
			%TextChat.grab_focus()
	if event.is_action_pressed("interact"):
		if looking_at_ball != null:
			var ball = looking_at_ball.remove_ball()
			balls_carried.append(ball)
			var ball_ui: BallUI = preload("res://BallUI.tscn").instantiate()
			ball_ui.color = ball.color
			%BallDisplay.add_child(ball_ui)
			ball_uis[ball] = ball_ui
			on_look_away_ball(looking_at_ball)
		if looking_at_ped != null:
			for ball in balls_carried:
				if ball.color == looking_at_ped.color:
					looking_at_ped.show_ball()
					balls_carried.erase(ball)
					on_look_away_ped(looking_at_ped)
					%BallDisplay.remove_child(ball_uis[ball])
					GlobalSignals.ball_in_pedestal(ball)
					break

	# Toggle mouse capture
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_text_chat_text_submitted(new_text: String) -> void:
	%TextChatContainer.visible = false
	%TextChat.release_focus()
	%TextChat.text = ""
	if new_text.length() == 0:
		return
	var new = RichTextLabel.new()
	new.fit_content = true
	new.text = new_text
	%ChatLog.add_child(new)
	while %ChatLog.get_children().size() > 10:
		%ChatLog.remove_child(%ChatLog.get_child(0))

func on_look_at_ball(e: BallSpawn):
	looking_at_ball = e
	%Hint.text = "Pick up orb"
	
func on_look_away_ball(e: BallSpawn):
	if e == looking_at_ball:
		looking_at_ball = null
		%Hint.text = ""
	
func on_look_at_ped(e: BallPedestal):
	looking_at_ped = e
	%Hint.text = "Place orb"
	
func on_look_away_ped(e: BallPedestal):
	if e == looking_at_ped:
		looking_at_ped = null
		%Hint.text = ""


func _on_clear_text_chat_button_pressed() -> void:
	while %ChatLog.get_children().size() > 0:
		%ChatLog.remove_child(%ChatLog.get_child(0))
	_on_text_chat_text_submitted("")
