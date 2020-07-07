extends Node2D

tool

var buffer1: Buffer
var buffer2: Buffer
export var buf1_x: int = 64
export var buf1_y: int = 64
export var buf1_seed: int = 64
export var buf1_scale: float = 0.2
export var buf1_strength: float = 1


export var debug_image: Image

export var do_rebuild: bool setget rebuild

var tiles_front: PoolByteArray
var tiles_back: PoolByteArray

func rebuild(in_rebuild: bool):
	if not in_rebuild:
		return
	print("rebuilding")
	if not buffer1 is Buffer:
		buffer1 = Buffer.new()
	if not buffer2 is Buffer:
		buffer2 = Buffer.new()
	
	if not debug_image:
		debug_image = Image.new()
	
	debug_image.create(buf1_x, buf1_y, false, Image.FORMAT_RGB8)
	
		
	buffer1.fill_noise(buf1_x, buf1_y, buf1_seed)
	buffer2.fill_noise(buf1_x, buf1_y, buf1_seed+1)
	

	
	if not tiles_front or not tiles_front is PoolByteArray:
		tiles_front = PoolByteArray()
	if tiles_front.size() != buf1_x * buf1_y:
		tiles_front.resize(buf1_x * buf1_y)
		
	
	for row in range(buf1_y):
		for col in range(buf1_x):
			var tile: int = 2
			
			var sample = buf1_strength * buffer1.pixel_lerp(col * buf1_scale, row * buf1_scale)
			if sample > 0.5:
				tile = 0
			
			tiles_front[row * buf1_x + col] = tile
			
	debug_image.lock()
	for row in range(buf1_y):
		for col in range(buf1_x):
			var arr_idx = row * buf1_x + col
			var v = buffer1.array[arr_idx]
			#var v = buffer1.pixel_lerp(col, row)
			var color = Color(v,v,v,1)
			debug_image.set_pixel(col, row, color)
	debug_image.unlock()
		
	var tex = ImageTexture.new()
	tex.create_from_image(debug_image)
	$Sprite.texture = tex
	
	var tilemap: TileMap = get_node(tilemap_path)
	update_boundaries(tiles_front, tilemap, get_vision_rect())
	
export var player_path: NodePath
export var bounds: Vector2 = Vector2(160, 90)
export var cell_size: float

export var tilemap_path: NodePath

var last_top: int
var last_bottom: int
var last_left: int
var last_right: int

func update_boundaries(tiles: PoolByteArray, tilemap: TileMap, rect: Rect2):
	var player: Node2D = get_node(player_path)
	var position = player.position
	var inv_cell_size = 1.0 / cell_size
	var top = floor(rect.position.y)
	var bottom = ceil(rect.end.y)
	var left = floor(rect.position.x)
	var right = ceil(rect.end.x)
	
	if top == last_top \
		and bottom == last_bottom \
		and left == last_left \
		and right == last_right:
			return
	
	for row in range(top, bottom):
		for col in range(left, right):
			var val = tiles[row * buf1_x + col] % (buf1_x * buf1_y)
			tilemap.set_cell(col, row, val)
	
	print("updating region: x %f %f    y %f %f" % [left, right, top, bottom])
	tilemap.update_bitmask_region(Vector2(left, top), Vector2(right, bottom))
	
	last_top = top
	last_bottom = bottom
	last_left = left
	last_right = right
	
func _process(delta: float):
	var tilemap: TileMap = get_node(tilemap_path)
	if tiles_front.size() == 0:
		rebuild(true)
	update_boundaries(tiles_front, tilemap, get_vision_rect())
	
	
func get_vision_rect():
	var player: Node2D = get_node(player_path)
	var position = player.position
	var inv_cell_size = 1.0 / cell_size
	
	var top = floor((position.y - bounds.y) * inv_cell_size)
	var bottom = ceil((position.y + bounds.y) * inv_cell_size)
	var left = floor((position.x - bounds.x) * inv_cell_size)
	var right = ceil((position.x + bounds.x) * inv_cell_size)
	return Rect2(left, top, right-left, bottom-top)
	

