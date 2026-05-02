extends Sprite2D

@export var rotation_speed: float = 1.0 # Время одного полного оборота в секундах

func _ready() -> void:
	start_rotation()

func start_rotation():
	# Создаем бесконечный цикл вращения
	var tween = create_tween().set_loops()
	
	# Поворачиваем на 360 градусов (TAU в Godot — это 2 * PI, полный круг)
	# Используем TRANS_LINEAR, чтобы скорость не менялась в процессе
	tween.tween_property(self, "rotation", rotation, rotation_speed)\
		.as_relative()\
		.set_trans(Tween.TRANS_LINEAR)
