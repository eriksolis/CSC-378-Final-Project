extends Area2D
@export var speed = 15
@export var damage = 200 # 2

## SPAWNS INITIAL EFFECT
func _ready() -> void:
	$FireParticles.amount = randi_range(3, 7)
	$FireParticles.emitting = true

## MOVES FIREBALL
func _physics_process(_delta: float) -> void:
	global_position += transform.x * speed

## DESTROYS FIREBALL
func destroy() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	set_physics_process(false)
	$AnimationPlayer.speed_scale = 4
	$AnimationPlayer.play_backwards("fadein")
	$FireParticles.amount = randi_range(5, 10)
	$FireParticles.emitting = true
	await $FireParticles.finished
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Enemies") and !body.is_in_group("Player"):
		destroy()
