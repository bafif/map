class_name LandformGeneration
extends Node

@onready var MapSprite = preload("res://.godot/imported/provinces.bmp-45055aa7cb180bd66e0eec38773d6005.ctex")

## Generación de las mínimas unidades de tierra en el mapa
##
## El script tiene el rol de tomar una imagen en la cual se encuentre dibujado un mapa
## a pixel perfecto en el cual se halle relleno cada pixel asociado a un terreno con
## el color asociado a dicho terreno.
func _ready() -> void:
	var names: Dictionary = import_json("res://map/definition.json")
	var save: SavedMap = SavedMap.new()
	save.saved_landforms = create_polygons(MapSprite.get_image())
	print("Polygons created :D")
	for i in range(names.size()):
		for landform in save.saved_landforms:
			if landform.code == name:
				landform.name = name

#region Esta función toma una imagen y devuelve un paquete de polígonos asociado a cada color.
## Toma una imagen y devuelve una lista de landforms con código de color y polígono
static func create_polygons(source: Image) -> Array[SavedLandform]:
	#region Describiendo el input y el output
	## Esta lista de SavedLandform es el output.
	var output_map: Array[SavedLandform] = []
	
	## Tamaño de la imagen original
	var size: Vector2i = source.get_size()
	print("Creating BitMap\n")
	
	## Rectángulo que limita el destino de la operación
	var r: Rect2i = Rect2i(Vector2.ZERO, size)
	print("\n\tRect: " + str(r))
	#endregion
	
	#region Variables comunes
	## Bitmap que tacha los píxeles ya procesados
	var fill: BitMap = BitMap.new()
	fill.create(size)
	
	## A cada color, todos sus píxeles
	var color_list: Array[String] = []
	print("\n\tProcesando colores...")
	
	## Cantidad de colores ya procesados
	var current: int = 0
	#endregion
	
	## Recorre toda la imagen en filas, de TL a BR
	for y2 in range(source.get_height()):
		for x2 in range(source.get_width()):
			
			## Color a procesar
			var color = "#" + str(source.get_pixel(int(x2), int(y2)).to_html(false))
			
			## Si el color no está procesado:
			## incluirlo como procesado
			if color not in color_list:
				color_list.append(color)
				var output_land: SavedLandform = SavedLandform.new()
				output_land.code = color
				
				if not current%100:
					print("procesados " + str(current) + " colores")
				current = current + 1
				
				## Lista de polígonos pertenecientes al color
				var polygons: Array[PackedVector2Array]
				
				## Vector para saltear partes del for anidado
				for y in range(y2, source.get_height()):
					for x in range(x2, source.get_width()):
						
						#region FillBits
						
						#region Variables del fill bits
						## Stack para iterar en fill bits
						var stack: Array[FillBitsStackEntry] = []
						var stsize: int = 0
						
						## Variables para el while por color
						var cur: Vector2i = Vector2i(x,y)
						var nexi: int
						var nexj: int
						var reenter: bool = true
						var popped: bool = false
						#endregion
						
						## Algoritmo de Fill Bits
						while(reenter||popped):
							if(reenter):
								nexi = cur.x - 1
								nexj = cur.y - 1
								reenter = false
							#region Loop de Fill Bits
							for i in range(nexi, cur.x + 1):
								for j in range(nexj, cur.y + 1):
									if(popped):
										nexj = cur.y
										popped = false
										continue
									if(i < r.position.x || i >= r.position.x + r.size.x
									|| j < r.position.y || j >= r.position.y + r.size.y):
										continue
									if(fill.get_bit(i,j)): continue
									else:
										## Color del píxel siendo procesado (fillbits)
										var curcolor = "#" + str(source.get_pixel(int(i), int(j)).to_html(false))
										## Píxel del color correcto encontrado sin procesar
										if(curcolor == color):
											fill.set_bit(i,j, true)
											var se: FillBitsStackEntry = FillBitsStackEntry.new()
											se.curv = cur
											se.i = i
											se.j = j
											stack.resize(max(stsize + 1, stack.size()))
											stack.set(stack.size(), se)
											stsize = stsize + 1
											cur = Vector2i(i, j)
											reenter = true
											break
									if(reenter):
										break
								if(!reenter):
									if(stsize):
										var se: FillBitsStackEntry = stack.get(stsize - 1)
										stsize = stsize - 1
										cur = se.curv
										nexi = se.i
										nexj = se.j
										popped = true
							#endregion


						
						#region MarchingSquare
						
						#region Variables para el marching square
						##Posición inicial (X)
						var startx: int = x
						##Posición inicial (Y)
						var starty: int = y
						
						##Para dónde se mueve (X)
						var stepx: int = 0
						##Para dónde se mueve (Y)
						var stepy: int = 0
						
						##Último movimiento (X)
						var prevx: int = 0
						##Último movimiento (Y)
						var prevy: int = 0
						
						##Posición siendo analizada (X)
						var curx: int = startx
						##Posición siendo analizada (Y)
						var cury: int = starty
						
						##Conteo de iteraciones para manejo de error
						var count: int = 0
						
						##Vértices del poligono
						var points: PackedVector2Array
						##Cantidad de vértices del polígono
						var posize: int = 0
						
						## Diccionario que guarda los cruces ya procesados
						var cross_map: Dictionary = {}
						#endregion
						
						polygons.resize(1)
						
						## Algoritmo de marching squares
						while true:
							#La gracia sería recorrer todo el borde, arrancando por la esquina
							#superior izquierda y yendo para abajo , priorizando siempre moverse hacia
							#abajo y hacia la izquierda. En el momento en el que se deba circundar el
							#contorno, no habrá más posibles giros hacia la izquierda ni movimientos
							#hacia abajo así que se va a terminar volviendo a la posición inicial.
							#
							#Al llegar a un cruce (casos 6 y 9), esto sería una especia de isla
							#que tiene contacto con el polígono en un solo punto, así que se anota el 
							#punto al que se llegó y se pasa a moverse por la isla hasta llegar al mismo
							#cruce. Entonces, así se iteran todas las islas salientes hasta llegar a la
							#primera y retomar el polígono original.
							#checking the 2x2 pixel grid, assigning these values to each pixel, if not transparent
							#
							#+---+---+
							#| 1 | 2 |
							#+---+---+
							#| 4 | 8 | <- current pixel (curx,cury)
							#+---+---+
							
							#region calculando SquareValue
							## Square Value (determina los píxeles desde curx - (1,1) hasta curx)
							var sv: int = 0
							## Top-Left (1)
							var tl: Vector2i = Vector2i(curx - 1, cury - 1)
							sv = sv + 1 if (r.has_point(tl) && color == source.get_pixel(tl.x, tl.y)) else 0
							## Top-Right (2)
							var top_right: Vector2i = Vector2i(curx, cury - 1)
							sv = sv + 2 if (r.has_point(top_right) && color == source.get_pixel(top_right.x, top_right.y)) else 0
							## Bottom-Left (4)
							var bl: Vector2i = Vector2i(curx - 1, cury)
							sv = sv + 4 if (r.has_point(bl) && color == source.get_pixel(bl.x, bl.y)) else 0
							## Bottom-Right (8)
							var br: Vector2i = Vector2i(curx, cury)
							sv = sv + 8 if (r.has_point(br) && color == source.get_pixel(br.x, br.y)) else 0
							if (sv == 0 || sv == 15):
								push_error("Invalid square value")
								return []
							#endregion
							
							#region calculando step
							##Procesa para dónde ir según los valores de alrededor
							match (sv):
								1, 5, 13:
									#/* going UP with these cases:
									#1          5           13
									#+---+---+  +---+---+  +---+---+
									#| 1 |   |  | 1 |   |  | 1 |   |
									#+---+---+  +---+---+  +---+---+
									#|   |   |  | 4 |   |  | 4 | 8 |
									#+---+---+  +---+---+  +---+---+
									#*/
									stepx = 0
									stepy = -1
									break

								8, 10, 11:
									#/* going DOWN with these cases:
									#8          10         11
									#+---+---+  +---+---+  +---+---+
									#|   |   |  |   | 2 |  | 1 | 2 |
									#+---+---+  +---+---+  +---+---+
									#|   | 8 |  |   | 8 |  |   | 8 |
									#+---+---+  +---+---+  +---+---+
									#*/
									stepx = 0
									stepy = 1
									break

								4, 12, 14:
									#/* going LEFT with these cases:
									#4          12         14
									#+---+---+  +---+---+  +---+---+
									#|   |   |  |   |   |  |   | 2 |
									#+---+---+  +---+---+  +---+---+
									#| 4 |   |  | 4 | 8 |  | 4 | 8 |
									#+---+---+  +---+---+  +---+---+
									#*/
									stepx = -1
									stepy = 0
									break

								2, 3, 7:
									#/* going RIGHT with these cases:
									#2          3          7
									#+---+---+  +---+---+  +---+---+
									#|   | 2 |  | 1 | 2 |  | 1 | 2 |
									#+---+---+  +---+---+  +---+---+
									#|   |   |  |   |   |  | 4 |   |
									#+---+---+  +---+---+  +---+---+
									#*/
									stepx = 1
									stepy = 0
									break
								9:
									#/* Going DOWN if coming from the LEFT, otherwise go UP.
									#9
									#+---+---+
									#| 1 |   |
									#+---+---+
									#|   | 8 |
									#+---+---+
									#*/
									if (prevx == 1):
										stepx = 0
										stepy = 1
									else:
										stepx = 0
										stepy = -1
									break
								6:
									#/* Going RIGHT if coming from BELOW, otherwise go LEFT.
									#6
									#+---+---+
									#|   | 2 |
									#+---+---+
									#| 4 |   |
									#+---+---+
									#*/
									if (prevy == -1):
										stepx = 1
										stepy = 0
									else:
										stepx = -1
										stepy = 0
									
									break
								_:
									print("this souldn't happen.")
							#endregion
							
							#region actualizando cross_map
							##Si la posición actual está en un cruce
							##lo procesa en el mapa de cruces
							if sv in [6, 9]:
								##Posición del cruce analizado
								var cur_pos: Vector2i = Vector2i(curx, cury)
								
								##Si ya está procesada
								#se fija en el mapa de cruces cuál es el índice
								#(osea en qué orden se descubrió ese punto) y ahí
								#elimina todos los que vengan después y que sean del
								#mismo polígono básicamente, así no se repiten los puntos
								if cur_pos in cross_map:
									##Índice del punto en donde está el cruce
									var found_index = cross_map[cur_pos]
									polygons.append(points.slice(found_index + 1, posize))
									posize = found_index + 1
									##Lista entera de cruces
									var keys = cross_map.keys()
									for key in keys:
										if cross_map[key] > found_index:
											cross_map.erase(key)
									cross_map.erase(cur_pos)
								else:
									cross_map[cur_pos] = posize - 1
							#endregion
							
							## El movimiento en sí sucede acá
							curx += stepx
							cury += stepy
							
							## Esto garantiza que el polígono no contenga
							## tres puntos consecutivos alineados.
							if stepx == prevx and stepy == prevy:
								points[posize -1] = Vector2i(curx, cury)
							else:
								points.resize(max(posize+1, points.size()))
								points[posize] = Vector2i(curx,cury)
								posize += 1
							
							count += 1
							prevx = stepx
							prevy = stepy
							
							if count > 2 * (r.size.x * r.size.y + 1):
								push_error("Infinite loop detected")
								return []
							if curx == startx and cury == starty:
								break
						points.resize(posize)
						output_land.polygons.append(points)
						
						if !fill.get_bitv(Vector2i(x,y)):
							pass
						#endregion
						
				output_land.polygons = polygons
				output_map.append(output_land)
	return output_map
#endregion

static func import_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file != null:
		return JSON.parse_string(file.get_as_text().replace("_", " "))
	else:
		print("Failed to open file:", path)
		return {}

static func export_json(path: String, dict: Dictionary) -> void:
	print("Saving data to JSON file")
	var file := FileAccess.open(path, FileAccess.WRITE)
	var json = JSON.stringify(dict, "\t")
	file.store_string(json)
	print("Data saved")

static func create_json(image: Image) -> Dictionary:
	var regions: Dictionary = import_json("res://map/definition.json")
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel_color = "#" + str(image.get_pixel(int(x), int(y)).to_html(false))
			if pixel_color not in regions:
				regions[pixel_color] = pixel_color
	export_json("res://map/definition_new.json", regions)
	return regions
