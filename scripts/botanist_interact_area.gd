extends "res://scripts/astrologist_interact_area.gd"

func setCompleted():
	completed = true
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	if player:
		player.healthUpgrade()
	$Notification.hide()
