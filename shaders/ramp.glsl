
vec4 ramp(vec4 color, vec4[32] palette){
    // iterate and find closest
    float min_dist = 1e10;
    int min_index = 0;
    for (int i = 0; i < 32; i++){
        float dist = distance(color, palette[i]);
        if (dist < min_dist){
            min_dist = dist;
            min_index = i;
        }
    }
    return palette[min_index];
}
