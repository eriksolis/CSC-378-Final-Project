extends Control
@onready var musicVolume = AudioServer.get_bus_index("Music")
@onready var sfxVolume = AudioServer.get_bus_index("SFX")
var first = false

func _ready() -> void:
	MusicHandler.play("SquareDreams")
	$SettingsMenu.hide()
	$CreditsPanel.hide()
	$CanvasLayer.hide()

func _on_start_button_pressed() -> void:
	MusicHandler.play("PixelizedFields")
	$Click.play()
	scene_manager.resetGame()
	scene_manager.change_scene("game")
	scene_manager.player.connect("restart", restart)
	scene_manager.player.connect("title", title)
	get_tree().paused = false
	hide()


func _on_quit_button_pressed() -> void:
	$Click.play()
	get_tree().quit()

func restart():
	MusicHandler.play("PixelizedFields")
	scene_manager.clearScenes()
	_on_start_button_pressed()

func title():
	MusicHandler.play("SquareDreams")
	scene_manager.clearScenes()
	$CanvasLayer.hide()
	$Background.show()
	$Logo.show()
	$VBoxContainer.show()
	show()

func _on_settings_button_pressed() -> void:
	$Click.play()
	if DisplayServer.window_get_mode() == 3:
		$SettingsMenu/MenuMargin/MenuOptions/FullscreenCheckbox.set_pressed_no_signal(true)
	else:
		$SettingsMenu/MenuMargin/MenuOptions/FullscreenCheckbox.set_pressed_no_signal(false)
	$SettingsMenu/MenuMargin/MenuOptions/MusicContainer/MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(musicVolume))
	$SettingsMenu/MenuMargin/MenuOptions/SFXContainer/SFXSlider.value = db_to_linear(AudioServer.get_bus_volume_db(sfxVolume))
	$SettingsMenu.show()

func _on_pause_settings_button_pressed() -> void:
	$Click.play()
	if DisplayServer.window_get_mode() == 3:
		$CanvasLayer/PauseMenu/SettingsMenu/MenuMargin/MenuOptions/FullscreenCheckbox.set_pressed_no_signal(true)
	else:
		$CanvasLayer/PauseMenu/SettingsMenu/MenuMargin/MenuOptions/FullscreenCheckbox.set_pressed_no_signal(false)
	$CanvasLayer/PauseMenu/SettingsMenu/MenuMargin/MenuOptions/MusicContainer/MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(musicVolume))
	$CanvasLayer/PauseMenu/SettingsMenu/MenuMargin/MenuOptions/SFXContainer/SFXSlider.value = db_to_linear(AudioServer.get_bus_volume_db(sfxVolume))
	$CanvasLayer/PauseMenu/SettingsMenu.show()

func _on_credits_button_pressed() -> void:
	$Click.play()
	$CreditsPanel.show()


func _on_return_button_pressed() -> void:
	$Click.play()
	$SettingsMenu.hide()
	$CreditsPanel.hide()

func _on_pause_return_button_pressed() -> void:
	$Click.play()
	$CanvasLayer/PauseMenu/SettingsMenu.hide()


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(musicVolume, linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfxVolume, linear_to_db(value))


func _on_fullscreen_checkbox_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_title_button_pressed() -> void:
	$Click.play()
	title()


func _on_resume_button_pressed() -> void:
	hide()
	$CanvasLayer.hide()
	$Background.show()
	$Logo.show()
	$VBoxContainer.show()
	$SettingsMenu.show()
	$CreditsPanel.show()
	get_tree().paused = false


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused and $CanvasLayer.visible:
			_on_resume_button_pressed()
		elif !get_tree().paused and !$CanvasLayer.visible and !visible:
			$Background.hide()
			$Logo.hide()
			$VBoxContainer.hide()
			$SettingsMenu.hide()
			$CreditsPanel.hide()
			$CanvasLayer.show()
			get_tree().paused = true
			show()
