/*{
  "DESCRIPTION": "vector field demonstration",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/pTwLX9y5LQfFD3iey)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 2,
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
    "ORIGINAL_VIEWS": 60,
    "ORIGINAL_DATE": {
      "$date": 1673123446413
    }
  }
}*/

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
  // mouse position is the droplets position in this example
  gl_Position = vec4(mouse.x, mouse.y, 0,1);

  // apply vector field to the next point
  // to demonstrate effect of vector field
  if (vertexId == 1.) {
    vec2 d = field(mouse.xy);
    d = normalize(d);
    gl_Position += vec4(d.x, d.y, 0,1);
  }

  gl_PointSize = vertexId * 2.;
  v_color = vec4(1.0 - vertexId,1,1,1);
}