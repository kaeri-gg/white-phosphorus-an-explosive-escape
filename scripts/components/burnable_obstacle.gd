class_name BurnableObstacle
extends Area2D

enum BURN_STATE { NORMAL, BURNING, ASH }

@export var is_fire: bool = false

var burn_state: BURN_STATE = BURN_STATE.NORMAL

func _ready() -> void:
	if "fire" in name.to_lower():
		is_fire = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(player: Node) -> void:
	if player is Player:
		if is_fire:
			_handle_fire_obstacle(player)
		else:
			_handle_burnable_obstacle(player)

func _handle_fire_obstacle(player: Player) -> void:
	if player.current_state == Player.STATE.BURNING:
		_spread_fire()
	else:
		player.die()

func _handle_burnable_obstacle(player: Player) -> void:
	if player.current_state == Player.STATE.BURNING:
		_burn_to_ash()
	else:
		player.die()

func _spread_fire() -> void:
	if burn_state != BURN_STATE.NORMAL:
		return

	burn_state = BURN_STATE.BURNING
	modulate = Color(1.4, 1.2, 0.8, 1.0)

	await utils.timeout(0.3)
	modulate = Color(1.6, 1.0, 0.6, 1.0)

	await utils.timeout(0.3)
	modulate = Color(1.8, 0.8, 0.4, 1.0)

	await utils.timeout(0.3)
	modulate = Color(2.0, 0.5, 0.2, 1.0)

	await utils.timeout(0.3)
	modulate = Color(1, 1, 1, 1.0)

func _burn_to_ash() -> void:
	if burn_state != BURN_STATE.NORMAL:
		return

	burn_state = BURN_STATE.BURNING

	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
		tween.tween_property(sprite, "scale", sprite.scale * 1.3, 0.5)
		await tween.finished

	burn_state = BURN_STATE.ASH
	queue_free()
