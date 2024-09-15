varying highp vec4 var_position;
varying mediump vec3 var_normal;
varying mediump vec2 var_texcoord0;
varying mediump vec4 var_light;

uniform lowp sampler2D tex0;
uniform lowp sampler2D tex1;
uniform lowp sampler2D tex2;
uniform lowp sampler2D tex3;
uniform lowp vec4 tint;
uniform lowp vec4 contrast;
uniform lowp vec4 brightness;
uniform lowp vec4 saturation;
uniform lowp vec4 gamma;
uniform lowp vec4 stinger;
uniform lowp vec4 blackbar;
uniform lowp vec4 stingercolor;
uniform lowp vec4 vignette;
uniform lowp vec4 vignette_opt;

uniform lowp vec4 resolution;

vec4 sprite_pass(vec4 color_world, vec4 color_sprite)
{
    return mix(color_world, color_sprite, color_sprite.a);

}

vec4 light_pass(vec4 color_world, vec4 color_light)
{
    return color_world * color_light;
}

vec2 normalize_xy(vec2 xy, float aspect, vec2 center)
{
    xy.x -= center.x;
    xy.x *= aspect;
    xy.x += center.x;
    return xy;
}

void main()
{
    float aspect = resolution.x / resolution.y;    
    vec2 center = vec2(.5, .5);
    vec2 normalized_xy = normalize_xy(var_texcoord0.xy, aspect, center);
    vec4 greyscale = vec4(0.299, 0.587, 0.114, 1.);
    vec4 blackbar_color = vec4(blackbar.rgb, 1.);
    vec4 color_world = texture2D(tex0, var_texcoord0.xy);
    vec4 color_light = texture2D(tex1, var_texcoord0.xy);
    vec4 color_gui = texture2D(tex2, var_texcoord0.xy);
    vec4 color_sprite = texture2D(tex3, var_texcoord0.xy);
    

    // sprite_pass
    vec4 world_sprite = sprite_pass(color_world, color_sprite);

    // light pass
    vec4 world_light = light_pass(world_sprite, color_light);

    // color contrast_brightness pass
    vec4 contrast_brightness = contrast * (world_light - 0.5) + 0.5 + brightness;
    contrast_brightness = clamp(contrast_brightness, 0.0, 1.0);

    // saturation pass
    vec4 saturated = mix(contrast_brightness,  greyscale, saturation);
    saturated = clamp(saturated, 0.0, 1.0);

    // gamma correction pass
    vec4 gammaed = pow(saturated, gamma);
    gammaed = clamp(gammaed, 0.0, 1.0);

    // gui draw pass
    vec4 world_light_corrected = mix(gammaed, color_gui, color_gui.a);

    // vignette
    vec2 vig_pos = var_texcoord0.xy;
    float vig_pct = distance(center, vig_pos);
    vec4 world_vignetted = mix(world_light_corrected, vignette, smoothstep(vignette_opt.x, vignette_opt.y, vig_pct));



    // distance field stinger pass
    float pct = distance(stinger.xy, normalized_xy);
    vec4 world_light_corrected_stingered = mix(world_vignetted, stingercolor, step(1. - pct, stinger.z));

    // blackbar pass
    float blackbar_rate = blackbar.w / 2.0;
    vec4 black_bar_pass = mix(world_light_corrected_stingered, blackbar_color, step(var_texcoord0.y, blackbar_rate));
    black_bar_pass = mix(black_bar_pass, blackbar_color, step(1.-blackbar_rate, var_texcoord0.y));

    
    gl_FragColor = black_bar_pass;
}

