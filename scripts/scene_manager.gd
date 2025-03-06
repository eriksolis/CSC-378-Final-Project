class_name SceneManager extends Node

# tutorial from https://www.youtube.com/watch?v=sKqtCc_HykM&t

var player: Player

var scene_dir_path = "res://scenes/"

func change_scene(from, to_scene_name: String) -> void:
	player = from.get_node("Player")
	# bugged when going back and forth from scene to scene, "Cannot call method 'get_parent' on a null value"
	if player:
		player.get_parent().remove_child(player) 
	
	var full_path = scene_dir_path + to_scene_name + ".tscn"
	from.get_tree().call_deferred("change_scene_to_file", full_path)
	
