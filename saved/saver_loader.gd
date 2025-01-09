class_name SaverLoader
extends Node

@onready var world_root

func save_game():
	var saved_game:SavedGame = SavedGame.new()
	var saved_data:Array[SavedData] = []
	
	get_tree().call_group("world_saving", "on_save_game", saved_data)
	saved_game.saved_data = saved_data
	
	ResourceSaver.save(saved_game, "user://savegame.tres")

func load_game():
	var saved_game:SavedGame = load("user://savegame.tres") as SavedGame
	get_tree().call_group("world_saving", "on_before_save")
	
	for item: SavedData in saved_game.saved_data:
		var scene = load(item.scene) as PackedScene
		var restored_node = scene.instantiate()
		world_root.add_child(restored_node)
		if restored_node.has_method("on_load_game"):
			restored_node.on_load_game(item)
