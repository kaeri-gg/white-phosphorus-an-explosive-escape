class_name Player
extends CharacterBody2D

@onready var player_sprite: PlayerExpressions = %PlayerExpressionController
@onready var air_timer: Timer = %AirTimer

@export var SPEED = 400.0
@export var JUMP_VELOCITY = -900.0
@export var AIR_SURVIVAL_TIME = 3.0

signal is_stable
signal is_burning
signal is_shaking

signal is_dead
signal is_evolved
signal air_timer_value(time_left: int)

# signals for animation
signal state_change(new_state: int)
signal movement_change(is_moving: bool)

enum STATE { STABLE, BURNING, SHAKING, DEAD, EVOLVED }
enum ENV { AIR, WATER }

var current_state: STATE = STATE.STABLE
var env_state: ENV = ENV.WATER
var was_moving: bool = false

func _ready() -> void:
	add_to_group("can_interact_with_water")
	air_timer.timeout.connect(_on_air_timer_timeout)
	state_change.connect(player_sprite.on_player_state_change)
	movement_change.connect(player_sprite.on_player_movement_change)
	update_visual_state()
	emit_timer_value()
	state_change.emit(current_state)
	movement_change.emit(was_moving)

func change_state(new_state: STATE) -> void:
	if current_state == new_state:
		return
		
	current_state = new_state
	update_visual_state()
	state_change.emit(current_state)
	
	# Emit corresponding signal
	match new_state:
		STATE.STABLE: 
			is_stable.emit()
		STATE.BURNING: 
			is_burning.emit()
		STATE.SHAKING: 
			is_shaking.emit()
		STATE.DEAD: 
			is_dead.emit()
		STATE.EVOLVED: 
			is_evolved.emit()

func _physics_process(delta: float) -> void:
	emit_timer_value()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if current_state == STATE.DEAD:
		move_and_slide()
		flip_char_on_move()
		return

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	var is_moving_now: bool = abs(velocity.x) > 0.1
	if is_moving_now != was_moving:
		was_moving = is_moving_now
		movement_change.emit(was_moving)

	move_and_slide()
	flip_char_on_move()

func detect_environment() -> void:
	if env_state == ENV.WATER:
		if not air_timer.is_stopped():
			air_timer.stop()

		change_state(STATE.STABLE)
		return

	check_hp()
	change_state(STATE.SHAKING)
	if air_timer.is_stopped():
		air_timer.start()

func enter_water() -> void:
	check_hp()
	update_environment(ENV.WATER)
	detect_environment()

func leave_water() -> void:
	check_hp()
	update_environment(ENV.AIR)
	detect_environment()

func update_environment(location: ENV) -> void:
	env_state = location
	
func check_hp() -> void:
	if current_state == STATE.DEAD:
		return
	# TODO: Add health
	
func burn() -> void:
	check_hp()

	if not air_timer.is_stopped():
		air_timer.stop()

	change_state(STATE.BURNING)
	
func die() -> void:
	if not air_timer.is_stopped():
		air_timer.stop()

	change_state(STATE.DEAD)

func _on_air_timer_timeout() -> void:
	if env_state != ENV.AIR:
		return

	burn()

func update_visual_state() -> void:
	match current_state:
		STATE.STABLE:
			player_sprite.play("stable")
		STATE.BURNING:
			player_sprite.play("start_burning")
			await utils.timeout(0.5)
			player_sprite.play("repeat_burning")
		STATE.SHAKING:
			player_sprite.play("shaking")
		STATE.DEAD:
			player_sprite.play("dead")
		STATE.EVOLVED:
			player_sprite.play("evolved")

func get_timer_display_value() -> float:
	if env_state == ENV.AIR and not air_timer.is_stopped():
		return air_timer.time_left

	return AIR_SURVIVAL_TIME

func emit_timer_value() -> void:
	air_timer_value.emit(get_timer_display_value())
	
func flip_char_on_move() -> void:
	if velocity.x > 0:
		player_sprite.flip_h = false
	if velocity.x < 0:	
		player_sprite.flip_h = true
		
