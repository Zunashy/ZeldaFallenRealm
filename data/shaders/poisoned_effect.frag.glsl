
#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

out COMPAT_PRECISION vec4 FragColor;

uniform sampler2D sol_texture;
uniform bool sol_vcolor_only;
uniform bool sol_alpha_mult;
in vec2 sol_vtex_coord;
in vec4 sol_vcolor;

void main() {
    if (!sol_vcolor_only) {
        vec4 col = texture(sol_texture, sol_vtex_coord);
        FragColor = vec4(col.r + 0.5, col.g, col.b + 0.5, col.a);
        
        if (sol_alpha_mult) {
            FragColor.rgb *= sol_vcolor.a; //Premultiply by opacity too
        }
    } else {
        FragColor = sol_vcolor;
    }
}
