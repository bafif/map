extends Camera2D

const SPEED: float = 800
const ACCEL: float = 600
const FRICT: float = 300
const HOOKE: float = 1

var veloc: Vector2
var direc: Vector2
var hooke: Vector2
var rect


func _ready() -> void:
	position = Vector2(0, 0)
	veloc = Vector2.ZERO
	hooke = Vector2.ZERO
	rect = $"../Settlements_Sprite".get_rect()
	
	set_limit(SIDE_LEFT, 0)
	set_limit(SIDE_TOP, 0)
	set_limit(SIDE_RIGHT, $"../Settlements_Sprite".texture.get_width())
	set_limit(SIDE_BOTTOM, $"../Settlements_Sprite".texture.get_height())

func _process(delta: float) -> void:
	direc = Input.get_vector(	"map_movement_left",
								"map_movement_right",
								"map_movement_up",
								"map_movement_down").normalized()
	veloc = veloc.move_toward(direc*SPEED, ACCEL*delta)
	veloc = veloc.move_toward(Vector2.ZERO, FRICT*delta)
	hooke = hooke.move_toward(direc, delta)
	position += veloc*delta - hooke*HOOKE

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				set_zoom(get_zoom()+Vector2(0.2,0.2))
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				set_zoom(get_zoom()+Vector2(-0.2,-0.2))
