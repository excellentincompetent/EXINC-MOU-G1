extends CharacterBody3D

#movement var
@export var SPEED = 5.0
@export var SPRINT_SPEED = 8.0
@export var JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#camera var
@export var MOUSE_SENSITIVITY = 0.003
@export var PITCH_MIN = -60.0
@export var PITCH_MAX = 70.0

@export var CAMERA_YAW_SMOOTHING = 5.0   # lower = more lag/delay, higher = snappier catch-up
@export var CAMERA_HEIGHT = 1.6

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera_yaw: float = 0.0   # tracks the camera's own smoothed yaw, separate from body

#animation var
signal movement_updated(input_dir: Vector2, is_sprinting: bool)

#code 
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_yaw = rotation.y
	spring_arm.rotation.y = camera_yaw

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		spring_arm.rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(PITCH_MIN), deg_to_rad(PITCH_MAX))
	
	if event.is_action_pressed("ui_cancel"):   # Escape by default
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var current_speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
	
	#signal for animation
	movement_updated.emit(input_dir, Input.is_action_pressed("sprint"))
	
	# Camera catch-up: follow the body's position instantly, but lag on yaw
	spring_arm.global_position = global_position + Vector3(0, CAMERA_HEIGHT, 0)
	camera_yaw = lerp_angle(camera_yaw, rotation.y, CAMERA_YAW_SMOOTHING * delta)
	spring_arm.rotation.y = camera_yaw
