extends CharacterBody2D

var player = null
const GRAVITY = 1800.0

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	if player:
		var dir_x = sign(player.global_position.x - global_position.x)
		velocity.x = dir_x * 200.0
		
		$AnimatedSprite2D.flip_h = dir_x > 0
		$AnimatedSprite2D.play("Idle")
	move_and_slide()
