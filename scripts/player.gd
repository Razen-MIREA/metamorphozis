extends CharacterBody2D

var LOSE = false

# Настройки
const WALK_SPEED = 600.0
const JUMP_VELOCITY = 700.0 * -1.0
const GRAVITY = 1800.0
const THRUST_POWER = 900.0
const GROWTH_SPEED = 1.0
const SHRINK_SPEED = 2.0
const MAX_SCALE = 10.0
const MIN_SCALE = 1.0

var health = 100.0

func _on_hit_box_body_entered(body: Node2D) -> void:
	#print(body.name)
	if body.is_in_group("Enemy"):
		health -= 10.0
		get_child(4).get_child(0).takeDMG(self, 10.0)
	elif body.is_in_group("Raf1"):
		ClassGame.setDMG(33.4)
		get_child(4).get_child(0).takeDMG(self, health - 100.0)
		modulate = Color(0.792, 0.0, 0.976, 1.0)
		sound2.play()
		body.queue_free()
	elif body.is_in_group("Raf2"):
		ClassGame.setDMG(50.0)
		get_child(4).get_child(0).takeDMG(self, health - 100.0)
		modulate = Color(0.991, 0.992, 0.15, 1.0)
		sound2.play()
		body.queue_free()
	elif body.is_in_group("Finish"):
		ClassGame.change()
		get_tree().change_scene_to_file("res://End.tscn")
	elif body.is_in_group("rafBig"):
		ClassGame.found()

var pop = AudioStreamPlayer2D.new()
var sound = AudioStreamPlayer2D.new()
var sound2 = AudioStreamPlayer2D.new()
var music = AudioStreamPlayer2D.new()

func _ready() -> void:
	ClassGame.setDMG(20.0)
	sound.stream = load("res://assets/sfx/bulletEffect.wav")
	call_deferred("add_child", sound)
	sound.volume_linear = 0.15
	
	sound2.stream = load("res://assets/sfx/Victory Fanfare.wav")
	call_deferred("add_child", sound2)
	sound2.volume_linear = 0.15
	
	pop.stream = load("res://assets/sfx/pop.mp3")
	call_deferred("add_child", pop)
	pop.volume_linear = 0.15
	
	music.stream = load("res://assets/sfx/bg_music.mp3")
	call_deferred("add_child", music)
	music.volume_linear = 0.2
	
	$AnimatedSprite2D.scale = Vector2.ONE * MIN_SCALE
	$AnimatedSprite2D.play("Idle")
	$Area2D.body_entered.connect(_on_hit_box_body_entered)
	var health = load("res://models/health_bar.tscn").instantiate()
	health.position = Vector2(415, 250)
	add_child(health)
	
	await get_tree().process_frame
	#music.play()
	
# В самом верху скрипта добавь предзагрузку, чтобы не лагало
@onready var bullet_path = preload("res://models/bullet.tscn")

func _input(event):
	if event.is_action_pressed("Attack"):
		var bullet = bullet_path.instantiate()
		sound.play()
		
		# owner — это корень всей сцены (например, Level1)
		# Если owner не сработает, используй get_tree().current_scene.add_child(bullet)
		get_tree().current_scene.add_child(bullet)
		
		# Устанавливаем позицию ПОСЛЕ добавления на сцену
		bullet.global_position = global_position + $Camera2D.position
		
		# Поворачиваем на мышь
		bullet.look_at(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	if LOSE:
		velocity = velocity.lerp(Vector2.ZERO, 0.05)
		move_and_slide()
		return

	var is_jetting = Input.is_action_pressed("Shift")
	var sprite = $AnimatedSprite2D
	
	if is_jetting:
		# --- РЕЖИМ ПОЛЕТА (JET) ---
		sprite.scale = sprite.scale.lerp(Vector2.ONE * MIN_SCALE, SHRINK_SPEED * delta)
		
		# ПРОВЕРКА НА СМЕРТЬ ОТ МИНИМАЛЬНОГО РАЗМЕРА
		# Если масштаб стал почти равен минимальному (с небольшим запасом)
		if sprite.scale.x <= MIN_SCALE + 0.05:
			explode()
			return # Выходим из функции, чтобы не лететь дальше
			
		var mouse_pos = get_global_mouse_position()
		var dir = (mouse_pos - global_position - $Camera2D.position).normalized()
		
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
	pop.play()
	
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "scale", $AnimatedSprite2D.scale * 1.3, 0.1)
	tween.tween_property($AnimatedSprite2D, "modulate:a", 0.0, 0.3)
	get_tree().create_timer(4.0/5).timeout.connect(func(): get_tree().change_scene_to_file("res://Menu.tscn"))
