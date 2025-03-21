extends Sprite2D
@export var summon : PackedScene
signal bossComplete
var enabled = false
var completed = false

func enable() -> void:
	if !enabled and summon:
		enabled = true
		$SummonManager.play("fadein")
		await $SummonManager.animation_finished
		var newSummon = summon.instantiate()
		newSummon.connect("bossDead", _on_boss_dead)
		newSummon.global_position = $SpawnPoint.global_position
		get_parent().add_child(newSummon)
		$SummonManager.play_backwards("fadein")

func _on_boss_dead() -> void:
	if completed == false:
		completed = true
		bossComplete.emit()
		queue_free()
