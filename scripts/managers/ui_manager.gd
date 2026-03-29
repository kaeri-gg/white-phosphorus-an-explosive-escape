class_name UiManager
extends Node

const MODAL_MANAGER_SCENE := preload("uid://ijw6ubii34sy")

var modal_manager: ModalManager

func initiate_modal_and() -> ModalManager:
	if modal_manager != null and is_instance_valid(modal_manager):
		return modal_manager

	var root: Node = get_tree().current_scene
	var existing: Node = root.get_node_or_null("ModalManagerRuntime")
	if existing and existing is ModalManager:
		modal_manager = existing
		return modal_manager

	modal_manager = MODAL_MANAGER_SCENE.instantiate()
	modal_manager.name = "ModalManagerRuntime"
	root.add_child(modal_manager)
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
