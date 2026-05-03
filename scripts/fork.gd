extends Sprite2D

var start_pos : Vector2

func _ready() -> void:
	start_pos = position
	$Area2D.body_entered.connect(_on_body_entered)
	# Запускаем цикл ударов
	start_strike_cycle()
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.explode() # Убиваем врага

func start_strike_cycle():
	var tween = create_tween().set_loops() # Делаем цикл бесконечным
	
	# 1. РЕЗКИЙ УДАР ВНИЗ
	# TRANS_CUBIC и EASE_IN дают эффект ускорения при падении
	tween.tween_property(self, "position:y", start_pos.y + 400, 0.1)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
	
	# 2. НЕБОЛЬШАЯ ПАУЗА В ПОЛУ (для дофамина, эффект застревания)
	tween.tween_interval(0.2)
	
	# 3. МЕДЛЕННЫЙ ВОЗВРАТ ВВЕРХ
	# TRANS_SINE дает плавное движение
	tween.tween_property(self, "position:y", start_pos.y, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	# 4. ПАУЗА ПЕРЕД СЛЕДУЮЩИМ УДАРОМ
	tween.tween_interval(0.5)
