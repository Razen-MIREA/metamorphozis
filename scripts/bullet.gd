extends Area2D

var speed = 1000.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		var dmg = ClassGame.getDMG()
		var health_bar = body.get_child(2).find_child("HealthBar", true, false) 
		
		if health_bar and health_bar.has_method("takeDMG"):
			health_bar.takeDMG(body, dmg)
		queue_free()
	elif not body.is_in_group("Player"):
		queue_free()

func _physics_process(delta):
	# Движение в сторону поворота (куда смотрит нос)
	# Vector2.RIGHT.rotated(rotation) — это универсальный способ
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
