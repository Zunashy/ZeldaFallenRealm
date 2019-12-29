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

uniform vec3 lights;
uniform float lights_n;
uniform float obs_level;

void main()
{
    float level = obs_level;

    vec4 tex_color = texture(sol_texture, sol_vtex_coord.xy);
    
    vec3 col = tex_color.xyz;

    if (lights_n > 0) {
      vec2 d = gl_FragCoord.xy - lights.xy;
      float dist = sqrt(d.x * d.x + d.y * d.y);
      if (dist < lights.z) {
        level += (lights.z - dist) / 10.0;
      }
    }

    col -= col / level;

    FragColor = vec4(col, 1.0);
    
}