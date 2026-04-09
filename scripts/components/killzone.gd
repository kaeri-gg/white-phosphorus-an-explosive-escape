extends Area2D

@onready var restart_timer: Timer = $Timer
@export var restart_delay: float = 0.6

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	restart_timer.wait_time = restart_delay

func _on_body_entered(body: Node) -> void:
	if body is Player and body.has_method("die"):
		Engine.time_scale = 0.5
		body.get_node_or_null("CollisionShape2D").queue_free()

		body.die()
		restart_timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()

func _exit_tree() -> void:
	Engine.time_scale = 1.0
