class_name Buffer

var width: int = 64
var height: int = 64
var array: PoolRealArray

func set_size(in_width: int, in_height: int):
	width = in_width
	height = in_height
	if len(array) != width * height:
		array.resize(width * height)
		
func fill_noise(in_width: int, in_height: int, in_seed: int):
	set_size(in_width, in_height)
	
	var seed_hash = hash(in_seed)
	var num_iters = width * height
	var x: int
	var y: int
	for idx in range(num_iters):
		x = idx % width
		y = idx / width
		seed(seed_hash + y*516843 + x*8843 + x * y * 433)
		array[idx] = randf()
		
		

func pixel_lerp(u: float, v: float):
	var left = floor(u)
	var right = ceil(u)
	var top = floor(v)
	var bottom = ceil(v)
	var top_left = array[to_array_idx(left, top)]
	var top_right = array[to_array_idx(right, top)]
	var bottom_left = array[to_array_idx(left, bottom)]
	var bottom_right = array[to_array_idx(right, bottom)]
	
	var dx2 = fposmod(u, 1.0)
	var dy2 = fposmod(v, 1.0)
	var dx1 = 1.0 - dx2
	var dy1 = 1.0 - dy2
	
	var result = top_left * dx1 * dy1
	result += top_right * dx2 * dy1
	result += bottom_left * dx1 * dy2
	result += bottom_right * dx2 * dy2
	return result


func to_array_idx(x: int, y: int):
	return y * width + x	

func to_coordinates(idx: int):
	return [idx % width, idx / width]

