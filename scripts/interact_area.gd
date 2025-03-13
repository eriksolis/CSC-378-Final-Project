extends Area2D
var completed = false
var inProgress = false
var summon_circles = 0
var completed_summons = 0
enum STATES{PRESTAGE, POSTSTAGE, PREBOSS, POSTBOSS}
var state = STATES.PRESTAGE
@onready var player = scene_manager.player
var post_stage_dialogue = ["Now that you have defeated the slimes, head back out of the room. >", "I sense more magical entities appearing in another area."]

func _ready() -> void:
	$DialogueLayer.connect("dialogueFinished", setCompleted)
	$E.hide()

func _input(_event: InputEvent) -> void:
	if !inProgress and !completed and Input.is_action_just_pressed("ui_interact") and player in get_overlapping_bodies():
		inProgress = true
		$DialogueLayer.start()

func setCompleted():
	match state:
		STATES.PRESTAGE:
			MusicHandler.play("SwarmingOnslaught")
			completed = true
			set_deferred("monitorable", false)
			set_deferred("monitoring", false)
			# ENABLE ALL SUMMON CIRCLES UPON DIALOGUE COMPLETION
			for summonCircles in get_tree().get_nodes_in_group("Summon"):
				summonCircles.enable()
				summonCircles.connect("spawnedClear", _on_summon_depleted)
				summon_circles += 1
		STATES.POSTSTAGE:
			completed = true
			set_deferred("monitorable", false)
			set_deferred("monitoring", false)
			get_parent().get_node("SceneTrigger").enable()
			scene_manager.enableRoom2()
	$Notification.hide()


func _on_body_entered(body: Node2D) -> void:
	if !completed and !inProgress and body.is_in_group("Player"):
		$E.show()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$E.hide()

func _on_summon_depleted():
	completed_summons += 1
	if completed_summons >= summon_circles and state == STATES.PRESTAGE:
		state = STATES.POSTSTAGE
		inProgress = false
		completed = false
		$DialogueLayer.dialogue = post_stage_dialogue
		MusicHandler.play("PixelizedFields")
		set_deferred("monitorable", true)
		set_deferred("monitoring", true)
		$Notification.show()
