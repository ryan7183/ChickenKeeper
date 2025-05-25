shader_type canvas_item;

//uniform sampler2D atlas;
uniform vec2 atlas_grid_size = vec2(384, 144);
uniform vec2 tile_texture_size = vec2(24,24);
// This will hold per-instance data from vertex shader
varying vec2 v_frame_index;
varying float color_info;
void vertex() {
    // Decode tile index from INSTANCE_CUSTOM.xy
    v_frame_index = INSTANCE_CUSTOM.xy;
	color_info = INSTANCE_CUSTOM.z;
}

ivec4 get_next_3_digits(int number){
	int altered_num = number;
	ivec4 result = ivec4(0,0,0,0);
	result.x = altered_num%10;
	altered_num = altered_num/10;
	result.y = altered_num%10;
	altered_num =altered_num/10;
	result.z = altered_num%10;
	altered_num =altered_num/10;
	result.a = altered_num;
	return result;
}

ivec3 get_next_2_digits(int number){
	int altered_num = number;
	ivec3 result = ivec3(0,0,0);
	result.x = altered_num%10;
	altered_num = altered_num/10;
	result.y = altered_num%10;
	altered_num =altered_num/10;
	result.z = altered_num;
	return result;
}

vec3 extract_color_amount(int number){
	vec3 result = vec3(0,0,0);
	int altered_num = number;
	result.x = float(altered_num%1000)/100.0;
	altered_num = altered_num/1000;
	result.y = float(altered_num%1000)/100.0;
	altered_num = altered_num/1000;
	result.z = float(altered_num%1000)/100.0;
	altered_num = altered_num/1000;
	return result;
}

void fragment() {
	vec2 tile_size = vec2(tile_texture_size.x/atlas_grid_size.x, tile_texture_size.y/atlas_grid_size.y);
    vec2 uv = UV * tile_size + tile_size * v_frame_index;
	vec2 white_uv = uv;
	white_uv.y += tile_size.y*3.0;
	
	int color_number = int(color_info);
	vec3 color_amounts = extract_color_amount(color_number);
	vec4 black_chicken = texture(TEXTURE,uv);
	vec4 white_chicken = texture(TEXTURE,white_uv);
	vec4 final_color = vec4(0,0,0,1.0);
	final_color.r = mix(black_chicken.r,white_chicken.r,color_amounts.r);
	final_color.g = mix(black_chicken.g,white_chicken.g,color_amounts.g);
	final_color.b = mix(black_chicken.b,white_chicken.b,color_amounts.b);
	final_color.a = mix(black_chicken.a,white_chicken.a,0.0);
    COLOR = final_color;//texture(TEXTURE,uv);//texture(atlas, uv);
	//COLOR.rgb = color_amounts.rgb;//extract_color_amount(color_number).b*100.0;
}