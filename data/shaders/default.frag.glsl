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

void main() {
    if(!sol_vcolor_only) {
      vec4 tex_color = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
      FragColor = tex_color * sol_vcolor;
      if(sol_alpha_mult) {
        FragColor.rgb *= sol_vcolor.a; //Premultiply by opacity too
      }
    } else {
      FragColor = sol_vcolor;
    }
}
