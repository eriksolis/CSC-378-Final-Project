extends Area2D
var completed = false
var inProgress = false
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var boss = load("res://scenes/king_slime.tscn")

func _ready() -> void:
	$DialogueLayer.connect("dialogueFinished", setCompleted)
	$E.hide()

func _input(_event: InputEvent) -> void:
	if !inProgress and !completed and Input.is_action_just_pressed("ui_interact") and player in get_overlapping_bodies():
		inProgress = true
		$DialogueLayer.start()

func setCompleted():
	MusicHandler.play("SwarmingOnslaught")
	completed = true
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	# ENABLE ALL SUMMON CIRCLES UPON DIALOGUE COMPLETION
	for summonCircles in get_tree().get_nodes_in_group("Summon"):
		summonCircles.enable()
	# SPAWN BOSS
	await get_tree().create_timer(10).timeout
	var bossSpawn = boss.instantiate()
	get_parent().add_child(bossSpawn)


func _on_body_entered(body: Node2D) -> void:
	if !completed and !inProgress and body.is_in_group("Player"):
		$E.show()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$E.hide()
