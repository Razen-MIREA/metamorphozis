extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.body_entered.connect(give)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func give(body) -> void:
	if body.is_in_group("Player"):
		ClassGame.found()
