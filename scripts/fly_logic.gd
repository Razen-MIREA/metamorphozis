extends CharacterBody2D

var player = null
const GRAVITY = 1800.0

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	if player:
		var dir = (player.global_position - global_position).normalized()
		# Плавное преследование без гравитации
		velocity = velocity.lerp(dir * 250.0, 0.05)
		
		$AnimatedSprite2D.flip_h = dir.x < 0
		$AnimatedSprite2D.play("Idle")
		move_and_slide()
