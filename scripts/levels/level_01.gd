extends Control

@onready var player: Player = $Player

func _ready() -> void:

	player.is_stable.connect(_on_player_stable)
	player.is_burning.connect(_on_player_burning)
	player.is_shaking.connect(_on_player_shaking)

func _on_player_stable() -> void: # Player.STABLE = he's in the water
	pass

func _on_player_burning() -> void: # Player.BURNING = is in the air for 3sec
	pass

func _on_player_shaking() -> void: # Player.SHAKING =  exposed to the air, 
	pass
