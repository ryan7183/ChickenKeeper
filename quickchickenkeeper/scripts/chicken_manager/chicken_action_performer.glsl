#[compute]
#version 450
#extension GL_EXT_shader_atomic_float:enable

layout(local_size_x = 100, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer PosInBuffer {
    vec2 data[];
}
pos_in;

layout(set = 0, binding = 1, std430) restrict buffer FoodInBuffer {
    float data[];
}
food_in;

//layout(set = 0, binding = 2, std430) restrict buffer FoodOutBuffer {
//    float data[];
//}
//food_out;

layout(set = 0, binding = 3, std430) restrict buffer HungerInBuffer {
    float data[];
}
hunger_in;

layout(set = 0, binding = 4, std430) restrict buffer HungerOutBuffer {
    float data[];
}
hunger_out;

layout(set = 0, binding = 5, std430) restrict buffer FatigueInBuffer {
    float data[];
}
fatigue_in;

layout(set = 0, binding = 6, std430) restrict buffer FatigueOutBuffer {
    float data[];
}
fatigue_out;

layout(set = 0, binding = 7, std430) restrict buffer ActionInBuffer {
    int data[];
}
action_in;

layout(set = 0, binding = 8, std430) restrict buffer SatisfactionInBuffer {
    float data[];
}
satisfaction_in;

layout(set = 0, binding = 9, std430) restrict buffer SatisfactionOutBuffer {
    float data[];
}
satisfaction_out;

layout(set = 0, binding = 10, std430) restrict buffer HealthInBuffer {
    float data[];
}
health_in;

layout(set = 0, binding = 11, std430) restrict buffer HealthOutBuffer {
    float data[];
}
health_out;

layout(push_constant) uniform Parameters {
    int terrain_width;
}
param;

int two_d_to_one_d_index(vec2 pos){
    int tile_width = 16;
    return int((int(pos.x/16) * param.terrain_width) + int(pos.y/16));
}

void main(){
    uint invocation = gl_GlobalInvocationID.x;
    float fatigue = fatigue_in.data[invocation];
    float hunger = hunger_in.data[invocation];
    vec2 position = pos_in.data[invocation];
    int tile_index = two_d_to_one_d_index(position);
    float food = food_in.data[tile_index];
    hunger_out.data[invocation] = max(hunger-0.8,0);
    fatigue_out.data[invocation] = max(fatigue-1.0,0);
    float satifaction = satisfaction_in.data[invocation];
    if(hunger>50 && fatigue>50){
        satifaction = min(satifaction+0.5,100);
    }else{
        satifaction = max(satifaction-0.25,0);
        
    }
    if(hunger<50 || fatigue<50){
        health_out.data[invocation] = health_in.data[invocation] - 0.02;
    }
    satisfaction_out.data[invocation] = satifaction;
    switch(action_in.data[invocation]){
        case 0://Eat
            food_in.data[tile_index] = 0;
            hunger_out.data[invocation] = min(hunger_out.data[invocation]+(food*2),100);
            //hunger_out.data[invocation]  = 100;
            break;
        case 1://Drink
            break;
        case 2://Wander
            break;
        case 3://Sit
            fatigue_out.data[invocation] = min(fatigue*1.1,100);
            break;
        case 4://Find Food
            break;
        case 5://Find Water
            break;
    }
}