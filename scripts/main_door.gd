extends Sprite2D

func _ready() -> void:
	$Area2D.body_entered.connect(open)

func open(body: Node2D):
	if body.is_in_group("Player"):
		ClassGame.change()
		# Вызываем смену сцены отложенно
		get_tree().call_deferred("change_scene_to_file", "res://End.tscn")
