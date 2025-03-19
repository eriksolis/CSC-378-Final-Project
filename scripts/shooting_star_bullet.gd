extends Area2D

@export var speed: float = 10
@export var damage: int = 1

func _ready() -> void:
	$FireParticles.amount = randi_range(3, 7)
	$FireParticles.emitting = true
	await get_tree().create_timer(10).timeout
	destroy()

func _physics_process(_delta: float) -> void:
	global_position -= Vector2(speed * 1.5, - speed)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.hit(damage)

func destroy() -> void:
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	set_physics_process(false)
	$AnimationPlayer.speed_scale = 4
	$AnimationPlayer.play_backwards("fadein")
	queue_free()
