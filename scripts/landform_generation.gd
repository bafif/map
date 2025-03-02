class_name LandformGeneration
extends Node
## Generación de las mínimas unidades de tierra en el mapa
##
## El script tiene el rol de tomar una imagen en la cual se encuentre dibujado un mapa
## a pixel perfecto en el cual se halle relleno cada pixel asociado a un terreno con
## el color asociado a dicho terreno.

func _ready() -> void:
	pass

## Esta función toma una imagen y devuelve un paquete de polígonos asociado a cada color.
static func create_polygons(source: Image, names: Dictionary) -> void:
	
	## Tamaño de la imagen original
	var size = source.get_size()
	print("Creating BitMap\n")
	
	## Rectángulo que limita el destino de la operación
	var r: Rect2i = Rect2i(Vector2.ZERO, size)
	print("\n\tRect: " + str(r))
	var from: Vector2i
	
	## Bitmap que tacha los píxeles ya procesados
	var fill: BitMap
	fill.create(size)
	
	## A cada color, todos sus píxeles
	var pixel_dict: Dictionary = {}
	print("\n\tProcesando colores...")
	
	var current: int = 0
	var total := str(names.size())
	
	## Stack para iterar en fill bits
	var stack
	
	## Recorre toda la imagen en filas, de TL a BR
	for y in range(source.get_height()):
		for x in range(source.get_width()):
			
			## Color a procesar
			var color = "#" + str(source.get_pixel(int(x), int(y)).to_html(false))
			
			## Si el color no está procesado:
			## incluirlo como procesado
			if color not in pixel_dict:
				pixel_dict[color] = []
				
				if not current%100:
					print("procesados " + str(current) + " colores de " + total)
				current = current + 1
				
				var polygons: Array[PackedVector2Array]
				if !fill.get_bitv(Vector2i(x,y)):
					pass
			pixel_dict[color].append(Vector2(x,y))
