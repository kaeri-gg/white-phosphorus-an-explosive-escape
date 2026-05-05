class_name BurnableObstacle
extends Area2D

enum TYPE { FIRE, FIREWORK, WOOD }

const KILL_DELAY: float = 0.5
const WOOD_BURN_DURATION: float = 1.0

@export var type: TYPE

var _kill_timer: Timer
var _pending_victim: Player = null
var _was_firework: bool = false
var _wood_ignited: bool = false

func _ready() -> void:
	_kill_timer = Timer.new()
	_kill_timer.one_shot = true
	_kill_timer.wait_time = KILL_DELAY
	_kill_timer.timeout.connect(_on_kill_timer_timeout)
	add_child(_kill_timer)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if type == TYPE.FIRE:
		var sprite := get_node_or_null("%PipeFireSprite") as AnimatedSprite2D
		if sprite:
			sprite.play("big_fire")

func _on_body_entered(body: Node) -> void:
	if body is not Player:
		return
	var player := body as Player
	match type:
		TYPE.FIRE:
			_handle_fire(player)
		TYPE.FIREWORK:
			_handle_firework(player)
		TYPE.WOOD:
			_handle_wood(player)

func _on_body_exited(body: Node) -> void:
	if body is not Player:
		return
	if _was_firework and _pending_victim == body:
		_kill_timer.stop()
		_pending_victim = null

func _handle_fire(player: Player) -> void:
	if _was_firework:
		_start_kill_countdown(player)
		return
	_play_explode_if_present()
	player.die()

func _handle_firework(player: Player) -> void:
	_play_explode_if_present()
	player.die()

func _play_explode_if_present() -> void:
	var sprite := get_node_or_null("Sprite2D") as AnimatedSprite2D
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("explode"):
		sprite.play("explode")

func _handle_wood(player: Player) -> void:
	print("touched wood, but its not working")
	# TODO: Work on this bug
	
	if _wood_ignited:
		return
	if player.current_state != Player.STATE.BURNING:
		return
	_ignite_wood()

func _start_kill_countdown(player: Player) -> void:
	print("should start countdown")
	_pending_victim = player
	_kill_timer.start()

func _on_kill_timer_timeout() -> void:
	if _pending_victim and is_instance_valid(_pending_victim):
		print("player should die")
		_pending_victim.die()
	_pending_victim = null

func _ignite_wood() -> void:
	_wood_ignited = true
	print("wood burned")
	var sprite := get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color(0.3, 0.3, 0.3, 1.0)
	var solid := get_node_or_null("StaticBody2D")
	if solid:
		solid.queue_free()
	await utils.timeout(WOOD_BURN_DURATION)
	queue_free()
