/*{
  "DESCRIPTION": "PseudoRandomParticles",
  "CREDIT": "shtrompel (ported from https://www.vertexshaderart.com/art/rMKz3eBbT4NuADdZY)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 4000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 150,
    "ORIGINAL_DATE": {
      "$date": 1530284139225
    }
  }
}*/

#define PI radians(180.)

// Pseudo-random number generator
// Taken from "The Book Of Shader"
// https://thebookofshaders.com/10/
float random(vec2 st) {
  return fract(sin(dot(st.xy,vec2(120.9898,708.233) * 43758.5453123)));
}

void main() {
  //Generate random x and y position
  float x_Pos = random(vec2(vertexId / vertexCount, 0));
  x_Pos = 4.0 * (x_Pos - 0.5);
  float y_Pos = random(vec2(vertexId / vertexCount, 1));
  y_Pos = 4.0 * (y_Pos - 0.5);

  //Create circular movement with the sin and cos functions theme
  x_Pos += sin(time / 4. + vertexId / vertexCount);
  y_Pos += cos(time * 1.25 + vertexId / vertexCount);

  vec2 position = vec2(x_Pos, y_Pos);

  //Some mouse interactivity
  position += position * distance(mouse, position) * 2.0 * step(distance(mouse, position), 0.6);

  //Apply position
  gl_Position = vec4(position, 0, 1);

  gl_PointSize = 10.0;

  //Generate random color
  float r = random(vec2(vertexId / vertexCount, 2)) / 4.;
  float g = random(vec2(vertexId / vertexCount, 3)) / 4.;
  float b = random(vec2(vertexId / vertexCount, 4)) / 4.;

  //Create smooth color transitioning with the sin function
  r += sin(time / 1.4 + 1.12) / 4.0 * 3.0;
  g += sin(time / 0.9 + 0.25) / 4.0 * 3.0;
  b += sin(time / 1.2 + 1.62) / 4.0 * 3.0;

  //Apply color
  v_color = vec4(r, g, b, 0.25);
}