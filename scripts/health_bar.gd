extends CanvasLayer

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

func _process(delta: float) -> void:
	updHealth()
	#health -= 10.0 * delta
