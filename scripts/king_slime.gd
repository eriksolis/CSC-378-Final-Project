extends "res://scripts/slime.gd"

var slimeTypes = [
load("res://scenes/slime.tscn"),
load("res://scenes/overgrowth_slime.tscn"), 
load("res://scenes/purple_slime.tscn"), 
load("res://scenes/mushroom_slime.tscn"),
load("res://scenes/cloud_slime.tscn"), 
load("res://scenes/star_slime.tscn"), 
load("res://scenes/comet_slime.tscn")
]
var bulletLoad = load("res://scenes/blue_bullet.tscn")
var waveLoad = load("res://scenes/wave_shot.tscn")
var smallSummon = load("res://scenes/small_summon.tscn")
signal bossDead

@export var chargeSpeed = 1000
var destroyed = false
var moving = true
var counter = 3

var playerPos = Vector2(0, 0)
var attack_timer: float = 0.0
var has_stopped: bool = false
var isCharging = false

func _ready() -> void:
	$SummonAnim.play("fadein")
	await $SummonAnim.animation_finished

func destroy():
	if !destroyed:
		destroyed = true
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		call_deferred("set_physics_process", false)
		$SlimeSprite/SlimeParticles.emitting = true
		$SummonAnim.play_backwards("fadein")
		await $SummonAnim.animation_finished
		bossDead.emit()
		queue_free()

func _physics_process(delta:float) -> void:
	if moving and !isCharging:
		nav_agent.target_position = player.global_position
		var direction = Vector2.ZERO
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = direction * speed 
		
	move_and_slide()

func chargeAttack():
	# Set target position to player's current position
	playerPos = player.global_position

	# Telegraph the attack
	velocity = Vector2.ZERO
	await get_tree().create_timer(0.5).timeout

	# Charge toward the saved player position
	var direction = (playerPos - global_position).normalized()
	velocity = direction * chargeSpeed

	# Keep charging for a duration
	var start_time = Time.get_ticks_msec()
	var duration = 500  # milliseconds

	while Time.get_ticks_msec() - start_time < duration:
		move_and_slide()  # Move during each frame
		await get_tree().process_frame  # Wait for next frame

	# Stop after charge
	velocity = Vector2.ZERO
	await get_tree().create_timer(0.3).timeout  # Recovery time

func bulletAttack():
	for i in range(0, 8):
		# Instantiate the enemy fireball
		var bullet = bulletLoad.instantiate()
		# Position it at the slime's location (or use a Marker2D if you want a different spawn point)
		bullet.global_position = global_position
		# Rotate to face the player
		bullet.rotation = (player.global_position - global_position).angle()
		bullet.rotation_degrees += (360.0/8) * i
		# Add the bullet to the scene
		get_parent().add_child(bullet)

func waveRainAttack():
	for i in range(0, 20):
		var newWave = waveLoad.instantiate()
		newWave.global_position = Vector2(250 * i, -100)
		get_parent().add_child(newWave)
		await get_tree().create_timer(0.2).timeout

func slimeSummons():
	for i in range(0, 4):
		var newSummon = smallSummon.instantiate()
		newSummon.summon = slimeTypes.pick_random()
		$Lever.rotation_degrees += randi_range(45, 90)
		newSummon.global_position = $Lever/Marker2D.global_position
		get_parent().add_child(newSummon)
		await get_tree().create_timer(1).timeout

# cycles thru attacks, pattern resets on slime spawns
func _on_timer_timeout() -> void:
	moving = false
	match counter:
		0:
			await chargeAttack()
			print("charge attack")
			counter += 1
		1:
			await bulletAttack()
			counter += 1
		2:
			await waveRainAttack()
			counter += 1
		3:
			await slimeSummons()
			counter = 0
	moving = true
	$Timer.start()
