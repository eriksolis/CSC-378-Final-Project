extends "res://scripts/slime.gd"
var copied = 0
@onready var clone = load("res://scenes/overgrowth_slime.tscn")
var timer = 5
var cloned = false
var stopped = false

func _ready() -> void:
	$SummonAnim.play("fadein")
	await $SummonAnim.animation_finished

func _physics_process(delta:float) -> void:
	if !stopped:
		nav_agent.target_position = player.global_position
		var direction = Vector2.ZERO
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = direction * speed
		move_and_slide()
		timer -= delta
		if !cloned and copied < 2 and timer <= delta:
			copied += 1
			stopped = true
			cloned = true
			await get_tree().create_timer(3)
			var newClone = clone.instantiate()
			newClone.copied = copied
			newClone.global_position = global_position - direction * 100
			get_parent().add_child(newClone)
			stopped = false
