@tool
extends Water
class_name HealingWater

# A variant of Water that gradually restores the Player's HP while the player
# is inside it. All wave physics, splash, and enter/leave behavior are
# inherited from Water — this script only adds a tick-based heal side-effect.
#
# The first heal happens `heal_interval` seconds after the player enters,
# and continues every `heal_interval` seconds until the player either leaves
# the water or reaches full HP.

## Seconds between each heal tick.
@export var heal_interval: float = 1.5

## How much HP is restored on each tick.
@export var heal_amount: int = 1

var _heal_timer: Timer
var _current_healing_player: Player

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return

	_heal_timer = Timer.new()
	_heal_timer.wait_time = heal_interval
	_heal_timer.one_shot = false
	_heal_timer.timeout.connect(_on_heal_tick)
	add_child(_heal_timer)

func _on_body_entered(body: Node2D) -> void:
	super._on_body_entered(body)
	if body is Player and _heal_timer:
		_current_healing_player = body
		_heal_timer.wait_time = heal_interval
		_heal_timer.start()

func _on_body_exited(body: Node2D) -> void:
	super._on_body_exited(body)
	if body is Player and body == _current_healing_player:
		_current_healing_player = null
		if _heal_timer:
			_heal_timer.stop()

func _on_heal_tick() -> void:
	if _current_healing_player == null or not is_instance_valid(_current_healing_player):
		_heal_timer.stop()
		return
	_current_healing_player.heal(heal_amount)
