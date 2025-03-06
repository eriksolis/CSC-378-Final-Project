class_name SceneManager extends Node

@onready var player: Player = load("res://scenes/player.tscn").instantiate()
var sceneDictionary = {}

func change_scene(to_scene_name: String) -> void:
	# remove player from current game scene
	var tempPlayer = get_tree().get_first_node_in_group("Player")
	if tempPlayer:
		player = tempPlayer
		player.get_parent().remove_child(player)
	
	clearScenes()
	
	# check and initialize unknown scene
	var savedScene = sceneDictionary.get(to_scene_name)
	# if unknown
	if !savedScene:
		var newScene = load("res://scenes/" + to_scene_name + ".tscn")
		sceneDictionary[to_scene_name] = newScene.instantiate()
	# add new scene to root
	get_tree().root.add_child(sceneDictionary[to_scene_name])
	sceneDictionary[to_scene_name].set_player(player)

func clearScenes():
	# remove all game scenes
	var gameScenes = get_tree().get_nodes_in_group("GameScene")
	for gameScene in gameScenes:
		gameScene.get_parent().remove_child(gameScene)

func resetGame():
	player.queue_free()
	player = load("res://scenes/player.tscn").instantiate()
	for scene in sceneDictionary:
		sceneDictionary[scene].queue_free()
	sceneDictionary.clear()
