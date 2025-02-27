extends RigidBody2D
@export var health = 3
enum TYPES {BLUE, GREEN, RED}
@export var type = TYPES.BLUE
@onready var blueParticle = load("res://images/enemies/slime_particle.png")
@onready var greenParticle = load("res://images/enemies/slime_particle2.png")
@onready var redParticle = load("res://images/enemies/slime_particle3.png")
var tween
var player
var speed = 300

func _ready() -> void:
	match type:
		TYPES.BLUE:
			$SlimeSprite.play("blue")
			$SlimeSprite/SlimeParticles.texture = blueParticle
		TYPES.RED:
			$SlimeSprite.play("red")
			$SlimeSprite/SlimeParticles.texture = redParticle
		TYPES.GREEN:
			$SlimeSprite.play("green")
			$SlimeSprite/SlimeParticles.texture = greenParticle
	$SummonAnim.play("fadein")
	await $SummonAnim.animation_finished
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(_delta: float) -> void:
	if player != null and player not in $Hitbox.get_overlapping_bodies():
		linear_velocity = linear_velocity.move_toward(player.position - position, speed).normalized() * 100

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBullets"):
		# modulate flash trick taken from
		# https://www.reddit.com/r/godot/comments/y8n1wa/is_it_possible_to_make_a_sprite_flash_white_using/
		$SlimeSprite.modulate.v = 3
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property($SlimeSprite, "modulate:v", 1, 0.2)
		area.destroy()
		health -= 1
		if health <= 0:
			destroy()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.hit()

func destroy():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	set_physics_process(false)
	$SlimeSprite/SlimeParticles.emitting = true
	$SummonAnim.speed_scale *= 2
	$SummonAnim.play_backwards("fadein")
	await $SummonAnim.animation_finished
	queue_free()
