class_name SceneTrigger extends Area2D

@export var connected_scene: String # name of scene to change to
var scene_folder = "res://scenes/"
var active = false
var in_door = false

func _on_body_entered(body) -> void:
	if active and body is Player:
		$E.show()
		in_door = true

func _input(event: InputEvent) -> void:
	if active and in_door and Input.is_action_just_pressed("ui_interact"):
		active = false
		get_parent().doorStatus = 1
		scene_manager.change_scene(connected_scene)

func _on_body_exited(body: Node2D) -> void:
	$E.hide()
	in_door = false

func enable():
	$Doorblock.hide()
	active = true
