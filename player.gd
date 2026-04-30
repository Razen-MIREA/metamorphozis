extends AnimatedSprite2D

var LOSE = false

# Настройки платформера
const WALK_SPEED = 300.0
const JUMP_VELOCITY = -600.0
const GRAVITY = 1500.0

# Настройки JET-POP
const THRUST_POWER = 300.0
const GROWTH_SPEED = 1
const SHRINK_SPEED = 2.0
const MAX_SCALE = 10.0
const MIN_SCALE = 0.6

var velocity = Vector2.ZERO

func _ready() -> void:
	play("Idle")

func _physics_process(delta: float) -> void:
	if LOSE:
		velocity = velocity.lerp(Vector2.ZERO, 0.05) # Плавная остановка
		position += velocity * delta
		return
	# --- 1. ЛОГИКА МЕТАМОРФОЗЫ (СДУВАЛКА НА МЫШКУ) ---
	var is_jetting = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	
	if is_jetting:
		# Сдуваемся
		scale = scale.lerp(Vector2.ONE * MIN_SCALE, SHRINK_SPEED * delta)
		
		# Летим к мышке (Тяга)
		var dir_to_mouse = (get_global_mouse_position() - global_position).normalized()
		velocity += dir_to_mouse * THRUST_POWER * delta * 4.0
		
		# Визуальный наклон в сторону полета
		rotation = lerp_angle(rotation, velocity.angle(), 0.1)
	else:
		# Состояние: ОБЫЧНОЕ ЖЕЛЕ
		rotation = lerp_angle(rotation, 0, 0.1)
		
		# Растем со временем
		if scale.x < MAX_SCALE:
			scale += Vector2.ONE * GROWTH_SPEED * delta
		
		# Проверка на взрыв (если слишком раздулся)
		if scale.x >= MAX_SCALE:
			explode()

		# --- 2. ОБЫЧНОЕ УПРАВЛЕНИЕ (ПЛАТФОРМЕР) ---
		# Гравитация
		velocity.y += GRAVITY * delta
		
		# Влево / Вправо
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * WALK_SPEED
			flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, WALK_SPEED * 0.1)

		# Прыжок (только когда не летим на тяге)
		if Input.is_action_just_pressed("Jump") and is_on_floor_fake():
			velocity.y = JUMP_VELOCITY

	# Ограничение максимальной скорости
	velocity = velocity.limit_length(2000)

	# Применяем движение
	position += velocity * delta
	
	# Фейковое столкновение с полом (пока нет стен)
	# В будущем замени position на move_and_slide(), если сменишь узел на CharacterBody2D
	if position.y > 600:
		position.y = 600
		velocity.y = 0

# Функция проверки "на земле" (упрощенная)
func is_on_floor_fake() -> bool:
	return position.y >= 600

func explode():
	if LOSE: return # Чтобы не вызывалось дважды
	LOSE = true
	play("Boom")
	
	# Эффектный "вздув" перед удалением
	var tween = create_tween()
	tween.tween_property(self, "scale", scale * 1.2, 0.1) # Слегка увеличиваем
	tween.tween_property(self, "modulate:a", 0.0, 0.2)   # Исчезаем (прозрачность)
	
	# Таймер на рестарт
	get_tree().create_timer(0.8).timeout.connect(
		func(): get_tree().reload_current_scene()
	)
