class_name UiManager
extends Node

const MODAL_MANAGER_SCENE := preload("uid://ijw6ubii34sy")

var modal_manager: ModalManager
var tutorial_shown: bool = false

func initiate_modal_and() -> ModalManager:
	if modal_manager != null and is_instance_valid(modal_manager):
		return modal_manager

	var root: Node = get_tree().current_scene
	var existing: Node = root.get_node_or_null("ModalManagerLayer/ModalManagerRuntime")
	if existing and existing is ModalManager:
		modal_manager = existing
		return modal_manager

	var canvas_layer := CanvasLayer.new()
	canvas_layer.name = "ModalManagerLayer"
	canvas_layer.layer = 10
	root.add_child(canvas_layer)

	modal_manager = MODAL_MANAGER_SCENE.instantiate()
	modal_manager.name = "ModalManagerRuntime"
	canvas_layer.add_child(modal_manager)
	return modal_manager

func open_settings_modal() -> void:
	initiate_modal_and().show_settings()

func toggle_settings_modal() -> void:
	var manager := initiate_modal_and()

	if manager.is_open():
		manager.close_modal()
		return

	manager.show_settings()

func open_about_us_modal() -> void:
	initiate_modal_and().show_about_us()

func open_tutorial_modal() -> void:
	tutorial_shown = true
	initiate_modal_and().show_tutorial()

func toggle_tutorial_modal() -> void:
	var manager := initiate_modal_and()
	if manager.is_open():
		manager.close_modal()
		return
	open_tutorial_modal()

func open_tutorial_modal_once() -> void:
	if tutorial_shown:
		return
	open_tutorial_modal()
