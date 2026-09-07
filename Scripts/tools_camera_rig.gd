extends Camera3D

@export var target: Node3D
@export var ortho_size: float = 10.0       # zoom level — tweak to taste
@export var height: float = 14.0
@export var distance: float = 10.0
@export var follow_speed: float = 6.0
@export var deadzone_radius: float = 0.6   # player can drift this far before cam reacts

var _cam_target_pos: Vector3

func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	size = ortho_size
	rotation_degrees = Vector3(-65, 0, 0)
	if target:
		_cam_target_pos = target.global_position

func _physics_process(delta: float) -> void:
	if not target:
		return

	var player_pos = target.global_position
	var offset_xz = Vector2(player_pos.x - _cam_target_pos.x, player_pos.z - _cam_target_pos.z)

	# Only move the follow target once the player exits the deadzone
	if offset_xz.length() > deadzone_radius:
		var pull = offset_xz.normalized() * (offset_xz.length() - deadzone_radius)
		_cam_target_pos.x += pull.x
		_cam_target_pos.z += pull.y

	var desired_position = _cam_target_pos + Vector3(0, height, distance)
	global_position = global_position.lerp(desired_position, follow_speed * delta)
	look_at(_cam_target_pos, Vector3.UP)
