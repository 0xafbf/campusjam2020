
# cada archivo es una clase
# con extends heredas de otra clase
extends Node2D

tool #tool permite hacer cosas desde el editor

#aca el 'tool' lo uso como un hack interesante, porque
# se lo pongo a un bool, que siempre lo pongo en false, pero
# igual el editor llama la funcion entonces es como un boton
export var do_generate: bool = false setget set_generate

export var clear: bool = false setget do_clear

export var tile_template: PackedScene

var tiles: Array

export var grid_width: int = 10
export var grid_height: int = 10

export var tile_width = 10
export var tile_height = 10

export var random_seed: int = 123412 setget set_seed
export var noise_scale: float = 2.0 setget set_scale

var current_seed: int 

var rng: RandomNumberGenerator

var pixels: Array

func _ready():
	tiles = get_children()
	set_generate(true)

func set_seed(new_seed: int):
	
	random_seed = new_seed
	set_generate(do_generate)

func do_clear(val: bool):
	if not val:
		return
	if not tiles:
		return
	for tile in tiles:
		if tile:
			remove_child(tile)
			tile.queue_free()
	for tile in get_children():
		if tile:
			remove_child(tile)
			tile.queue_free()

# BILINEAR
func pixel_lerp(u: float, v: float):
	var left = floor(u)
	var right = ceil(u)
	var top = floor(v)
	var bottom = ceil(v)
	var top_left = pixels[to_array_idx(left, top)]
	var top_right = pixels[to_array_idx(right, top)]
	var bottom_left = pixels[to_array_idx(left, bottom)]
	var bottom_right = pixels[to_array_idx(right, bottom)]
	
	var dx2 = fposmod(u, 1.0)
	var dy2 = fposmod(v, 1.0)
	var dx1 = 1.0 - dx2
	var dy1 = 1.0 - dy2
	
	var result = top_left * dx1 * dy1
	result += top_right * dx2 * dy1
	result += bottom_left * dx1 * dy2
	result += bottom_right * dx2 * dy2
	return result

func set_scale(val):
	noise_scale = val
	if Engine.editor_hint:
		set_generate(true)

# rebuild
func set_generate(rebuild: bool):
	if not rebuild:
		return

	rng = RandomNumberGenerator.new()
	rng.seed = random_seed
	
	if len(tiles) != grid_width * grid_height:
		tiles = get_children()
	if len(tiles) != grid_width * grid_height:
		#clear when resizing
		do_clear(true)
		var new_tiles = Array()
		new_tiles.resize(grid_width * grid_height)
		tiles = new_tiles
	
	if len(pixels) != grid_width * grid_height:
	
		# fill pixels
		pixels.resize(grid_width * grid_height)
	
	for idx in range(grid_width):
		for jdx in range(grid_height):
			var value = calc_rand(idx, jdx)
			pixels[to_array_idx(idx, jdx)] = value
			
	
	
	var inv_scale = 1.0 / noise_scale
	for idx in range(grid_width):
		for jdx in range(grid_height):
			var value = pixel_lerp(idx * inv_scale, jdx * inv_scale)
			var tile_idx = to_array_idx(idx, jdx)
			var tile: ATile = tiles[tile_idx]
			
			if tile == null: # value > 0.5:
				tile = tile_template.instance() 
				tiles[tile_idx] = tile
			
				add_child(tile)
				tile.set_owner(owner)
				
				tile.position.x = tile_width * idx
				tile.position.y = tile_height * jdx
				
			tile.set_active(value < 0.5)
				
			tile.color = Color(value, value, value)


func calc_rand(x: int, y: int):
	return rng.randf()

func to_array_idx(x: int, y: int):
	return y * grid_width + x	
	
func to_coordinates(idx: int):
	return [idx % grid_width, idx / grid_width]

