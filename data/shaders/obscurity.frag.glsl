#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
precision mediump float;
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform sampler2D sol_texture;
uniform bool sol_vcolor_only;
uniform bool sol_alpha_mult;
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

uniform vec3 light1;
uniform vec3 light2;
uniform vec3 light3;
uniform vec3 light4;
uniform float n_lights;
uniform float obs_level;

void main()
{
    float level = obs_level;

    vec4 tex_color = texture(sol_texture, sol_vtex_coord.xy);
    
    vec3 col = tex_color.xyz;

    if (n_lights > 0){
        vec2 d = gl_FragCoord.xy - light1.xy;
        float dist = sqrt(d.x * d.x + d.y * d.y);
        if (dist < light1.z) {
            level += (light1.z - dist) / 10.0;
        }
    }
    if (n_lights > 1){
        vec2 d = gl_FragCoord.xy - light2.xy;
        float dist = sqrt(d.x * d.x + d.y * d.y);
        if (dist < light2.z) {
            level += (light2.z - dist) / 10.0;
        }
    } 
    if (n_lights > 2){
        vec2 d = gl_FragCoord.xy - light3.xy;
        float dist = sqrt(d.x * d.x + d.y * d.y);
        if (dist < light3.z) {
            level += (light3.z - dist) / 10.0;
        }
    } 
    if (n_lights > 3){
        vec2 d = gl_FragCoord.xy - light4.xy;
        float dist = sqrt(d.x * d.x + d.y * d.y);
        if (dist < light4.z) {
            level += (light4.z - dist) / 10.0;
        }
    } 
    col -= col / level;

    FragColor = vec4(col, 1.0);
    
}