extends Area2D

@export var speed: float = 15
@export var damage: int = 1

func _ready() -> void:
	$FireParticles.amount = randi_range(3, 7)
	$FireParticles.emitting = true

func _physics_process(_delta: float) -> void:
	global_position += transform.x * speed

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.hit(damage)
		destroy()
	elif !body.is_in_group("Enemies"):
		destroy()

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
