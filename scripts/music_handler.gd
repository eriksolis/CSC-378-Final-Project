extends Node

## TAKES STRING AS SONG NAME, PLAYS SONG
func play(song : String) -> void:
	for child in get_children():
		if child.name == song:
			child.play()
		else:
			child.stop()
