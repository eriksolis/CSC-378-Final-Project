class_name BaseScene extends Node


@onready var player: Player = $Player
@onready var entrance_markers: Node2D = $EntranceMarkers

func _ready() -> void:
	if scene_manager.player:
		if player:
			player.queue_free()
		
		player = scene_manager.player
		add_child(player)
		
	position_player()

func position_player() -> void:
	for entrance in entrance_markers.get_children():
		if entrance is Marker2D and entrance.name == "DoorPos":
			player.global_position = entrance.global_position
