extends Node3D

@export var target: Node3D          # drag your Player node here in the Inspector
@export var offset: Vector3 = Vector3(0, 8, -6)   # tweak to taste for your angle
@export var follow_speed: float = 5.0   # higher = snappier follow, lower = floatier/laggier

func _process(delta: float) -> void:
	if not target:
		return
	var target_position = target.global_position + offset
	global_position = global_position.lerp(target_position, follow_speed * delta)
