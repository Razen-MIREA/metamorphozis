extends Node2D

func _ready():
	$Button.pressed.connect(_on_exit_button_pressed)

# Вызывается при нажатии кнопки "Выход"
func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://Menu.tscn")
