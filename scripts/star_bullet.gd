extends "res://scripts/enemy_fireball.gd"
@onready var fireball = load("res://scenes/shard_bullet.tscn")
var split = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.hit(damage)
		destroy()
	elif !body.is_in_group("Enemies"):
		split = true
		destroy()

func destroy() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	set_physics_process(false)
	$AnimationPlayer.speed_scale = 4
	$AnimationPlayer.play_backwards("fadein")
	$FireParticles.amount = randi_range(5, 10)
	if split:
		await spawnFireballs()
	$FireParticles.emitting = true
	await $FireParticles.finished
	queue_free()

func spawnFireballs():
	var parent = get_parent()
	for i in range(0, 5):
		var fireballSpawn = fireball.instantiate()
		fireballSpawn.global_position = global_position
		fireballSpawn.rotation_degrees = rotation_degrees + (i * 72)
		parent.call_deferred("add_child", fireballSpawn)
