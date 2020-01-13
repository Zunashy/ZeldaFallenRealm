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

void darken(out vec3 col){
  float level = obs_level;
  
  col = tex_color.xyz;

  if (lights_n > 0) {
    vec2 d = gl_FragCoord.xy - lights.xy;
    float dist = sqrt(d.x * d.x + d.y * d.y);
    if (dist < lights.z) {
      level += (lights.z - dist) / 10.0;
    }
  }

  col -= col / level;

  col = vec4(col, 1.0);
}

void chroma(out vec3 col){
  float amount = 0.02;
  vec2 uv = sol_vtex_coord;
  vec3 col;
  col.r = COMPAT_TEXTURE( sol_texture, vec2(uv.x - amount, uv.y) ).r;
  col.g = COMPAT_TEXTURE( sol_texture, uv ).g;
  col.b = COMPAT_TEXTURE( sol_texture, vec2(uv.x + amount, uv.y) ).b;      
  FragColor = vec4(col, 1.0);
}

void main()
{
  vec3 color = texture(sol_texture, sol_vtex_coord.xy).xyz;

  if (obs_level > 0){
    darken(color)
  }
    
}