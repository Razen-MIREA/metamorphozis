extends Node2D

func _ready() -> void:
	# Даем кадру загрузиться, прежде чем спавнить толпу
	await get_tree().process_frame 
	
	for spawn_point in get_children():
		var enemyName = spawn_point.name
		
		var scene_path = "res://models/Enemy_" + enemyName + ".tscn"
		var enemy_scene = load(scene_path)
		
		var health_scene = load("res://models/health_bar.tscn")
		
		for i in range(3):
			var enemy : Node2D = enemy_scene.instantiate()
			#enemy.add_to_group("Enemy")
			enemy.name = enemyName + str(i)
			enemy.global_position = spawn_point.global_position + Vector2(randf_range(-5.0, 5.0), 0)
			get_parent().add_child(enemy)
			
			var health = health_scene.instantiate()
			health.position = Vector2(415, 200)
			enemy.get_children()[0].add_child(health)
