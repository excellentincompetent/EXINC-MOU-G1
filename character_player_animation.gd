extends Node

@export var player: CharacterBody3D
@export var animation_player: AnimationPlayer

enum State { IDLE, WALK_FORWARD, WALK_BACK, WALK_LEFT, WALK_RIGHT }
var current_state: State = State.IDLE

const DEADZONE = 0.2   # ignores tiny input noise so idle doesn't flicker

func _ready() -> void:
	player.movement_updated.connect(_on_movement_updated)

func _on_movement_updated(input_dir: Vector2, is_sprinting: bool) -> void:
	var new_state = determine_state(input_dir)
	if new_state != current_state:
		current_state = new_state
		play_state(new_state)

func determine_state(input_dir: Vector2) -> State:
	if input_dir.length() < DEADZONE:
		return State.IDLE

	# Prioritize forward/back if input leans that way, else strafe
	if abs(input_dir.y) >= abs(input_dir.x):
		return State.WALK_BACK if input_dir.y > 0 else State.WALK_FORWARD
	else:
		return State.WALK_RIGHT if input_dir.x > 0 else State.WALK_LEFT

func play_state(state: State) -> void:
	match state:
		State.IDLE:
			animation_player.play("character_player_idle")
		State.WALK_FORWARD:
			animation_player.play("character_player_walkForward")
		State.WALK_BACK:
			animation_player.play("character_player_walkBack")
		State.WALK_LEFT:
			animation_player.play("character_player_walkLeft")
		State.WALK_RIGHT:
			animation_player.play("character_player_walkRight")
