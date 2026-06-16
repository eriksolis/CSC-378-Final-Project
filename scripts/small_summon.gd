extends Sprite2D
@export var summon : PackedScene

func _ready() -> void:
	$Summon.pitch_scale = randf_range(0.3, 0.7)
	$Summon.play()
	$SummonManager.play("fadein")
	await $SummonManager.animation_finished
	var newSummon = summon.instantiate()
	newSummon.global_position = $SpawnPoint.global_position
	get_parent().add_child(newSummon)
	$SummonManager.play_backwards("fadein")
	await $SummonManager.animation_finished
	queue_free()
