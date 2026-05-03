extends Node2D

var health = 100.0
var healthMax = 100.0

@onready var hr = $HealthRed
@onready var hg = $HealthGreen

func updHealth():
	if health < 0.0: return
	var percent: float = health / healthMax
	hg.scale.x = hr.scale.x * percent

func _ready() -> void:
	updHealth()

func takeDMG(target_node: Node2D, dmg : float) -> void:
	health -= dmg
	updHealth()
	if health <= 0.0:
		if target_node.is_in_group("Player"):
			target_node.explode()
		elif target_node.is_in_group("Enemy"):
			ClassGame.add_kill()
			target_node.queue_free()
