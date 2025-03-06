class_name SceneTrigger extends Area2D

@export var connected_scene: String # name of scene to change to
var scene_folder = "res://scenes/"
var active = false
var in_door = false

func _on_body_entered(body) -> void:
	if active and body is Player:
		in_door = true

func _input(event: InputEvent) -> void:
	if active and in_door and Input.is_action_just_pressed("ui_interact"):
		active = false
		scene_manager.change_scene(get_owner(), connected_scene)

func _on_body_exited(body: Node2D) -> void:
	in_door = false
