extends Sprite2D
@onready var enemy = load("res://scenes/slime.tscn")
enum TYPES {BLUE, GREEN, RED}
var enemyTypes = [TYPES.BLUE, TYPES.GREEN, TYPES.RED]
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
	var type = enemyTypes.pick_random()
	var enemySpawn =  enemy.instantiate()
	enemySpawn.type = type
	enemySpawn.connect("enemyDead", checkSpawned)
	enemySpawn.global_position = $SpawnPoint.global_position
	match type:
		TYPES.BLUE:
			$Glow.self_modulate = Color("ffffff")
		TYPES.GREEN:
			$Glow.self_modulate = Color("#b6ffbe")
		TYPES.RED:
			$Glow.self_modulate = Color("#ffa19e")
	$SummonManager.play("summon")
	await $SummonManager.animation_finished
	get_parent().add_child(enemySpawn)
	$SummonManager.play_backwards("summon")
	await $SummonManager.animation_finished
	if count < maxSpawns:
		await get_tree().create_timer(delay).timeout
		randomSummon(randf_range(delay - 0.5, delay + 0.5))
	else:
		$SummonManager.play_backwards("fadein")
		await $SummonManager.animation_finished
		# Connect this signal to whatever script wants
		# to know that all enemies have spawned.
		spawnComplete.emit()

func checkSpawned():
	spawned -= 1
	if spawned <= 0 and count >= maxSpawns:
		# Connect this signal to whatever script wants 
		# to know that all enemies are dead.
		print("done with count " + str(maxSpawns))
		spawnedClear.emit()
		spawned = 0
		count = 0
