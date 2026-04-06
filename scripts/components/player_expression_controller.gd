class_name PlayerExpressions
extends AnimatedSprite2D

@onready var blink_timer: Timer = %BlinkTimer
@onready var eyebrow_timer: Timer = %EyebrowTimer

@export var BLINK_MIN_INTERVAL: float = 2.0
@export var BLINK_MAX_INTERVAL: float = 4.0

@export var EYEBROW_MIN_INTERVAL: float = 4.0
@export var EYEBROW_MAX_INTERVAL: float = 8.0
@export var SHAKE_TWEEN_OFFSET: float = 10.0
@export var SHAKE_TWEEN_STEP_DURATION: float = 0.05
@export var SHAKE_TWEEN_ROTATION_DEGREES: float = 4

var current_state: int = Player.STATE.STABLE
var is_playing_expression: bool = false
var base_position: Vector2
var base_rotation_degrees: float
var shake_tween: Tween

func _ready() -> void:
	base_position = position
	base_rotation_degrees = rotation_degrees
	blink_timer.timeout.connect(_on_blink_timer_timeout)
	eyebrow_timer.timeout.connect(_on_eyebrow_timer_timeout)
	animation_finished.connect(_on_animation_finished)

	_schedule_next_blink()
	_schedule_next_eyebrow()
	
func on_player_state_change(new_state: int) -> void:
	current_state = new_state
	if current_state != Player.STATE.STABLE:
		is_playing_expression = false

	if current_state == Player.STATE.SHAKING:
		_start_shake_tween()
		return
		
	if current_state == Player.STATE.BURNING:
		_start_shake_tween()
		return	

	_stop_shake_tween()
	if current_state != Player.STATE.STABLE:
		return

	play("stable")

func on_player_movement_change(_moving: bool) -> void:
	pass

func _schedule_next_blink() -> void:
	blink_timer.wait_time = randf_range(BLINK_MIN_INTERVAL, BLINK_MAX_INTERVAL)
	blink_timer.start()
	
func _schedule_next_eyebrow() -> void:
	eyebrow_timer.wait_time = randf_range(EYEBROW_MIN_INTERVAL, EYEBROW_MAX_INTERVAL)
	eyebrow_timer.start()	

func _on_blink_timer_timeout() -> void:
	_schedule_next_blink()
	if not _can_play_expression():
		return

	is_playing_expression = true
	play("stable_blink")

func _on_eyebrow_timer_timeout() -> void:
	_schedule_next_eyebrow()
	if not _can_play_expression():
		return

	is_playing_expression = true
	play("stable_eyebrow")

func _can_play_expression() -> bool:
	return current_state == Player.STATE.STABLE and not is_playing_expression

func _on_animation_finished() -> void:
	if animation != "stable_blink" and animation != "stable_eyebrow":
		return

	is_playing_expression = false
	if current_state == Player.STATE.STABLE:
		play("stable")

func _start_shake_tween() -> void:
	if shake_tween:
		return

	shake_tween = create_tween().set_loops()
	shake_tween.tween_property(self, "position:x", SHAKE_TWEEN_OFFSET, SHAKE_TWEEN_STEP_DURATION).as_relative()
	shake_tween.parallel().tween_property(self, "rotation_degrees", SHAKE_TWEEN_ROTATION_DEGREES, SHAKE_TWEEN_STEP_DURATION).as_relative()
	shake_tween.tween_property(self, "position:x", -SHAKE_TWEEN_OFFSET * 2.0, SHAKE_TWEEN_STEP_DURATION * 2.0).as_relative()
	shake_tween.parallel().tween_property(self, "rotation_degrees", -SHAKE_TWEEN_ROTATION_DEGREES * 2.0, SHAKE_TWEEN_STEP_DURATION * 2.0).as_relative()
	shake_tween.tween_property(self, "position:x", SHAKE_TWEEN_OFFSET, SHAKE_TWEEN_STEP_DURATION).as_relative()
	shake_tween.parallel().tween_property(self, "rotation_degrees", SHAKE_TWEEN_ROTATION_DEGREES, SHAKE_TWEEN_STEP_DURATION).as_relative()

func _stop_shake_tween() -> void:
	if shake_tween:
		shake_tween.kill()
		shake_tween = null

	position = base_position
	rotation_degrees = base_rotation_degrees
