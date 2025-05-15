#[compute]
#version 450

layout(local_size_x = 100, local_size_y = 1, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, std430) restrict buffer PosInBuffer {
    vec2 data[];
}
pos_in;

layout(set = 0, binding = 1, std430) restrict buffer PosOutBuffer {
    vec2 data[];
}
pos_out;

layout(set = 0, binding = 2, std430) restrict buffer TargetInBuffer {
    vec2 data[];
}
target_in;

layout(push_constant) uniform Parameters {
    float delta_time;
    int work_groups;
}
param;

void move_away_from_neighbors(int invocation){
    
}


void main(){
    uint invocation = gl_GlobalInvocationID.x;
    vec2 chicken_pos = pos_in.data[invocation];
    vec2 target = target_in.data[invocation];
    vec2 direction = normalize(target.xy-chicken_pos.xy);
    chicken_pos = chicken_pos.xy + (direction.xy * 10 *  param.delta_time);

    int num = pos_in.data.length();
    for(int i= 0; i<num; i++){
        if (i != invocation){
            vec2 neighbor = pos_in.data[i];
            float dist = distance(chicken_pos,neighbor);
            if(dist<24){
                vec2 direction = normalize(chicken_pos.xy-neighbor.xy);
                chicken_pos.xy = chicken_pos.xy + (direction.xy * 10 *  param.delta_time);
            }
        }
    }
    pos_out.data[invocation].xy = chicken_pos.xy;
}

