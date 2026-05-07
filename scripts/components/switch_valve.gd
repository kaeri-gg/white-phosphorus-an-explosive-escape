extends StaticBody2D

signal interacted(actor: Node2D)
signal transfer_denied(reason: String)

@export var prompt_offset: Vector2 = Vector2(-100, -120)
@export var source_water: Water
@export var target_water: Water
@export var transfer_duration: float = 3.0
@export var requires_source_filled: bool = true

@onready var interact_area: Area2D = %InteractArea
@onready var prompt_label: Label = %PromptLabel
@onready var switch_sprite: AnimatedSprite2D = %SwitchSprite

var has_transferred: bool = false
var is_transferring: bool = false

var current_player: Player

func _ready() -> void:
	add_to_group("interactable")
	interact_area.body_entered.connect(_on_interact_area_body_entered)
	interact_area.body_exited.connect(_on_interact_area_body_exited)
	prompt_label.top_level = true
	_set_prompt_visible(false)

func _process(_delta: float) -> void:
	_update_prompt_position()

func _update_prompt_position() -> void:
	prompt_label.global_position = global_position + prompt_offset

func interact(actor: Node2D) -> void:
	interacted.emit(actor)

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is Player:
		_set_current_player(body)

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body == current_player:
		_clear_current_player()

func _on_player_pressed_switch() -> void:
	if current_player == null or is_transferring or has_transferred:
		return

	if target_water == null:
		push_warning("%s: target_water is not set." % name)
		return

	if not _can_start_transfer():
		transfer_denied.emit("source_not_full")
		return

	switch_sprite.play("interact")
	interact(current_player)
	_start_water_transfer()

func _start_water_transfer() -> void:
	is_transferring = true

	if source_water:
		source_water.animate_fill(source_water.min_height, transfer_duration)
	target_water.animate_fill(target_water.max_height, transfer_duration)

	await get_tree().create_timer(transfer_duration).timeout

	has_transferred = true
	is_transferring = false


func _can_start_transfer() -> bool:
	if source_water == null or not requires_source_filled:
		return true
	return source_water.is_full()

func _set_current_player(player: Player) -> void:
	if current_player == player:
		return

	_clear_current_player()
	current_player = player
	current_player.switch_pressed.connect(_on_player_pressed_switch)
	_set_prompt_visible(true)
	_update_prompt_position()

func _clear_current_player() -> void:
	if current_player == null:
		return

	if is_instance_valid(current_player) and current_player.switch_pressed.is_connected(_on_player_pressed_switch):
		current_player.switch_pressed.disconnect(_on_player_pressed_switch)

	current_player = null
	_set_prompt_visible(false)

func _set_prompt_visible(is_prompt_visible: bool) -> void:
	prompt_label.visible = is_prompt_visible
	set_process(is_prompt_visible)

func _exit_tree() -> void:
	_clear_current_player()
