extends "res://scripts/slime.gd"
var health_bar_scene = preload("res://scenes/HealthBar.tscn") 
var health_bar

func _ready() -> void:
	health_bar = health_bar_scene.instantiate()
	add_child(health_bar)
	health_bar.position = Vector2(-232, -200)
	$SummonAnim.play("fadein")
	await $SummonAnim.animation_finished
	
	var bar_node = health_bar.get_node("ProgressBar")
	if bar_node:
		bar_node.max_value = health
		bar_node.value = health

func _on_hitbox_area_entered(area: Area2D) -> void:
	super._on_hitbox_area_entered(area)
	var bar_node = health_bar.get_node("ProgressBar")
	if bar_node:
		bar_node.value = health

func destroy():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	set_physics_process(false)
	$SlimeSprite/SlimeParticles.emitting = true
	$SummonAnim.play_backwards("fadein")
	await $SummonAnim.animation_finished
	if health_bar:
		queue_free()
	queue_free()
	
