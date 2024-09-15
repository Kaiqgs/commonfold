// #include "/common/shaders/2x2dither.glsl"
// #include "/common/shaders/4x4dither.glsl"
#include "/common/shaders/8x8dither.glsl"

varying mediump vec2 var_texcoord0;
varying mediump vec4 var_position;

uniform lowp sampler2D texture_sampler;
uniform lowp vec4 tint;

void main()
{
    // Pre-multiply alpha since all runtime textures already are
    lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    vec4 texture = texture2D(texture_sampler, var_texcoord0.xy) * tint_pm;
    vec2 pos = var_position.xy;
    //gl_FragColor = texture;
    gl_FragColor = vdither8x8(pos, texture);
}
