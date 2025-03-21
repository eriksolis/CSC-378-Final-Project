class_name Player extends CharacterBody2D


enum DIRECTIONS {BACK, FRONT, SIDE}
var direction = DIRECTIONS.FRONT
enum MOTION {IDLE, WALK}
var motion = MOTION.IDLE
var health = 6
var maxHealth = 6
const SPEED = 300.0
var tween
var heartArray = []
var alt_fire = false
var dash = false
signal restart
signal title
@onready var fireball = load("res://scenes/fireball.tscn")
@onready var large_fireball = load("res://scenes/large_fireball.tscn")
@onready var heart = load("res://scenes/heart.tscn")

var dash_unlocked = false
var is_dashing = false
var dash_speed = 700.0  
var dash_time = 0.5
var dash_cooldown = 10
var can_dash = true
var dash_direction = Vector2.ZERO
@onready var dash_bar = $PlayerUI/DashCooldownBar
var cooldown = false
var progress = 10 
var bar_speed = 1.0

func _ready() -> void:
	$Camera2D.enabled = true
	add_to_group("Player", true)
	$PlayerUI/RestartMenu.hide()
	setHealth()
	dash_bar.visible = false
	if dash_bar:
		dash_bar.max_value = dash_cooldown
		dash_bar.value = dash_cooldown

func _process(delta: float) -> void:
	if dash_bar: 
		dash_bar.value = progress
	
	if cooldown:
		progress += bar_speed * delta
		if progress >= dash_cooldown:
			progress = dash_cooldown
			cooldown = false
			can_dash = true
			
func _physics_process(_delta: float) -> void:
	if is_dashing:
		velocity = dash_direction * dash_speed
		move_and_slide()
		return  
		
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
	
	if dash_unlocked and can_dash and Input.is_action_just_pressed("ui_dash"):
		start_dash()

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
	if Input.is_action_pressed("ui_accept") and $Wand.animation == "default":
		$Wand.play("fire")
		$Fire.pitch_scale = randf_range(0.9, 1)
		$Fire.play()
		var fireSpawn = fireball.instantiate()
		fireSpawn.global_position = $Wand/Marker2D.global_position
		fireSpawn.rotation = get_angle_to(mousePos)
		get_parent().add_child(fireSpawn)
	elif alt_fire and Input.is_action_pressed("ui_alt_fire") and $Wand.animation == "default":
		$Wand.play("alt_fire")
		$Fire.pitch_scale = randf_range(0.8, 0.9)
		$Fire.play()
		var fireSpawn = large_fireball.instantiate()
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
func hit(damage):
	$Hit.pitch_scale = randf_range(0.95, 1)
	$Hit.play()
	$Sprite.modulate.v = 3
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property($Sprite, "modulate:v", 1, 0.2)
	health -= damage
	updateHealth()
	await tween.finished
	if health <= 0:
		# END GAME
		MusicHandler.play("BitTragedy")
		get_tree().paused = true
		$PlayerUI/RestartMenu.show()

## RESET FIRE
func _on_wand_animation_finished() -> void:
	$Wand.play("default")

func setHealth():
	@warning_ignore("integer_division")
	var icons = health / 2
	if health % 2 == 1:
		icons += 1
	for i in range(0, icons):
		var healthIcon = heart.instantiate()
		heartArray.append(healthIcon)
		$PlayerUI/HealthIcons.add_child(healthIcon)
	updateHealth()


func updateHealth():
	@warning_ignore("integer_division")
	var startIndex = health / 2
	for i in range(startIndex, len(heartArray)):
		if i == startIndex and health % 2 == 1:
			if heartArray[i].get_children():
				heartArray[i].get_child(0).hide()
		elif heartArray[i].get_children():
			for child in heartArray[i].get_children():
				child.hide()


func heal():
	@warning_ignore("integer_division")
	if health + 2 > maxHealth:
		if health + 1 > maxHealth:
			return false
		else:
			health += 1
	else:
		health += 2
	var tracker = 0
	for i in range(0, len(heartArray)):
		var heartSprites = heartArray[i].get_children()
		heartSprites.reverse()
		for child in heartSprites:
			tracker += 1
			if tracker <= health:
				child.show()
			else:
				return true
	return true

func healthUpgrade():
	maxHealth += 2
	health = maxHealth
	for heart in heartArray:
		heart.queue_free()
	heartArray.clear()
	setHealth()

func unlock_dash():
	dash_unlocked = true

func enable_dash_bar():
	dash_bar.visible = true
	
func start_dash():
	if velocity.length() > 0: 
		is_dashing = true
		can_dash = false
		cooldown = true
		progress = 0
		dash_direction = velocity.normalized() 
		$DashTimer.start(dash_time)  
		$CooldownTimer.start(dash_cooldown)  
		
	if dash_bar:
		dash_bar.value = 0

func _on_restart_button_button_down() -> void:
	restart.emit()


func _on_title_button_button_down() -> void:
	title.emit()


func _on_dash_timer_timeout() -> void:
	is_dashing = false


func _on_cooldown_timer_timeout() -> void:
	can_dash = true
