class_name BaseScene extends Node

@onready var entrance_markers: Node2D = $EntranceMarkers
@export var defaultPosition = Vector2(543, 546)
@export var doorStatus = 0

func set_player(player):
	print(doorStatus)
	match doorStatus:
		0:
			player.global_position = defaultPosition
			
		1:
			for entrance in entrance_markers.get_children():
				#print(entrance)
				print(scene_manager.lastRoom)
				if entrance is Marker2D and entrance.name == "DoorPos" and scene_manager.lastRoom != "room_2":
					print("doorpos1")
					player.global_position = entrance.global_position
					break
				elif entrance is Marker2D and entrance.name == "DoorPos2" and scene_manager.lastRoom == "room_2":
					print("doorpos2")
					player.global_position = entrance.global_position
					break
				elif entrance is Marker2D and entrance.name == "DoorPos3":
					print("ending")
					player.global_position = entrance.global_position
					break
	add_child(player)
