extends CharacterBody3D

#movement var
const SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5

#rotation var
const ROTATION_SPEED = 10.0    # higher = snappier turning, lower = smoother/floatier
const MIN_AIM_DISTANCE = 0.5   # ignore mouse targets closer than this to avoid jitter

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var current_speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var camera = get_viewport().get_camera_3d()
	var cam_forward = -camera.global_transform.basis.z
	var cam_right = camera.global_transform.basis.x
	cam_forward.y = 0
	cam_right.y = 0
	cam_forward = cam_forward.normalized()
	cam_right = cam_right.normalized()

	var direction = (cam_forward * -input_dir.y + cam_right * input_dir.x).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	rotate_towards_mouse(delta)
	move_and_slide()
	
func rotate_towards_mouse(delta) -> void:
	var camera = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()

	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)

	# Horizontal plane at the player's own height
	var ground_plane = Plane(Vector3.UP, global_position.y)
	var target_point = ground_plane.intersects_ray(ray_origin, ray_dir)

	if target_point == null:
		return

	var to_target = target_point - global_position
	to_target.y = 0

	if to_target.length() < MIN_AIM_DISTANCE:
		return  # mouse too close on-screen — hold last facing instead of snapping wildly

	var target_yaw = atan2(to_target.x, to_target.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, ROTATION_SPEED * delta)
