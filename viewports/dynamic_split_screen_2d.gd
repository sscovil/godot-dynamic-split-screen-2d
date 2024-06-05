class_name DynamicSplitScreen2D
extends SubViewportContainer

@export var player1: Player
@export var player2: Player

@export_group("Dynamic Split Screen")
@export var adaptive_split_line_thickness: bool = true
@export var max_separation: float = 50.0
@export var split_line_color: Color = Color.BLACK
@export var split_line_thickness: float = 3.0

var player_distance: Vector2: get = get_player_distance
var screen_size: Vector2: get = get_screen_size

@onready var camera1: Camera2D = $Viewport1/Camera1
@onready var camera2: Camera2D = $Viewport2/Camera2
@onready var view: TextureRect = $View
@onready var viewport1: SubViewport = $Viewport1
@onready var viewport2: SubViewport = $Viewport2


func _ready() -> void:
	update_viewport_size()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	initialize_viewports()
	update_splitscreen()


func _process(delta) -> void:
	move_cameras()
	update_splitscreen()


func _on_viewport_size_changed() -> void:
	update_viewport_size()


func get_player_distance() -> Vector2:
	return player2.position - player1.position


func get_screen_size() -> Vector2:
	return get_viewport().get_visible_rect().size


func get_split_line_thickness() -> float:
	if adaptive_split_line_thickness:
		return split_line_thickness
	
	var thickness = lerpf(0, split_line_thickness, (player_distance.length() - max_separation) / max_separation)
	
	return clampf(thickness, 0, split_line_thickness)


func initialize_viewports() -> void:
	camera1.set_custom_viewport(viewport1)
	camera2.set_custom_viewport(viewport2)
	view.material.set_shader_parameter("viewport1", viewport1.get_texture())
	view.material.set_shader_parameter("viewport2", viewport2.get_texture())


func is_split_screen_active() -> bool:
	return player_distance.length() > max_separation


func move_cameras() -> void:
	var distance: float = clamp(player_distance.length(), 0.0, max_separation)
	var position_difference = player_distance.normalized() * distance
	
	camera1.position = player1.position + position_difference / 2.0
	camera2.position = player2.position - position_difference / 2.0


func update_splitscreen() -> void:
	var player1_position = player1.position / screen_size
	var player2_position = player2.position / screen_size
	var thickness = get_split_line_thickness()

	view.material.set_shader_parameter("split_active", is_split_screen_active())
	view.material.set_shader_parameter("player1_position", player1_position)
	view.material.set_shader_parameter("player2_position", player2_position)
	view.material.set_shader_parameter("split_line_thickness", thickness)
	view.material.set_shader_parameter("split_line_color", split_line_color)


func update_viewport_size() -> void:
	viewport1.size = screen_size
	viewport2.size = screen_size
	view.material.set_shader_parameter("viewport_size", screen_size)
