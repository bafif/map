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
	var stack: Array[FillBitsStackEntry]
	var stsize: int = 0
	
	## Variables para el while por color
	var cur: Vector2i = Vector2i.ZERO
	var nexi: int = 0
	var nexj: int = 0
	var reenter: bool = true
	var popped: bool = false
	
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
				
				## Lista de polígonos pertenecientes al color
				var polygons: Array[PackedVector2Array]
				
				nexi = 0
				nexj = 0
				cur = Vector2i(x,y)
				
				## Algoritmo de Fill Bits
				while(reenter||popped):
					if(reenter):
						nexi = cur.x - 1
						nexj = cur.y - 1
						reenter = false
					## Loop de Fill Bits
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
									var se: FillBitsStackEntry
									se.cur = cur
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
								cur = se.cur
								nexi = se.i
								nexj = se.j
								popped = true
				## Variables para el marching square
				var stepx: int = 0
				var prevx: int = 0
				var startx: int = x
				var stepy: int = 0
				var prevy: int = 0
				var starty: int = y
				var curx: int = startx
				var cury: int = starty
				var count: int = 0
				var points: Array[Vector2i]
				var posize: int = 0
				var ret
				ret.resize(1)
				
				## Algoritmo de marching squares
				while(curx != startx || cury != starty):
						#checking the 2x2 pixel grid, assigning these values to each pixel, if not transparent
						#+---+---+
						#| 1 | 2 |
						#+---+---+
						#| 4 | 8 | <- current pixel (curx,cury)
						#+---+---+
						var sv: int = 0
						var tl: Vector2i = Vector2i(curx - 1, cury - 1)
						sv = sv + 1 if (r.has_point(tl) && color == source.get_pixel(tl.x, tl.y)) else 0
						var tr: Vector2i = Vector2i(curx, cury - 1)
						sv = sv + 1 if (r.has_point(tr) && color == source.get_pixel(tr.x, tr.y)) else 0
						var bl: Vector2i = Vector2i(curx - 1, cury)
						sv = sv + 1 if (r.has_point(bl) && color == source.get_pixel(bl.x, bl.y)) else 0
						var br: Vector2i = Vector2i(curx, cury)
						sv = sv + 1 if (r.has_point(br) && color == source.get_pixel(br.x, br.y)) else 0
						if (sv == 0 || sv == 15): ERR_INVALID_DATA
						
					
				if !fill.get_bitv(Vector2i(x,y)):
					pass
			pixel_dict[color].append(Vector2(x,y))
