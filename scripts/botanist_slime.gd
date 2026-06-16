extends "res://scripts/slime.gd"

var vinesLoad = load("res://scenes/vines.tscn")
var petalLoad = load("res://scenes/petal_bullet.tscn")
var flowerSpawnerLoad = load("res://scenes/flower_spawner.tscn")
var slimeTypes = [load("res://scenes/overgrowth_slime.tscn"), load("res://scenes/purple_slime.tscn"), load("res://scenes/mushroom_slime.tscn")]
var smallSummon = load("res://scenes/small_summon.tscn")
var botanistLoad = load("res://scenes/botanist_interact_area.tscn")
signal minibossDead
var destroyed = false
var moving = true
var counter = 3

func _ready() -> void:
	$CanvasLayer/HealthBar.max_value = health
	$CanvasLayer/HealthBar.value = health
	var tween = get_tree().create_tween()
	tween.tween_property($CanvasLayer/HealthBar, "modulate:a", 1, 0.25)
	$SummonAnim.play("fadein")
	await $SummonAnim.animation_finished

func destroy():
	if !destroyed:
		var tween = get_tree().create_tween()
		tween.tween_property($CanvasLayer/HealthBar, "modulate:a", 0, 0.25)
		destroyed = true
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		call_deferred("set_physics_process", false)
		var botanist = botanistLoad.instantiate()
		botanist.global_position = global_position
		get_parent().add_child(botanist)
		$SlimeSprite/SlimeParticles.emitting = true
		$SummonAnim.play_backwards("fadein")
		await $SummonAnim.animation_finished
		minibossDead.emit()
		queue_free()

func _physics_process(delta:float) -> void:
	if moving:
		nav_agent.target_position = player.global_position
		var direction = Vector2.ZERO
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = direction * speed
		move_and_slide()

func vineAttack():
	var total = randi_range(3, 5)
	var increment = 360.0/total
	for i in range(0, total):
		var vines = vinesLoad.instantiate()
		vines.rotation_degrees = randi_range(roundi(increment) * i, roundi(increment) * (i + 1))
		vines.global_position = global_position
		get_parent().add_child(vines)
		await get_tree().create_timer(0.1).timeout

func petalAttack():
	for i in range(0, 5):
		# Instantiate the enemy fireball
		var bullet = petalLoad.instantiate()
		# Position it at the slime's location (or use a Marker2D if you want a different spawn point)
		bullet.global_position = global_position
		# Rotate to face the player
		bullet.rotation = (player.global_position - global_position).angle()
		bullet.rotation_degrees += (360.0/5) * i
		# Add the bullet to the scene
		get_parent().add_child(bullet)

func flowerSpawners():
	var total = randi_range(3, 4)
	for i in range(0, total):
		# Instantiate the enemy fireball
		var bullet = flowerSpawnerLoad.instantiate()
		# Position it at the slime's location (or use a Marker2D if you want a different spawn point)
		bullet.global_position = global_position
		# Rotate to face the player
		bullet.rotation = (player.global_position - global_position).angle()
		bullet.rotation_degrees += (360.0/ total) * i
		# Add the bullet to the scene
		get_parent().add_child(bullet)

func slimeSummons():
	for i in range(0, randi_range(2, 4)):
		var newSummon = smallSummon.instantiate()
		newSummon.summon = slimeTypes.pick_random()
		$Lever.rotation_degrees += randi_range(45, 90)
		newSummon.global_position = $Lever/Marker2D.global_position
		get_parent().add_child(newSummon)
		await get_tree().create_timer(1).timeout

func _on_timer_timeout() -> void:
	moving = false
	match counter:
		0:
			await vineAttack()
			counter += 1
		1:
			await petalAttack()
			counter += 1
		2:
			await flowerSpawners()
			counter += 1
		3:
			await slimeSummons()
			counter = 0
	moving = true
	$Timer.start()

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
