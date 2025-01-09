class_name SettlementArea
extends Area2D

var settlement_name: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_child_entered_tree(node: Node) -> void:
	if node.is_class("Polygon2D"):
		node.color = Color(0,0,0,0)

func _on_mouse_entered() -> void:
	print(settlement_name)
	for node in get_children():
		if node.is_class("Polygon2D"):
			node.color = Color(1,1,1,0.3)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		print(str(settlement_name) + " Clicked")
		for node in get_children():
			if node.is_class("Polygon2D"):
				node.color = Color(1,1,1,0.6)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		for node in get_children():
			if node.is_class("Polygon2D"):
				node.color = Color(1,1,1,0.3)

func _on_mouse_exited() -> void:
	for node in get_children():
		if node.is_class("Polygon2D"):
			node.color = Color(1,1,1,0)
