extends Node2D

func _ready() -> void:
	# Даем кадру загрузиться, прежде чем спавнить толпу
	await get_tree().process_frame 
	
	for spawn_point in get_children():
		var enemyName = spawn_point.name
		var scene_path = "res://models/Enemy_" + enemyName + ".tscn"
		
		# Проверяем, существует ли файл, чтобы не вылетело
		if not ResourceLoader.exists(scene_path):
			print("Ошибка: Нет файла ", scene_path)
			continue
			
		var enemy_scene = load(scene_path)
		
		for i in range(3):
			var enemy = enemy_scene.instantiate()
			
			# Устанавливаем позицию маркера
			# Добавляем рандомный разброс, чтобы они не застревали друг в друге
			enemy.global_position = spawn_point.global_position + Vector2(randf_range(-1, 1), 0)
			
			# ДОБАВЛЯЕМ В РОДИТЕЛЯ СПАВНЕРА (на саму карту)
			# Это решает ошибку "already has a parent"
			get_parent().add_child(enemy)
