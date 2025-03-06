extends "res://scripts/slime.gd"

func _ready() -> void:
	$SummonAnim.play("fadein")
	await $SummonAnim.animation_finished

func destroy():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	set_physics_process(false)
	$SlimeSprite/SlimeParticles.emitting = true
	$SummonAnim.play_backwards("fadein")
	await $SummonAnim.animation_finished
	queue_free()
