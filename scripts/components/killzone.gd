class_name Killzone
extends Area2D

const DEBUG := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(player: Node) -> void:
	if DEBUG: print("obstacle touched")
	if player is Player:
		player.die()
