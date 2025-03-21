extends CharacterBody2D
@export var health = 4
enum TYPES {BLUE, GREEN, RED}
@export var type = TYPES.BLUE
@onready var blueParticle = load("res://images/enemies/slime_particle.png")
@onready var greenParticle = load("res://images/enemies/slime_particle2.png")
@onready var redParticle = load("res://images/enemies/slime_particle3.png")
#@onready var orangeParticle = load("res://images/enemies/slime_particle4.png")
var tween
@onready var player = scene_manager.player
@onready var nav_agent := $Navigation/NavigationAgent2D as NavigationAgent2D
var speed = 150
signal enemyDead

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
		#TYPES.ORANGE:
			#$SlimeSprite.play("orange")
			#$SlimeSprite/SlimeParticles.texture = orangeParticle
	$SummonAnim.play("fadein")
	await $SummonAnim.animation_finished
	
func _physics_process(delta:float) -> void:
	nav_agent.target_position = player.global_position
	var direction = Vector2.ZERO
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()
		
	
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

func _on_timer_target_positiontimeout() -> void:
	nav_agent.target_position = player.global_position
	pass # Replace with function body.
