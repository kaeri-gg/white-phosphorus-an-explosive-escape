extends StaticBody2D

signal interacted(actor: Node2D)

const _SWITCH_GROUP := "switch_valve"

@export var prompt_offset: Vector2 = Vector2(-100, -120)
@export var source_water: Water
@export var target_water: Water
@export var transfer_duration: float = 3.0

@export_group("Aura Glow")
@export var aura_color: Color = Color(0.974, 1.0, 0.999, 1.0):
	set(value):
		aura_color = value
		_push_aura_param(&"aura_color", value)
@export var aura_radius: float = 100.0:
	set(value):
		aura_radius = value
		_push_aura_param(&"aura_radius", value)
@export_range(0.5, 5.0) var aura_spread: float = 1.8:
	set(value):
		aura_spread = value
		_push_aura_param(&"spread", value)
@export_range(0.0, 1.0) var aura_brightness: float = 0.55:
	set(value):
		aura_brightness = value
		_push_aura_param(&"brightness", value)
@export var aura_pulse_speed: float = 2.0:
	set(value):
		aura_pulse_speed = value
		_push_aura_param(&"pulse_speed", value)

@onready var interact_area: Area2D = %InteractArea
@onready var prompt_label: Label = %PromptLabel
@onready var switch_sprite: AnimatedSprite2D = %SwitchSprite

var has_transferred: bool = false
var is_transferring: bool = false

var current_player: Player

func _ready() -> void:
	add_to_group("interactable")
	add_to_group(_SWITCH_GROUP)
	interact_area.body_entered.connect(_on_interact_area_body_entered)
	interact_area.body_exited.connect(_on_interact_area_body_exited)
	prompt_label.top_level = true
	_set_prompt_visible(false)
	_init_aura_material()

# Give each switch its own material copy so per-instance aura tweaks don't
# leak across siblings, then push the inspector values onto the shader.
func _init_aura_material() -> void:
	if switch_sprite.material:
		switch_sprite.material = switch_sprite.material.duplicate()
	_push_aura_param(&"aura_color", aura_color)
	_push_aura_param(&"aura_radius", aura_radius)
	_push_aura_param(&"spread", aura_spread)
	_push_aura_param(&"brightness", aura_brightness)
	_push_aura_param(&"pulse_speed", aura_pulse_speed)

func _push_aura_param(param_name: StringName, value: Variant) -> void:
	if switch_sprite == null:
		return
	var mat := switch_sprite.material as ShaderMaterial
	if mat == null:
		return
	mat.set_shader_parameter(param_name, value)

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
	sound_manager.play("OpeningValve")

	_set_prompt_visible(false)
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

func _set_current_player(player: Player) -> void:
	if current_player == player:
		return

	_clear_current_player()
	current_player = player
	current_player.switch_pressed.connect(_on_player_pressed_switch)
	if not has_transferred and not is_transferring and not _any_switch_used():
		_set_prompt_visible(true)
		_update_prompt_position()

func _any_switch_used() -> bool:
	for node in get_tree().get_nodes_in_group(_SWITCH_GROUP):
		if node == self:
			continue
		if node.has_transferred or node.is_transferring:
			return true
	return false

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
