extends "res://scripts/slime.gd"

func _ready() -> void:
	$CanvasLayer/HealthBar.max_value = health
	$CanvasLayer/HealthBar.value = health
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/HealthBar, "modulate:a", 1, 0.25)
	$SummonAnim.play("fadein")
	await $SummonAnim.animation_finished

func destroy():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	set_physics_process(false)
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/HealthBar, "modulate:a", 0, 0.25)
	$SlimeSprite/SlimeParticles.emitting = true
	$SummonAnim.play_backwards("fadein")
	await $SummonAnim.animation_finished
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBullets"):
		$Hit.pitch_scale = randf_range(0.95, 1)
		$Hit.play()
		# modulate flash trick taken from
		# https://www.reddit.com/r/godot/comments/y8n1wa/is_it_possible_to_make_a_sprite_flash_white_using/
		$SlimeSprite.modulate.v = 3
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property($SlimeSprite, "modulate:v", 1, 0.2)
		area.destroy()
		health -= area.damage
		$CanvasLayer/HealthBar.value = health
		if health <= 0:
			destroy()
