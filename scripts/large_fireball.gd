extends "res://scripts/fireball.gd"
@onready var fireball = load("res://scenes/fireball.tscn")

## DESTROYS FIREBALL
func destroy() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	set_physics_process(false)
	$AnimationPlayer.speed_scale = 4
	$AnimationPlayer.play_backwards("fadein")
	$FireParticles.amount = randi_range(5, 10)
	await spawnFireballs()
	$FireParticles.emitting = true
	await $FireParticles.finished
	queue_free()

func spawnFireballs():
	var parent = get_parent()
	for i in range(0, 6):
		var fireballSpawn = fireball.instantiate()
		fireballSpawn.global_position = global_position
		fireballSpawn.rotation_degrees = rotation_degrees + (i * 60)
		parent.call_deferred("add_child", fireballSpawn)
