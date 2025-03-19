extends "res://scripts/enemy_fireball.gd"
var cloned = 0
var destroyed = false
@onready var cloneScene = load("res://scenes/vines.tscn")

var health = 3
var timer = 2
var tween
@onready var player = scene_manager.player

func _ready() -> void:
	$FireParticles.amount = randi_range(3, 7)
	$FireParticles.emitting = true
	await get_tree().create_timer(0.5).timeout
	if cloned < 4:
		spawn()
	await get_tree().create_timer(4.5).timeout
	if !destroyed:
		destroyed = true
		destroy()

func _physics_process(_delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.hit(damage)
		if !destroyed:
			destroyed = true
			destroy()

func spawn() -> void:
	var clone = cloneScene.instantiate()
	clone.rotation_degrees = rotation_degrees
	clone.global_position = self.global_position + (transform.x * 240)
	clone.cloned = cloned + 1
	get_parent().add_child(clone)


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
			if !destroyed:
				destroyed = true
				destroy()
