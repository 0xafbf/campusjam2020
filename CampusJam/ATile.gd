extends StaticBody2D
class_name ATile
tool

export var color: Color setget set_color

#como este script es tool, este set_color se llama aun si cambio cosas
# desde el editor

#permite cosas cheveres, puedo cambiar variables de un 'prefab' y se actualizan
# objetos internos
func set_color(new_color: Color):
	color = new_color
	if $Polygon2D:
		$Polygon2D.color = color

func set_active(new_active):
	$Polygon2D.visible = new_active
	if new_active:
		collision_mask = 1
		collision_layer = 1
	else:
		collision_mask = 0
		collision_layer = 0

