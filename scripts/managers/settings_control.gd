class_name	Settings
extends Control

@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider
@onready var ui_scale_option: OptionButton = %UIScaleOptionButton

const UI_SCALES := [0.9, 1.0, 1.15, 1.25]

func _ready() -> void:
	bind_ui_settings()
	bind_sound_settings()
	
func bind_sound_settings() -> void:
	music_volume_slider.value_changed.connect(_set_bus_volume.bind("Music"))
	sfx_volume_slider.value_changed.connect(_set_bus_volume.bind("SFX"))
	
	music_volume_slider.drag_ended.connect(_on_slider_drag_ended)
	sfx_volume_slider.drag_ended.connect(_on_slider_drag_ended)

func bind_ui_settings() -> void:
	ui_scale_option.item_selected.connect(_on_ui_scale_selected)

func _on_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		sound_manager.play("Click")
	
func _set_bus_volume(volume: float, bus_name: String) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("Audio bus '%s' not found." % bus_name)
		return

	if volume <= 0.0:
		AudioServer.set_bus_volume_db(bus_index, -80.0) 
	else:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume / 100.0))
		
func _on_ui_scale_selected(index: int) -> void:
	var id := ui_scale_option.get_item_id(index)
	get_window().content_scale_factor = UI_SCALES[id]
