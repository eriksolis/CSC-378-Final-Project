extends Sprite2D
@export var summon : PackedScene

func _ready() -> void:
	$SummonManager.play("fadein")
	await $SummonManager.animation_finished
	var newSummon = summon.instantiate()
	newSummon.global_position = $SpawnPoint.global_position
	get_parent().add_child(newSummon)
	$SummonManager.play_backwards("fadein")
	await $SummonManager.animation_finished
	queue_free()
