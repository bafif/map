class_name Map
extends Node2D

@onready var Settlements_Sprite = $Settlements_Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_settlements()

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
			print("loaded " + str(current) + "settlements from" + total)
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

func create_settlements() -> void:
	var save: SavedMap = SavedMap.new()
	var save_settles: Array[SavedSettlement] = []
	
	print("Creating the settlements!!!\n")
	var image: Image = Settlements_Sprite.get_texture().get_image()
	var pixel_color_dict: Dictionary = get_pixel_color_dict(image)
	var settlements_dict: Dictionary = import_json("res://map/definition.json")
	
	print("Files loaded.\n")
	var current: int = 0
	var total := str(settlements_dict.size())
	var settlement_scene = load("res://scenes/settlement_area.tscn")
	for settlement_code in settlements_dict:
		
		var save_settle: SavedSettlement = SavedSettlement.new()
		save_settle.scene = "res://scenes/settlement_area.tscn"
		save_settle.code = settlement_code
		save_settle.name = settlements_dict[settlement_code]
		
		if not current%100:
			print("generated " + str(current) + " settlements from " + total)
		current = current + 1
		
		var settlement = settlement_scene.instantiate()
		settlement.settlement_name = save_settle.name
		settlement.set_name(settlement_code)
		$Settlements.add_child(settlement)
		var polygons := get_polygons(image.get_size(), settlement_code, pixel_color_dict)
		save_settle.polygons = polygons
		save_settles.append(save_settle)
		for polygon in polygons:
			var settlement_collision := CollisionPolygon2D.new()
			var settlement_polygon := Polygon2D.new()
			settlement.add_child(settlement_collision)
			settlement.add_child(settlement_polygon)
			settlement_collision.polygon = polygon
			settlement_polygon.polygon = polygon
		save.saved_settlements = save_settles
		ResourceSaver.save(save, "user://saved_map.tres")
	print("Settlements generated.")
	

func get_pixel_color_dict(image: Image) -> Dictionary:
	var pixel_color_dict: Dictionary = {}
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel_color = "#" + str(image.get_pixel(int(x), int(y)).to_html(false))
			if pixel_color not in pixel_color_dict:
				pixel_color_dict[pixel_color] = []
			pixel_color_dict[pixel_color].append(Vector2(x,y))
	return pixel_color_dict

func get_polygons(size: Vector2i, color: String, dict: Dictionary) -> Array[PackedVector2Array]:
	var target := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	for pixel in dict[color]:
		target.set_pixel(pixel.x, pixel.y, "#ffffff")
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(target)
	var polygons := bitmap.opaque_to_polygons(Rect2(Vector2(0,0), bitmap.get_size()), 0.1)
	return polygons

# Import JSON files and converts to lists or dictionary
func import_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file != null:
		return JSON.parse_string(file.get_as_text().replace("_", " "))
	else:
		print("Failed to open file:", path)
		return {}

func export_json(path: String, dict: Dictionary) -> void:
	print("Saving data to JSON file")
	var file := FileAccess.open(path, FileAccess.WRITE)
	var json = JSON.stringify(dict, "\t")
	file.store_string(json)
