extends "res://scripts/enemy_fireball.gd"
var health = 6
var timer = 0.5
var tween
@onready var pistil_bullet = load("res://scenes/pistil_bullet.tscn")
@onready var player = scene_manager.player

func _ready() -> void:
	$FireParticles.amount = randi_range(3, 7)
	$FireParticles.emitting = true
	await get_tree().create_timer(10).timeout
	destroy()

func _physics_process(_delta: float) -> void:
	if speed > 0:
		global_position += transform.x * speed
		speed -= 0.15
	elif timer <= 0:
		shoot()
		timer = 0.5
	else:
		speed = 0
		timer -= _delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.hit(damage)

func shoot() -> void:
	var bullet = pistil_bullet.instantiate()
	bullet.global_position = global_position
	if player:
		bullet.rotation = (player.global_position - global_position).angle()
	get_parent().add_child(bullet)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerBullets"):
		$Sprite2D.modulate.v = 3
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate:v", 1, 0.2)
		health -= area.damage
		area.destroy()
		if health <= 0:
			if tween:
				tween.kill()
			destroy()
