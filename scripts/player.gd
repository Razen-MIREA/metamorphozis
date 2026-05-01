extends CharacterBody2D

var LOSE = false

# Настройки
const WALK_SPEED = 600.0
const JUMP_VELOCITY = 700.0 * -1.0
const GRAVITY = 1800.0
const THRUST_POWER = 1200.0 
const GROWTH_SPEED = 1.0
const SHRINK_SPEED = 2.0
const MAX_SCALE = 25.0
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
		var dir = (mouse_pos - $Camera2D.position - global_position).normalized()
		
		# Плавно меняем вектор скорости в сторону мыши
		velocity = velocity.lerp(dir * THRUST_POWER, 0.1) 
		sprite.rotation = lerp_angle(sprite.rotation, velocity.angle(), 0.2)
	else:
		# --- РЕЖИМ ПЛАТФОРМЕРА (POP) ---
		sprite.rotation = lerp_angle(sprite.rotation, 0, 0.1)
		
		# Рост
		if sprite.scale.x < MAX_SCALE:
			sprite.scale += Vector2.ONE * GROWTH_SPEED * delta
		
		if sprite.scale.x >= MAX_SCALE:
			explode()

		# Гравитация (CharacterBody2D требует прибавления к velocity)
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		
		# Управление влево-вправо
		var input_dir = Input.get_axis("left", "right")
		if input_dir != 0:
			velocity.x = input_dir * WALK_SPEED
			sprite.flip_h = input_dir < 0
		else:
			velocity.x = move_toward(velocity.x, 0, WALK_SPEED * 0.2)

		# ПРЫЖОК (теперь через родную функцию Godot)
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	# Ограничение скорости
	velocity = velocity.limit_length(1500)

	# --- ДВИЖЕНИЕ (СУТЬ CHARACTERBODY2D) ---
	# move_and_slide сама обрабатывает дельту и столкновения
	move_and_slide()
	
	# Эффект отскока после move_and_slide
	if get_slide_collision_count() > 0:
		var collision = get_last_slide_collision()
		if is_jetting: # Отскакиваем только в режиме полета для драйва
			velocity = velocity.bounce(collision.get_normal()) * 0.5
	
	$CollisionShape2D.shape.radius = $AnimatedSprite2D.scale.x * 2.0

func explode():
	if LOSE: return
	LOSE = true
	$AnimatedSprite2D.play("Boom")
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "scale", $AnimatedSprite2D.scale * 1.3, 0.1)
	tween.tween_property($AnimatedSprite2D, "modulate:a", 0.0, 0.3)
	get_tree().create_timer(0.8).timeout.connect(func(): get_tree().reload_current_scene())
