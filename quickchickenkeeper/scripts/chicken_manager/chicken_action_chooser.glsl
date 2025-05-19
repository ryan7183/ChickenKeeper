#[compute]
#version 450

layout(local_size_x = 100, local_size_y = 1, local_size_z = 1) in;


layout(set = 0, binding = 0, std430) restrict buffer PosInBuffer {
    vec2 data[];
}
pos_in;

layout(set = 0, binding = 1, std430) restrict buffer TargetInBuffer {
    vec2 data[];
}
target_in;

layout(set = 0, binding = 2, std430) restrict buffer TargetOutBuffer {
    vec2 data[];
}
target_out;

layout(set = 0, binding = 3, std430) restrict buffer TerrainInBuffer {
    int data[];
}
terrain_in;

layout(set = 0, binding = 4, std430) restrict buffer HungerInBuffer {
    int data[];
}
hunger_in;

layout(set = 0, binding = 5, std430) restrict buffer FatigueInBuffer {
    float data[];
}
fatigue_in;

layout(set = 0, binding = 6, std430) restrict buffer ActionOutBuffer {
    int data[];
}
action_out;

layout(push_constant) uniform Parameters {
    float delta_time;
    int terrain_width;
}
param;

vec2 get_wander_target(vec2 pos){
    return vec2(0,0);
}

vec2 get_nearest_grass(vec2 pos){
    return vec2(0,0);
}

void main(){
    uint invocation = gl_GlobalInvocationID.x;
    float fatigue = fatigue_in.data[invocation];
    float hunger = hunger_in.data[invocation];
    vec2 position = pos_in.data[invocation];
    if (fatigue< 50 || hunger<50){
        //Hungry or tired
        if(fatigue<hunger && fatigue<50){
            action_out.data[invocation] = 3;
            target_out.data[invocation] = position;
        }else{
            action_out.data[invocation] = 4;
            vec2 nearest =  get_nearest_grass(position);
            target_out.data[invocation] =nearest;
            if (nearest.x<0 || nearest.y<0){
                target_out.data[invocation] = position;
            }
            
        }

    }else{
        //Satified
        action_out.data[invocation] = 2;
        target_out.data[invocation] =get_wander_target(position);
    }
}