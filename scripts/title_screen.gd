extends Control
@onready var game = load("res://scenes/game.tscn")
var loadedGame


func _on_start_button_pressed() -> void:
	loadedGame = game.instantiate()
	loadedGame.get_node("Player").connect("restart", restart)
	get_parent().add_child(loadedGame)
	hide()


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func restart():
	loadedGame.queue_free()
	show()
	
