extends Sprite2D

# add ranged slime
enum TYPES { BLUE, GREEN, RED, RANGED }
var slime_types = [TYPES.BLUE, TYPES.GREEN, TYPES.RED, TYPES.RANGED]

# load slimes
@onready var melee_slime_scene = load("res://scenes/slime.tscn")
@onready var ranged_slime_scene = load("res://scenes/ranged_slime.tscn")
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
	# randomly pick type from enum
	var chosen_type = slime_types.pick_random()
	var slime_scene
	match chosen_type:
		TYPES.BLUE, TYPES.GREEN, TYPES.RED:
			slime_scene = melee_slime_scene
		TYPES.RANGED:
			slime_scene = ranged_slime_scene

	var enemySpawn = slime_scene.instantiate()

	# if a melee slime, set the "type" so it knows which color/animation to use
	if chosen_type != TYPES.RANGED:
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
		TYPES.RANGED:
			$Glow.self_modulate = Color("#ce8a3f")

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
