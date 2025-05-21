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

layout(set = 0, binding = 3, std430) restrict buffer FoodInBuffer {
    float data[];
}
food_in;

layout(set = 0, binding = 4, std430) restrict buffer FoodOutBuffer {
    float data[];
}
food_out;

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
    //If dirt
    if(terrain_in.data[invocation] == 1 ){
        terrain_out.data[invocation] =1;
        changed_out.data[invocation] = false;
        uint neighbor_count = 0;
        float food_count = 0;
        if (invocation-width >=0 && terrain_in.data[invocation-width]==0){
            neighbor_count +=1;
            food_count+=food_in.data[invocation-width];
        }
        if(invocation+width <terrain_in.data.length() && terrain_in.data[invocation+width]==0){
            neighbor_count +=1;
            food_count+=food_in.data[invocation+width];
        }
        if(invocation+1 <terrain_in.data.length() && terrain_in.data[invocation+1]==0){
            neighbor_count +=1;
            food_count+=food_in.data[invocation+1];
        }
        if(invocation-1 >=0 && terrain_in.data[invocation-1]==0){
            neighbor_count +=1;
            food_count+=food_in.data[invocation-1];
        }
        if (food_count>99.0 && random(vec2(invocation+param.time,0))*10 < 0.1 && neighbor_count>0){
            terrain_out.data[invocation] = 0;
            changed_out.data[invocation] = true;
            food_out.data[invocation] = 10.0;
        }
    //If grass with no food
    }else if(terrain_in.data[invocation] == 0 && food_in.data[invocation]<0.001){
        terrain_out.data[invocation] = 1;
        changed_out.data[invocation] = true;
        food_out.data[invocation] = 0;    
    }else{
        terrain_out.data[invocation] = terrain_in.data[invocation];
        changed_out.data[invocation] = false;
        food_out.data[invocation] = min(food_in.data[invocation] * 1.001, 100);
    }
}