extends Node2D

func _ready():
	$Button.pressed.connect(_on_exit_button_pressed)
	achivements()

# Вызывается при нажатии кнопки "Выход"
func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://Menu.tscn")

func achivements():
	$AchivePre.text += '\n'
	var bigraf = ClassGame.is_found()
	var paccifist = (ClassGame.killcounter() == 0)
	var genocide = (ClassGame.killcounter() == 27)
	
	if genocide:
		$AchivePre.text += "Вы всех убили, вы совершили Геноцид!\n"
	elif paccifist:
		$AchivePre.text += "Вы никого не убили, вы Пацифист!\n"
	else:
		$AchivePre.text += "Вы совершели не все убийства, так что вы имеете что-то доброе в своем сердце!\n"
	
	if bigraf:
		$AchivePre.text += "Вы нашли большой Лавандовый Раф!\n"
	else:
		$AchivePre.text += "Вы не нашли большой Лавандовый Раф! ( в конце =D )\n"
