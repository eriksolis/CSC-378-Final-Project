extends "res://scripts/ranged_slime.gd"

func shoot_fireball() -> void:
	$Fire.play()
	var bulletArray = []
	for i in range(0, 8):
		# Instantiate the enemy fireball
		bulletArray.append(enemy_fireball_scene.instantiate())
		# Position it at the slime's location
		bulletArray[i].global_position = global_position
		# Rotate to face the player
		bulletArray[i].rotation = (player.global_position - global_position).angle()
		bulletArray[i].rotation_degrees += ((360.0/8) * i)
	for bullet in bulletArray:
		get_parent().add_child(bullet)
