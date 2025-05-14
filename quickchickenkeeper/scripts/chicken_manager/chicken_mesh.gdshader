shader_type canvas_item;

//uniform sampler2D atlas;
uniform vec2 atlas_grid_size = vec2(384, 144);
uniform vec2 tile_texture_size = vec2(24,24);
// This will hold per-instance data from vertex shader
varying vec2 v_frame_index;

void vertex() {
    // Decode tile index from INSTANCE_CUSTOM.xy
    v_frame_index = INSTANCE_CUSTOM.xy;
}

void fragment() {
	vec2 tile_size = vec2(tile_texture_size.x/atlas_grid_size.x, tile_texture_size.y/atlas_grid_size.y);
    vec2 uv = UV * tile_size + tile_size * v_frame_index;

    COLOR = texture(TEXTURE,uv);//texture(atlas, uv);
}