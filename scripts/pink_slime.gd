extends "res://scripts/ranged_slime.gd"
var loadSlimeHeart = load("res://scenes/heart_up.tscn")

func destroy():
	var slimeHeart = loadSlimeHeart.instantiate()
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	set_physics_process(false)
	$SlimeSprite/SlimeParticles.emitting = true
	$SummonAnim.speed_scale *= 2
	$SummonAnim.play_backwards("fadein")
	await $SummonAnim.animation_finished
	slimeHeart.global_position = self.global_position
	get_parent().add_child(slimeHeart)
	enemyDead.emit()
	queue_free()
