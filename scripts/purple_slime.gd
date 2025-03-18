extends "res://scripts/ranged_slime.gd"

func shoot_fireball() -> void:
	$Fire.play()
	# Instantiate the enemy fireball
	var bullet = enemy_fireball_scene.instantiate()
	var bullet2 = enemy_fireball_scene.instantiate()
	var bullet3 = enemy_fireball_scene.instantiate()
	# Position it at the slime's location (or use a Marker2D if you want a different spawn point)
	bullet.global_position = global_position
	bullet2.global_position = global_position
	bullet3.global_position = global_position

	# Rotate to face the player
	bullet.rotation = (player.global_position - global_position).angle()
	bullet2.rotation = (player.global_position - global_position).angle()
	bullet2.rotation_degrees += 15
	bullet3.rotation = (player.global_position - global_position).angle()
	bullet3.rotation_degrees -= 15
	

	# Add the bullet to the scene
	get_parent().add_child(bullet)
	get_parent().add_child(bullet2)
	get_parent().add_child(bullet3)
