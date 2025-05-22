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

/**layout(set = 0, binding = 7, std430) restrict buffer IndexOutBuffer {
    float data[];
}
index_out;
*/

layout(push_constant) uniform Parameters {
    float delta_time;
    int terrain_width;
}
param;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

vec2 get_wander_target(vec2 pos, float seed){
    float delta = param.delta_time;
    float posx = (random(vec2(delta + seed,0))-0.5)*10;
    float posy = (random(vec2(0,delta+seed))-0.5)*10;
    vec2 move =  vec2(posx, posy);
    vec2 tar = min(max(pos + move, vec2(0,0)),vec2(1600,1600));
    return tar;
}

vec2 get_nearest_grass(vec2 pos){
    vec2 nearest_grass = vec2(0,0);
    float n_dist = 100;
    bool found = false;
    ivec2 tile_pos = ivec2(pos/16.0);
    for(int x= -2;x<=2;x++){
        for(int y= -2;y<=2;y++){
            int x_index = int(floor(tile_pos.x) +x);
            int y_index = int(floor(tile_pos.y) + y);
            int index = (x_index * param.terrain_width) + y_index;
            int tile = terrain_in.data[index];//terrain_in.data[index];
            float dist = abs(x)+abs(y);
            if( tile==0 && dist <= n_dist){
                found = true;
                nearest_grass = (vec2(x_index, y_index)) * 16.0;
                n_dist = dist;
            }
        }
    }

    if(!found){
        nearest_grass = get_wander_target(pos, param.delta_time + gl_GlobalInvocationID.x);
    }

    return nearest_grass;
}

void main(){
    uint invocation = gl_GlobalInvocationID.x;
    float fatigue = fatigue_in.data[invocation];
    float hunger = hunger_in.data[invocation];
    vec2 position = pos_in.data[invocation];
    vec2 cur_tar = target_in.data[invocation];
    if (fatigue< 90 || hunger<90){
        //Hungry or tired
        if(fatigue<hunger && fatigue<90){
            action_out.data[invocation] = 3;
            target_out.data[invocation] = position;
        }else{
            action_out.data[invocation] = 4;
            vec2 nearest =  get_nearest_grass(position);
            target_out.data[invocation] =nearest;
            float dist = distance(position,nearest);
            if(dist< 16){
                action_out.data[invocation] = 0;
                target_out.data[invocation] = nearest;
            }else if (nearest.x<0 || nearest.y<0 || nearest.y>param.terrain_width*16 || nearest.x>param.terrain_width*16){
                target_out.data[invocation] = position;
            }
            
        }

    }else{
        //Satified
        action_out.data[invocation] = 2;
        float dist = distance(position, cur_tar);
        if (dist<0.01){
            vec2 tar = get_wander_target(position, float(invocation));
            target_out.data[invocation] = tar;
            if (tar.x<0 || tar.y<0 || tar.y>param.terrain_width*16 || tar.x>param.terrain_width*16){
                target_out.data[invocation] = position;
            }
        }
       
    }
}