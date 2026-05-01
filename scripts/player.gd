extends CharacterBody2D

var LOSE = false

# Настройки
const WALK_SPEED = 600.0
const JUMP_VELOCITY = 700.0 * -1.0
const GRAVITY = 1800.0
const THRUST_POWER = 1200.0 
const GROWTH_SPEED = 1.0
const SHRINK_SPEED = 2.0
const MAX_SCALE = 10.0
const MIN_SCALE = 1.0

func _ready() -> void:
	$AnimatedSprite2D.scale = Vector2.ONE * MIN_SCALE
	$AnimatedSprite2D.play("Idle")

func _physics_process(delta: float) -> void:
	if LOSE:
		velocity = velocity.lerp(Vector2.ZERO, 0.05)
		move_and_slide()
		return

	var is_jetting = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	var sprite = $AnimatedSprite2D
	
	if is_jetting:
		# --- РЕЖИМ ПОЛЕТА (JET) ---
		sprite.scale = sprite.scale.lerp(Vector2.ONE * MIN_SCALE, SHRINK_SPEED * delta)
		
		var mouse_pos = get_global_mouse_position()
		var dir = (mouse_pos - global_position - $Camera2D.position).normalized() # Убрал лишнюю камеру из расчета
		
		# В режиме полета мы игнорируем гравитацию, чтобы не "проседать"
		velocity = velocity.lerp(dir * THRUST_POWER, 0.1) 
		sprite.rotation = lerp_angle(sprite.rotation, velocity.angle(), 0.2)
		
		# Если есть анимация полета — включи её тут
	else:
		# --- РЕЖИМ ПЛАТФОРМЕРА (POP) ---
		sprite.rotation = lerp_angle(sprite.rotation, 0, 0.1)
		
		# Рост
		if sprite.scale.x < MAX_SCALE:
			sprite.scale += Vector2.ONE * GROWTH_SPEED * delta
		
		if sprite.scale.x >= MAX_SCALE:
			explode()

		# Гравитация работает ТОЛЬКО когда мы не летим
		velocity.y += GRAVITY * delta
		
		# Управление влево-вправо
		var input_dir = Input.get_axis("left", "right")
		if input_dir != 0:
			velocity.x = input_dir * WALK_SPEED
			sprite.flip_h = input_dir < 0
		else:
			velocity.x = move_toward(velocity.x, 0, WALK_SPEED * 0.2)
			if is_on_floor(): sprite.play("Idle") # ВОЗВРАТ В IDLE

		# ПРЫЖОК
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			sprite.play("Jump")

	# Ограничение скорости
	velocity = velocity.limit_length(1500)

	move_and_slide()
	
	# ФИНКС АНИМАЦИИ: Если приземлились, но ничего не жмем — Idle
	if is_on_floor() and velocity.x == 0 and not is_jetting:
		sprite.play("Idle")

	# Обновление хитбокса
	$CollisionShape2D.shape.radius = $AnimatedSprite2D.scale.x * 2.0

func explode():
	if LOSE: return
	LOSE = true
	$AnimatedSprite2D.play("Boom")
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "scale", $AnimatedSprite2D.scale * 1.3, 0.1)
	tween.tween_property($AnimatedSprite2D, "modulate:a", 0.0, 0.3)
	get_tree().create_timer(4.0/5).timeout.connect(func(): get_tree().reload_current_scene())
