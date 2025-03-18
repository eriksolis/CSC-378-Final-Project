extends RigidBody2D

signal enemyDead

@export var health: int = 3
@export var speed: float = 300
@export var chase_distance: float = 250.0  # Distance at which slime stops moving
@export var attack_range: float = 500.0    # Distance within which slime can shoot
@export var attack_cooldown: float = 2.0
@onready var player = scene_manager.player  # same approach as your melee slime
var playerPos = Vector2(0, 0)

var attack_timer: float = 0.0
var has_stopped: bool = false
var tween

func _ready() -> void:
	# Play the same "fadein" animation your melee slime uses
	$SummonAnim.play("fadein")
	await $SummonAnim.animation_finished
	if player:
		playerPos = player.global_position

func _physics_process(delta: float) -> void:
	if player == null:
		return

	# If the player is NOT physically in the slime's hitbox
	if player not in $Hitbox.get_overlapping_bodies():
		# CHARGE ATTACK BASED ON LAST PLAYER POSITION
		if attack_timer > 0 and global_position != playerPos:
			# Move closer
			attack_timer -= delta
			var direction = (playerPos - position).normalized()
			linear_velocity = linear_velocity.move_toward(direction, speed).normalized() * 500
			if global_position != playerPos:
				playerPos += direction
		elif !has_stopped:
			# Stop once in range
			linear_velocity = Vector2.ZERO
			has_stopped = true
			await get_tree().create_timer(1).timeout
			has_stopped = false
			playerPos = player.global_position
			attack_timer = attack_cooldown

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
