#[compute]
#version 450

layout(local_size_x = 100, local_size_y = 1, local_size_z = 1) in;


layout(set = 0, binding = 0, std430) restrict buffer TerrainInBuffer {
    int data[];
}
terrain_in;

layout(set = 0, binding = 1, std430) restrict buffer TerrainOutBuffer {
    int data[];
}
terrain_out;

layout(set = 0, binding = 2, std430) restrict buffer ChangedOutBuffer {
    bool data[];
}
changed_out;

layout(push_constant) uniform Parameters {
    float delta_time;
    float time;
    int terrain_width;
}
param;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void main(){
    uint invocation = gl_GlobalInvocationID.x;
    int width = param.terrain_width;
    if(terrain_in.data[invocation] == 1 ){
        uint neighbor_count = 0;
        if (invocation-width >=0 && terrain_in.data[invocation-width]==0){
            neighbor_count +=1;
        }
        if(invocation+width <terrain_in.data.length() && terrain_in.data[invocation+width]==0){
            neighbor_count +=1;
        }
        if(invocation+1 <terrain_in.data.length() && terrain_in.data[invocation+1]==0){
            neighbor_count +=1;
        }
        if(invocation-1 >=0 && terrain_in.data[invocation-1]==0){
            neighbor_count +=1;
        }
        if (random(vec2(invocation+param.time,invocation))*(2.0/neighbor_count) < 0.001){
            terrain_out.data[invocation] = 0;
            changed_out.data[invocation] = true;
        }
            
    }else{
        terrain_out.data[invocation] = terrain_in.data[invocation];
        changed_out.data[invocation] = false;
    }
}