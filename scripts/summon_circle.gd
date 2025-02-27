extends Sprite2D
@onready var enemy = load("res://scenes/slime.tscn")
enum TYPES {BLUE, GREEN, RED}
var enemyTypes = [TYPES.BLUE, TYPES.GREEN, TYPES.RED]

func enable() -> void:
	$SummonManager.play("fadein")
	await $SummonManager.animation_finished
	randomSummon(5)

func randomSummon(delay) -> void:
	var type = enemyTypes.pick_random()
	var enemySpawn =  enemy.instantiate()
	enemySpawn.type = type
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
	await get_tree().create_timer(delay).timeout
	randomSummon(randi_range(4, 6))
