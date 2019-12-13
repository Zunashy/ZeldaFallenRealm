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

uniform vec4 visu_box;

void main() {
    if(!sol_vcolor_only) {
      vec4 tex_color = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);

      vec4 col;
      if (sol_vtex_coord.x > visu_box.x && sol_vtex_coord.x < visu_box.x + visu_box.z && sol_vtex_coord.y > visu_box.y && sol_vtex_coord.y < visu_box.y + visu_box.w){
        col = vec4(1.0, 0.0, 0.0, 1.0);
      } else {
        col = tex_color;
      }

      FragColor = col;
      
    } else {
      FragColor = sol_vcolor;
    }
}
