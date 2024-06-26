class_name Player
extends CharacterBody2D

enum PlayerAction {
	CLIMB_DOWN,
	CLIMB_UP,
	DUCK,
	JUMP,
	WALK_LEFT,
	WALK_RIGHT,
}

enum PlayerState {
	DUCK,
	FRONT,
	HURT,
	JUMP,
	STAND,
	WALK,
}

const SPEED: float = 400.0
const JUMP_VELOCITY: float = -500.0

@export_enum("p1", "p2") var player_id: String

var action_map: Dictionary = {
	PlayerAction.CLIMB_DOWN: "climb_down",
	PlayerAction.CLIMB_UP: "climb_up",
	PlayerAction.DUCK: "duck",
	PlayerAction.JUMP: "jump",
	PlayerAction.WALK_LEFT: "walk_left",
	PlayerAction.WALK_RIGHT: "walk_right",
}

var state_map: Dictionary = {
	PlayerState.DUCK: "duck",
	PlayerState.FRONT: "front",
	PlayerState.HURT: "hurt",
	PlayerState.JUMP: "jump",
	PlayerState.STAND: "stand",
	PlayerState.WALK: "walk",
}

var current_direction: int: get = get_current_direction
var current_state: PlayerState = PlayerState.FRONT
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta) -> void:
	update_state()


func _physics_process(delta) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor() and is_action_just_pressed(PlayerAction.JUMP):
		velocity.y = JUMP_VELOCITY

	var direction: float = get_x_input_axis()
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func get_action(action: PlayerAction) -> String:
	return "%s_%s" % [player_id, action_map[action]]


func get_current_direction() -> int:
	var direction: float = get_x_input_axis()
	
	if abs(direction) > 0.0001:
		return 1 if direction > 0 else -1
	
	return 0


func get_x_input_axis() -> float:
	return Input.get_axis(get_action(PlayerAction.WALK_LEFT), get_action(PlayerAction.WALK_RIGHT))


func get_y_input_axis() -> float:
	return Input.get_axis(get_action(PlayerAction.CLIMB_UP), get_action(PlayerAction.CLIMB_DOWN))


func is_action_just_pressed(action: PlayerAction) -> bool:
	return Input.is_action_just_pressed(get_action(action))


func is_action_just_released(action: PlayerAction) -> bool:
	return Input.is_action_just_released(get_action(action))


func is_action_pressed(action: PlayerAction) -> bool:
	return Input.is_action_pressed(get_action(action))


func next_state() -> PlayerState:
	if is_action_pressed(PlayerAction.DUCK):
		return PlayerState.DUCK
	
	if !is_on_floor():
		return PlayerState.JUMP
	
	if abs(get_x_input_axis()) > 0.0001:
		return PlayerState.WALK
	
	return PlayerState.STAND


func play_animation(state: PlayerState) -> void:
	sprite.play(state_map[state])


func update_state() -> void:
	var previous_state: PlayerState = current_state
	
	current_state = next_state()
	
	if current_state != previous_state:
		play_animation(current_state)
	
	if current_direction:
		sprite.set_flip_h(-1 == current_direction)
	
	if PlayerState.DUCK == current_state:
		hitbox.shape.set_height(70)
	else:
		hitbox.shape.set_height(92)
