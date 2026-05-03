extends Node2D

func _ready():
	$ExitButton.pressed.connect(_on_exit_button_pressed)
	$PlayButton.pressed.connect(_on_load_button_pressed)
	$FinishButton.pressed.connect(_on_finish_press)
	if not ClassGame.finished():
		$FinishButton.hide()

# Вызывается при нажатии кнопки "Выход"
func _on_exit_button_pressed():
	get_tree().quit() # Завершает работу приложения

# Вызывается при нажатии кнопки "Загрузить"
func _on_load_button_pressed():
	# Замените путь на вашу сцену с игрой
	get_tree().change_scene_to_file("res://Game.tscn")

func _on_finish_press():
	get_tree().change_scene_to_file("res://End.tscn")
