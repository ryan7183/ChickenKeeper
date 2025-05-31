extends Node

func byte_array_to_vec2_array(bytes:PackedByteArray, size:int)->Array[Vector2]:
	var decoded :Array = bytes.to_float32_array()
	var arr: Array[Vector2] = []
	arr.resize(size)
	var index:int = 0
	for i:int in range(1,decoded.size(),2):
		arr[index] = Vector2(decoded[i-1],decoded[i])
		index+=1
		pass
	
	return arr
	

func one_d_to_two_d_square_array(arr:Array, width:int)->Array[Array]:
	var new_arr:Array[Array] = []
	new_arr.resize(width)
	for x:int in range(width):
		var col:Array = []
		col.resize(width)
		for y:int in range(width):
			var index:int = (x*width)+y
			col[y] = arr[(x*width)+y]
			pass
		new_arr[x] = col
	return new_arr
