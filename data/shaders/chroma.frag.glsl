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
uniform vec2 sol_output_size;
uniform bool sol_vcolor_only;
uniform bool sol_alpha_mult;
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

void main() {
    if(!sol_vcolor_only) {
      float amount = 0.02;
      vec2 uv = sol_vtex_coord;
      vec3 col;
      col.r = COMPAT_TEXTURE( sol_texture, vec2(uv.x - amount, uv.y) ).r;
      col.g = COMPAT_TEXTURE( sol_texture, uv ).g;
      col.b = COMPAT_TEXTURE( sol_texture, vec2(uv.x + amount, uv.y) ).b;      
      FragColor = vec4(col, 1.0);

    } else {
      FragColor = sol_vcolor;
    }
}

