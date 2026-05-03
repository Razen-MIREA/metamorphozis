extends Area2D

func _ready() -> void:
	await get_tree().process_frame
	body_entered.connect(spawn)

func spawn(body):
	if body.is_in_group("Player"):
		var marker = get_child(1)
		var enemyName = marker.name
		
		var scene_path = "res://models/Enemy_" + enemyName + ".tscn"
		var enemy_scene = load(scene_path)
		
		var health_scene = load("res://models/health_bar.tscn")
		
		for i in range(3):
			var enemy : Node2D = enemy_scene.instantiate()
			#enemy.add_to_group("Enemy")
			enemy.name = enemyName + str(i)
			enemy.global_position = marker.global_position + Vector2(randf_range(-5.0, 5.0), 0)
			get_parent().call_deferred("add_child", enemy)
			
			var health = health_scene.instantiate()
			health.position = Vector2(415, 200)
			enemy.get_children()[0].add_child(health)
		queue_free()
