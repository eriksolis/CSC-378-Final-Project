extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.heal():
			destroy()
		else:
			return

func destroy():
	$Pickup.play()
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	$SlimeParticles.emitting = true
	$SummonAnim.speed_scale *= 2
	$SummonAnim.play_backwards("fadein")
	await $SummonAnim.animation_finished
	queue_free()
