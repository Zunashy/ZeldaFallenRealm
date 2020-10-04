#ifdef GL_ES
precision mediump float;
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

in vec2 sol_vtex_coord;
in vec4 sol_vcolor;
layout(origin_upper_left, pixel_center_integer) in vec4 gl_FragCoord;

out vec4 FragColor;

uniform sampler2D sol_texture;
uniform vec2 sol_input_size;

uniform float rad;
uniform vec2 center;
uniform float width;
uniform float amplitude;
uniform float refraction;

void main(){

    float dist = distance(gl_FragCoord.xy, center);

    if ((dist <= rad + width) && (dist >= rad - width)){
        float diff = (dist - rad) / width; //to stay between -1.0 and 1.0
        float diffPow = 1.0 - pow(abs(diff), refraction);
        float diffFinal = diff * diffPow;
        vec2 dir = normalize(gl_FragCoord.xy - center);
        vec2 uv = (gl_FragCoord.xy + dir * diffFinal * amplitude).xy / sol_input_size.xy;

        FragColor = texture(sol_texture, uv);
    } else {
        FragColor = texture(sol_texture, sol_vtex_coord);
    }
}