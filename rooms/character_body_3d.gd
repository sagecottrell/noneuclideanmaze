class_name Player
extends CharacterBody3D


@export var jump_speed: float = 4
@export var accel: float = 4
@export var decel: float = 4
@export var walk_speed: float = 4

@onready var head = $head
@onready var camera = $head/PhantomCamera3D

var mouse_sensitivity = 0.002

var last_good_position: Vector3

func _process(delta: float) -> void:
	velocity += get_gravity() * delta
	
	if get_viewport().gui_get_focus_owner() != null:
		return
	
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = jump_speed
	
	var input_dir = Input.get_vector("left", "right", "fwd", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not direction.is_zero_approx():
		velocity.x = move_toward(velocity.x, direction.x * walk_speed, accel)
		velocity.z = move_toward(velocity.z, direction.z * walk_speed, accel)
	else:
		velocity.x = move_toward(velocity.x, 0, decel)
		velocity.z = move_toward(velocity.x, 0, decel)
	
	move_and_slide()
	
	if is_on_floor():
		last_good_position = global_position
	elif global_position.distance_to(last_good_position) > 100:
		global_position = last_good_position
		

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Rotate body horizontally (yaw)
		head.rotate_y(-event.relative.x * mouse_sensitivity)

func teleport(transform: Transform3D):
	global_transform = transform
	last_good_position = transform.origin
