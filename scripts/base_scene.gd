class_name BaseScene extends Node

@onready var entrance_markers: Node2D = $EntranceMarkers
@export var defaultPosition = Vector2(543, 546)
@export var doorStatus = 0

func set_player(player):
	match doorStatus:
		0:
			player.global_position = defaultPosition
			
		1:
			for entrance in entrance_markers.get_children():
				if entrance is Marker2D and entrance.name == "DoorPos":
					player.global_position = entrance.global_position
	add_child(player)
