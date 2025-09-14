/*{
  "DESCRIPTION": "vector field demonstration2",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/b3WFbQ4SDWLwXbcSp)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 56,
    "ORIGINAL_DATE": {
      "$date": 1673125264235
    }
  }
}*/

#define WIDTH 20.
#define SPACING 20.
#define LINE_LENGTH 10.

/*

Note that every line is perpendicular to ("facing") the mouse

*/

vec2 field(vec2 pos) {
  // just for easier readability
  float x = pos.x;
  float y = pos.y;

  // vector field mapping
  return vec2(
    -y,
    x
  );
}

void main() {
  // droplet grid positioning
  float x = floor(floor(vertexId/2.) / WIDTH) / SPACING;
  float y = mod(floor(vertexId/2.), WIDTH) / SPACING;
  vec2 line_pos = vec2(2.*x - 1.,2.*y - 1.);

  // droplet position in this example
  gl_Position = vec4(line_pos.x, line_pos.y, 0,1);

  // apply vector field to the next connecting point
  // to demonstrate effect of vector field
  if (mod(vertexId, 2.) == 1.) {

    // uses the field to calculate the displacement relative to the mouse's xy
    vec2 d = field(line_pos.xy - mouse.xy);

    // apply field calculation to vertex
    d = normalize(d) / LINE_LENGTH;
    gl_Position += vec4(d.x, d.y, 0,0);
  }

  gl_PointSize = 4.;
  v_color = vec4(mod(vertexId, 2.),1,1,1);
}