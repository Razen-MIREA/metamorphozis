extends CanvasLayer

func _process(delta: float) -> void:
	var kills = ClassGame.killcounter()
	var enemies = ClassGame.enemycounter()
	$Kills.text = "Kills: " + str(kills)
	$Counter.text = "Enemies: " + str(enemies)
