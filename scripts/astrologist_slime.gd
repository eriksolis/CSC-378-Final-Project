extends "res://scripts/slime.gd"

var shootingStarLoad = load("res://scenes/shooting_star_bullet.tscn")
var crescentMoonLoad = load("res://scenes/crescent_moon_bullet.tscn")
var slimeTypes = [load("res://scenes/cloud_slime.tscn"), load("res://scenes/star_slime.tscn"), load("res://scenes/comet_slime.tscn")]
var smallSummon = load("res://scenes/small_summon.tscn")
var astrologistLoad = load("res://scenes/astrologist_interact_area.tscn")
signal minibossDead
signal astrologist_defeated
var destroyed = false
var moving = true
var counter = 2
var health_bar_scene = preload("res://scenes/HealthBar.tscn") 
var health_bar

func _ready() -> void:
	health_bar = health_bar_scene.instantiate()
	add_child(health_bar)
	health_bar.position = Vector2(-232, -180)
	$SummonAnim.play("fadein")
	await $SummonAnim.animation_finished
	var bar_node = health_bar.get_node("ProgressBar")
	if bar_node:
		bar_node.max_value = health
		bar_node.value = health
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		astrologist_defeated.connect(player.unlock_dash)
		
func _on_hitbox_area_entered(area: Area2D) -> void:
	super._on_hitbox_area_entered(area)
	var bar_node = health_bar.get_node("ProgressBar")
	if bar_node:
		bar_node.value = health
		
func destroy():
	if !destroyed:
		destroyed = true
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		call_deferred("set_physics_process", false)
		var astrologist = astrologistLoad.instantiate()
		astrologist.global_position = global_position
		get_parent().add_child(astrologist)
		$SlimeSprite/SlimeParticles.emitting = true
		$SummonAnim.play_backwards("fadein")
		await $SummonAnim.animation_finished
		minibossDead.emit()
		astrologist_defeated.emit()
		if health_bar:
			queue_free()
		queue_free()

func _physics_process(delta:float) -> void:
	if moving:
		nav_agent.target_position = player.global_position
		var direction = Vector2.ZERO
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = direction * speed
		move_and_slide()

func shootingStarAttack():
	for i in range(0, 20):
		var newShootingStar = shootingStarLoad.instantiate()
		newShootingStar.global_position = Vector2(250 * i, -100)
		get_parent().add_child(newShootingStar)
		await get_tree().create_timer(0.2).timeout

func crescentMoonAttack():
	for i in range(0, randi_range(4, 6)):
		# Instantiate the enemy fireball
		var bullet = crescentMoonLoad.instantiate()
		# Position it at the slime's location (or use a Marker2D if you want a different spawn point)
		bullet.global_position = global_position
		# Rotate to face the player
		bullet.rotation = (player.global_position - global_position).angle()
		bullet.rotation_degrees += randi_range(-2, 2) * 10
		# Add the bullet to the scene
		get_parent().add_child(bullet)
		await get_tree().create_timer(0.5).timeout

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
			await shootingStarAttack()
			counter += 1
		1:
			await crescentMoonAttack()
			counter += 1
		2:
			await slimeSummons()
			counter = 0
	moving = true
	$Timer.start()
