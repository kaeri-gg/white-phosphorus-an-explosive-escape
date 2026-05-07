class_name BurnableObstacle
extends Area2D

enum TYPE { FIRE, FIREWORK }

@export var type: TYPE

var _detonated: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	if type == TYPE.FIRE:
		var sprite := get_node_or_null("%PipeFireSprite") as AnimatedSprite2D
		if sprite:
			sprite.play("big_fire")

func _physics_process(_delta: float) -> void:
	if type != TYPE.FIREWORK or _detonated:
		return
	for body in get_overlapping_bodies():
		if body is Player and (body as Player).current_state == Player.STATE.BURNING:
			_detonate(body as Player)
			return

func _on_body_entered(body: Node) -> void:
	if body is not Player:
		return
	var player := body as Player
	match type:
		TYPE.FIRE:
			_handle_fire(player)
		TYPE.FIREWORK:
			if player.current_state == Player.STATE.BURNING:
				_detonate(player)

func _handle_fire(player: Player) -> void:
	_play_explode_if_present()
	player.die()

func _detonate(player: Player) -> void:
	if _detonated:
		return
	_detonated = true
	_play_explode_if_present()
	player.die()

func _play_explode_if_present() -> void:
	var sprite := get_node_or_null("Sprite2D") as AnimatedSprite2D
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("explode"):
		sprite.play("explode")
