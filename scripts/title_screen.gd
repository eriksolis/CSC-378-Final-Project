extends Control
@onready var game = load("res://scenes/game.tscn")
@onready var musicVolume = AudioServer.get_bus_index("Music")
@onready var sfxVolume = AudioServer.get_bus_index("SFX")
var loadedGame

func _ready() -> void:
	MusicHandler.play("SquareDreams")
	$SettingsMenu.hide()
	$CreditsPanel.hide()

func _on_start_button_pressed() -> void:
	MusicHandler.play("PixelizedFields")
	$Click.play()
	loadedGame = game.instantiate()
	loadedGame.get_node("Player").connect("restart", restart)
	loadedGame.get_node("Player").connect("title", title)
	get_parent().add_child(loadedGame)
	get_tree().paused = false
	hide()


func _on_quit_button_pressed() -> void:
	$Click.play()
	get_tree().quit()

func restart():
	MusicHandler.play("PixelizedFields")
	loadedGame.queue_free()
	_on_start_button_pressed()

func title():
	MusicHandler.play("SquareDreams")
	loadedGame.queue_free()
	show()

func _on_settings_button_pressed() -> void:
	$Click.play()
	$SettingsMenu/MenuMargin/MenuOptions/MusicContainer/MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(musicVolume))
	$SettingsMenu/MenuMargin/MenuOptions/SFXContainer/SFXSlider.value = db_to_linear(AudioServer.get_bus_volume_db(sfxVolume))
	$SettingsMenu.show()

func _on_credits_button_pressed() -> void:
	$Click.play()
	$CreditsPanel.show()


func _on_return_button_pressed() -> void:
	$Click.play()
	$SettingsMenu.hide()
	$CreditsPanel.hide()


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(musicVolume, linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfxVolume, linear_to_db(value))


func _on_fullscreen_checkbox_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
