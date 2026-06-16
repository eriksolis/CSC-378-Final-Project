extends Sprite2D
@export var summon : PackedScene
signal minibossComplete
var enabled = false
var completed = false

func enable() -> void:
	if !enabled and summon:
		$Summon.play()
		enabled = true
		$SummonManager.play("fadein")
		await $SummonManager.animation_finished
		var newSummon = summon.instantiate()
		newSummon.connect("minibossDead", _on_miniboss_dead)
		newSummon.global_position = $SpawnPoint.global_position
		get_parent().add_child(newSummon)
		$SummonManager.play_backwards("fadein")

func _on_miniboss_dead() -> void:
	if completed == false:
		completed = true
		minibossComplete.emit()
		queue_free()
