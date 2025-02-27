extends Area2D
var completed = false
var inProgress = false
@onready var player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	$DialogueLayer.connect("dialogueFinished", setCompleted)
	$E.hide()

func _input(event: InputEvent) -> void:
	if !inProgress and !completed and Input.is_action_just_pressed("ui_interact") and player in get_overlapping_bodies():
		inProgress = true
		$DialogueLayer.start()

func setCompleted():
	completed = true
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)


func _on_body_entered(body: Node2D) -> void:
	if !completed and body.is_in_group("Player"):
		$E.show()


func _on_body_exited(body: Node2D) -> void:
	$E.hide()
