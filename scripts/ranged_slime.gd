extends RigidBody2D

signal enemyDead

@export var health: int = 3
@export var speed: float = 300
@export var chase_distance: float = 250.0  # Distance at which slime stops moving
@export var attack_range: float = 500.0    # Distance within which slime can shoot
@export var attack_cooldown: float = 2.0
@onready var player = scene_manager.player  # same approach as your melee slime

# Load your new enemy fireball scene
@onready var enemy_fireball_scene = load("res://scenes/enemy_fireball.tscn")

var attack_timer: float = 0.0
var has_stopped: bool = false
var tween

func _ready() -> void:
	# If you have unique animations/particles for the ranged slime, change them here:
	$SlimeSprite.play("orange")  # for example
	$SlimeSprite/SlimeParticles.texture = load("res://images/enemies/slime_particle4.png") # optional

	# Play the same "fadein" animation your melee slime uses
	$SummonAnim.play("fadein")
	await $SummonAnim.animation_finished

func _physics_process(delta: float) -> void:
	if player == null:
		return

	# If the player is NOT physically in the slime's hitbox
	if player not in $Hitbox.get_overlapping_bodies():
		var dist_to_player = global_position.distance_to(player.global_position)

		# (1) Chase until within 'chase_distance'
		if not has_stopped:
			if dist_to_player > chase_distance:
				# Move closer
				var direction = (player.position - position).normalized()
				linear_velocity = linear_velocity.move_toward(direction, speed).normalized() * 100
			else:
				# Stop once in range
				linear_velocity = Vector2.ZERO
				has_stopped = true
		else:
			# Stay still after stopping
			linear_velocity = Vector2.ZERO

		# (2) Shoot if within 'attack_range'
		if dist_to_player <= attack_range:
			if attack_timer <= 0:
				shoot_fireball()
				attack_timer = attack_cooldown

	# Decrement the cooldown timer
	if attack_timer > 0:
		attack_timer -= delta

func shoot_fireball() -> void:
	# Instantiate the enemy fireball
	var bullet = enemy_fireball_scene.instantiate()
	# Position it at the slime's location (or use a Marker2D if you want a different spawn point)
	bullet.global_position = global_position

	# Rotate to face the player
	bullet.rotation = (player.global_position - global_position).angle()

	# Add the bullet to the scene
	get_parent().add_child(bullet)

#
# The following is the same damage & death logic as your melee slime
#

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBullets"):
		$Hit.pitch_scale = randf_range(0.95, 1)
		$Hit.play()
		$SlimeSprite.modulate.v = 3

		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property($SlimeSprite, "modulate:v", 1, 0.2)

		area.destroy()
		health -= area.damage
		if health <= 0:
			destroy()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.hit(1)

func destroy():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	set_physics_process(false)
	$SlimeSprite/SlimeParticles.emitting = true
	$SummonAnim.speed_scale *= 2
	$SummonAnim.play_backwards("fadein")
	await $SummonAnim.animation_finished
	enemyDead.emit()
	queue_free()
