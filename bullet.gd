extends Area2D

var direction = Vector2.ZERO # Это мы установим из игрока
var speed = 1500.0

func _ready():
	# Поворачиваем пулю по вектору полета
	if direction != Vector2.ZERO:
		rotation = direction.angle()
	# Удаляем через 3 секунды, чтобы не копить мусор
	get_tree().create_timer(3.0).timeout.connect(queue_free)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("Enemies"):
		body.queue_free() # Убиваем врага
	queue_free() # Сама пуля лопается
