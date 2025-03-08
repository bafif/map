class_name Map
extends Node2D

@onready var Settlements_Sprite = $Settlements_Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settlements()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func load_settlements() -> void:
	print("Loading the settlements...\n")
	var current: int = 0
	var saved_map:SavedMap = load("user://saved_map.tres")
	var settlement_scene = load("res://scenes/settlement_area.tscn")
	var total := str(saved_map.saved_settlements.size())
	
	print("Files loaded.\n")	
	for saved_settle in saved_map.saved_settlements:
		if not current%100:
			print("loaded " + str(current) + " settlements from " + total)
		current = current + 1
		
		var settlement = settlement_scene.instantiate()
		settlement.settlement_name = saved_settle.name
		settlement.set_name(saved_settle.code)
		$Settlements.add_child(settlement)
		var polygons := saved_settle.polygons
		for polygon in polygons:
			var settlement_collision := CollisionPolygon2D.new()
			var settlement_polygon := Polygon2D.new()
			settlement.add_child(settlement_collision)
			settlement.add_child(settlement_polygon)
			settlement_collision.polygon = polygon
			settlement_polygon.polygon = polygon
		
	print("Settlements loaded.")
