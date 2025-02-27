extends CanvasLayer
var tween
@export var dialogue = ["This is dialogue.", "hello","i like turtles :>"]
@export var image = load("res://images/npcs/magnus/000.png")
@export var characterName = "Magnus"
@onready var dialogueLabel = $DialogueBox/MarginContainer/HBoxContainer/Dialogue
signal dialogueFinished

var current = 0
var textSpeed = 0.05

func _ready() -> void:
	hide()
	if image == null:
		$DialogueBox/MarginContainer/HBoxContainer/CharacterDetails.hide()
	else:
		$DialogueBox/MarginContainer/HBoxContainer/CharacterDetails/Portrait.texture = image
		$DialogueBox/MarginContainer/HBoxContainer/CharacterDetails/Name.text = characterName

func start() -> void:
	show()
	current = 0
	display(dialogue[current])

func display(text):
	dialogueLabel.visible_characters = 0
	dialogueLabel.text = text
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	var totalCharacters = len(dialogueLabel.text)
	tween.tween_method(nextChar, 0, totalCharacters, totalCharacters * textSpeed)

func nextChar(value: int):
	dialogueLabel.visible_characters = value
	if !$Click1.playing:
		$Click1.pitch_scale = randf_range(0.9, 1)
		$Click1.play()

func _input(_event: InputEvent) -> void:
	if visible and Input.is_action_just_pressed("ui_interact"):
		if !$Click1.playing:
			$Click1.pitch_scale = randf_range(0.9, 1)
			$Click1.play()
		var currentCharacters = dialogueLabel.visible_characters
		var totalCharacters = len(dialogueLabel.text)
		if currentCharacters != totalCharacters and currentCharacters != -1:
			if tween:
				tween.kill()
			dialogueLabel.visible_characters = -1
		else:
			if current + 1 < len(dialogue):
				current += 1
				display(dialogue[current])
			else:
				hide()
				dialogueFinished.emit()
