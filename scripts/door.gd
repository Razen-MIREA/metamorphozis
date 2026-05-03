extends Sprite2D

func _ready() -> void:
	$Area2D.body_entered.connect(open)

func open(body: Node2D):
	if body.is_in_group("Player"):
		queue_free()
