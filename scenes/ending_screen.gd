extends Control

func _on_quit_button_pressed() -> void:
	$Click.play()
	get_tree().quit()
