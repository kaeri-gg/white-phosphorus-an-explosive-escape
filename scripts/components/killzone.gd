extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if body is CharacterBody2D and body.has_method("die"):
		body.die()
