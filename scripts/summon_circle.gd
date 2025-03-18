extends Sprite2D

# add ranged slime
enum TYPES { BLUE, GREEN, RED, ORANGE, PURPLE, MUSHROOM, HEART, COMET, CLOUD, STAR, OVERGROWTH}
# add or decrease slime types allowed in the inspector panel
@export var slime_types = [TYPES.BLUE, TYPES.GREEN, TYPES.RED, TYPES.ORANGE]
# tracks if last spawn is heart slime
@export var heartSpawn = false

# load slimes
@onready var melee_slime_scene = load("res://scenes/slime.tscn")
@onready var ranged_slime_scene = load("res://scenes/ranged_slime.tscn")
@onready var purple_slime_scene = load("res://scenes/purple_slime.tscn")
@onready var mushroom_slime_scene = load("res://scenes/mushroom_slime.tscn")
@onready var heart_slime_scene = load("res://scenes/pink_slime.tscn")
@onready var comet_slime_scene = load("res://scenes/comet_slime.tscn")
@onready var cloud_slime_scene = load("res://scenes/cloud_slime.tscn")
@onready var star_slime_scene = load("res://scenes/star_slime.tscn")
@onready var overgrowth_slime_scene = load("res://scenes/overgrowth_slime.tscn")
var count = 0
var spawned = 0
@export var maxSpawns = 10
@export var summonDelay = 0.5
signal spawnComplete
signal spawnedClear

func enable() -> void:
	count = 0
	spawned = 0
	$SummonManager.play("fadein")
	await $SummonManager.animation_finished
	randomSummon(summonDelay)

func randomSummon(delay) -> void:
	count += 1
	spawned += 1
	var chosen_type
	var slime_scene
	if heartSpawn and count == maxSpawns:
		chosen_type = TYPES.HEART
	else:
		# randomly pick type from enum
		chosen_type = slime_types.pick_random()
	
	match chosen_type:
		TYPES.BLUE, TYPES.GREEN, TYPES.RED:
			slime_scene = melee_slime_scene
		TYPES.ORANGE:
			slime_scene = ranged_slime_scene
		TYPES.PURPLE:
			slime_scene = purple_slime_scene
		TYPES.MUSHROOM:
			slime_scene = mushroom_slime_scene
		TYPES.HEART:
			slime_scene = heart_slime_scene
		TYPES.COMET:
			slime_scene = comet_slime_scene
		TYPES.CLOUD:
			slime_scene = cloud_slime_scene
		TYPES.STAR:
			slime_scene = star_slime_scene
		TYPES.OVERGROWTH:
			slime_scene = overgrowth_slime_scene

	var enemySpawn = slime_scene.instantiate()

	# if a melee slime, set the "type" so it knows which color/animation to use
	if chosen_type == TYPES.BLUE or chosen_type == TYPES.GREEN or chosen_type == TYPES.RED:
		enemySpawn.type = chosen_type
	enemySpawn.connect("enemyDead", checkSpawned)

	# pos of slime at our SpawnPoint
	enemySpawn.global_position = $SpawnPoint.global_position
	
	match chosen_type:
		TYPES.BLUE:
			$Glow.self_modulate = Color("ffffff")
		TYPES.GREEN:
			$Glow.self_modulate = Color("#b6ffbe")
		TYPES.RED:
			$Glow.self_modulate = Color("#ffa19e")
		TYPES.ORANGE:
			$Glow.self_modulate = Color("#ce8a3f")
		TYPES.PURPLE:
			$Glow.self_modulate = Color("#BE74E6")
		TYPES.MUSHROOM:
			$Glow.self_modulate = Color("#BD054A")
		TYPES.HEART:
			$Glow.self_modulate = Color("#E47B9C")

	$SummonManager.play("summon")
	await $SummonManager.animation_finished

	get_parent().add_child(enemySpawn)

	$SummonManager.play_backwards("summon")
	await $SummonManager.animation_finished

	# spawn until reach maxSpawns
	if count < maxSpawns:
		await get_tree().create_timer(delay).timeout
		randomSummon(randf_range(delay - 0.5, delay + 0.5))
	else:
		$SummonManager.play_backwards("fadein")
		await $SummonManager.animation_finished
		spawnComplete.emit()

func checkSpawned():
	spawned -= 1
	if spawned <= 0 and count >= maxSpawns:
		print("done with count " + str(maxSpawns))
		spawnedClear.emit()
		spawned = 0
		count = 0
