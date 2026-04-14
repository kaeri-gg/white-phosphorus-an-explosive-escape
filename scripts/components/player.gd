class_name Player
extends CharacterBody2D

@onready var player_sprite: PlayerExpressions = %PlayerExpressionController
@onready var die_timer: Timer = %DieTimer
@onready var burn_timer: Timer = %BurnTimer

@export var SPEED : float = 400.0
@export var JUMP_VELOCITY : float = -500.0
@export var EASY_SURVIVAL_TIME : float = 5.0
@export var HARD_AIR_SURVIVAL_TIME : float = 7.0
@export var PLAYER_HEALTH : int = 7 

var current_health : int

signal stabilized
signal burned
signal shook

signal died # emitted after death animation finishes
signal die_timer_value(time_left: float)
signal switch_pressed

# signals for animation
signal state_change(new_state: int)
signal movement_change(is_moving: bool)

signal health_changed(current: int, max_hp: int)

enum STATE { STABLE, BURNING, SHAKING, DEAD, EVOLVED }
enum ENV { AIR, WATER }

const max_jump: int = 2

var jump_count: int
var current_state: STATE = STATE.STABLE
var env_state: ENV = ENV.AIR
var was_moving: bool = false
var is_dying: bool = false

func _ready() -> void:
	current_health = PLAYER_HEALTH
	health_changed.emit(current_health, PLAYER_HEALTH)
	
	add_to_group("can_interact_with_water")
	
	die_timer.timeout.connect(player_will_die)
	burn_timer.timeout.connect(player_will_burn)
	state_change.connect(player_sprite.on_player_state_change)
	movement_change.connect(player_sprite.on_player_movement_change)
	
	detect_environment()
	update_visual_state()
	
	state_change.emit(current_state)
	movement_change.emit(was_moving)

func change_state(new_state: STATE) -> void:
	if current_state == new_state:
		return
		
	current_state = new_state
	state_change.emit(current_state)
	
	if new_state != STATE.DEAD:
		update_visual_state()
	
	# Emit corresponding signal
	match new_state:
		STATE.STABLE: 
			stabilized.emit()
		STATE.BURNING: 
			burned.emit()
		STATE.SHAKING: 
			shook.emit()

func _physics_process(delta: float) -> void:
	survival_timer_label_updater()

	if current_state == STATE.DEAD:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor():
		jump_count = 0
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and jump_count < max_jump:
		jump_count += 1
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
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
		if not die_timer.is_stopped():
			die_timer.stop()
		if not burn_timer.is_stopped():
			burn_timer.stop()

		change_state(STATE.STABLE)
		return

	change_state(STATE.SHAKING)
	
	if burn_timer.is_stopped():
		burn_timer.start()
	if die_timer.is_stopped():
		die_timer.start()

func enter_water() -> void:
	update_environment(ENV.WATER)
	heal()
	detect_environment()

func leave_water() -> void:
	update_environment(ENV.AIR)
	detect_environment()

func update_environment(location: ENV) -> void:
	env_state = location

func player_will_die() -> void:
	if env_state != ENV.AIR:
		return
	
	if current_state == STATE.BURNING:
		take_damage(1)
	
func player_will_burn() -> void:
	print("burn")

	if not burn_timer.is_stopped():
		burn_timer.stop()

	change_state(STATE.BURNING)	
	take_damage(1)
	
func heal() -> void:
	if current_state == STATE.DEAD:
		return
	# when player enters water, he's going to recover
	if env_state == ENV.WATER:
		current_health = PLAYER_HEALTH
		health_changed.emit(current_health, PLAYER_HEALTH)
	
func die() -> void:
	if is_dying or current_state == STATE.DEAD:
		return
	
	is_dying = true
	
	if not die_timer.is_stopped():
		die_timer.stop()
	if not burn_timer.is_stopped():
		burn_timer.stop()	
	
	current_state = STATE.DEAD
	state_change.emit(current_state)
	
	await play_death_animation()
	died.emit()
	
func play_death_animation() -> void:
	player_sprite.play("start_burning")
	await utils.timeout(0.7)
	player_sprite.play("dead")
	
	
func take_damage(amount: int) -> void:
	if current_state == STATE.DEAD:
		return

	current_health -= amount
	health_changed.emit(current_health, PLAYER_HEALTH) # Add this
	
	if current_health <= 0:
		die()
	
	
func update_visual_state() -> void:
	var state_at_call := current_state
	match current_state:
		STATE.STABLE:
			player_sprite.play("stable")
		STATE.BURNING:
			player_sprite.play("start_burning")
			await utils.timeout(0.5)
			if current_state != state_at_call:
				return
				
			player_sprite.play("repeat_burning")
		STATE.SHAKING:
			player_sprite.play("shaking")
		STATE.EVOLVED:
			player_sprite.play("evolved")

func remaining_survival_timer_value() -> float:
	if env_state == ENV.AIR and not die_timer.is_stopped():
		return die_timer.time_left

	return EASY_SURVIVAL_TIME

func survival_timer_label_updater() -> void:
	if env_state == ENV.AIR and not die_timer.is_stopped():
		die_timer_value.emit(remaining_survival_timer_value())
	
func flip_char_on_move() -> void:
	if velocity.x > 0:
		player_sprite.flip_h = false
	if velocity.x < 0:	
		player_sprite.flip_h = true
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("press_e_to_interact") and not event.is_echo():
		switch_pressed.emit()
