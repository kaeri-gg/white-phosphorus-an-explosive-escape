extends Control

@onready var player: Player = $Player
@onready var timer_label: Label = $Timer/TimerLabel

func _ready() -> void:

	player.is_stable.connect(_on_player_stable)
	player.is_burning.connect(_on_player_burning)
	player.is_shaking.connect(_on_player_shaking)
	player.air_timer_value.connect(_on_timer_updated)
	_on_timer_updated(player.get_timer_display_value())

func _on_player_stable() -> void: # Player.STABLE = he's in the water
	pass

func _on_player_burning() -> void: # Player.BURNING = is in the air for 3sec
	pass

func _on_player_shaking() -> void: # Player.SHAKING =  exposed to the air, 
	pass

func _on_timer_updated(time_left: float) -> void:
	timer_label.text = "%.1f" % time_left
