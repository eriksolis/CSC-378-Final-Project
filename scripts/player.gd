extends CharacterBody2D


enum DIRECTIONS {BACK, FRONT, SIDE}
var direction = DIRECTIONS.FRONT
enum MOTION {IDLE, WALK}
var motion = MOTION.IDLE
var health = 6
const SPEED = 150.0
@onready var fireball = load("res://scenes/fireball.tscn")


func _physics_process(_delta: float) -> void:
	# MOVEMENT
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_direction:
		velocity = input_direction * SPEED
		motion = MOTION.WALK
	else:
		motion = MOTION.IDLE
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	updateDirection()
	updateAnimation()
	updateWand()
	move_and_slide()

## UPDATE DIRECTION BASED ON MOVEMENT AND THEN MOUSE
func updateDirection():
	if velocity.x != 0:
		$Sprite.flip_h = (velocity.x < 0)
		direction = DIRECTIONS.SIDE
	elif velocity.y < 0:
		$Sprite.flip_h = false
		direction = DIRECTIONS.BACK
	elif velocity.y > 0:
		$Sprite.flip_h = false
		direction = DIRECTIONS.FRONT
	else:
		var mousePos = get_global_mouse_position()
		if (mousePos.x - position.x) < -200:
			$Sprite.flip_h = true
			direction = DIRECTIONS.SIDE
		elif (mousePos.x - position.x) > 200:
			$Sprite.flip_h = false
			direction = DIRECTIONS.SIDE
		elif mousePos.y < position.y:
			$Sprite.flip_h = false
			direction = DIRECTIONS.BACK
		else:
			$Sprite.flip_h = false
			direction = DIRECTIONS.FRONT

## UPDATE ANIMATION BASED ON STATES
func updateAnimation():
	var animName = "_"
	match direction:
		DIRECTIONS.FRONT:
			animName = "front" + animName
		DIRECTIONS.BACK:
			animName = "back" + animName
		DIRECTIONS.SIDE:
			animName = "side" + animName
	match motion:
		MOTION.IDLE:
			animName += "idle"
		MOTION.WALK:
			animName += "walk"
	if $Sprite.animation != animName:
		var saved_frame = $Sprite.frame
		var saved_progress = $Sprite.frame_progress
		$Sprite.play(animName)
		$Sprite.set_frame_and_progress(saved_frame, saved_progress)

## UPDATE WAND MOTION AND FIRE
func updateWand():
	var mousePos = get_global_mouse_position()
	$Wand.look_at(mousePos)
	$Wand.rotation_degrees += 45
	if Input.is_action_pressed("ui_accept") and $Wand.animation != "fire":
		$Wand.play("fire")
		var fireSpawn = fireball.instantiate()
		fireSpawn.global_position = $Wand/Marker2D.global_position
		fireSpawn.rotation = get_angle_to(mousePos)
		get_parent().add_child(fireSpawn)
	$Wand.flip_h = (mousePos.x < position.x)
	if mousePos.x < position.x:
		$Wand.position.x = -23
		$Wand.offset = Vector2(-12, -12)
		$Wand.rotation_degrees += 90
	else:
		$Wand.position.x = 23
		$Wand.offset = Vector2(12, -12)
	if mousePos.y < position.y:
		$Wand.position.y = 10
	else:
		$Wand.position.y = 26

## CALLED BY ENEMY ON PLAYER
func hit():
	health -= 1
	if health == 0:
		# END GAME
		get_tree().paused = true

## RESET FIRE
func _on_wand_animation_finished() -> void:
	$Wand.play("default")
