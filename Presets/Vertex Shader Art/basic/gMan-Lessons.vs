/*{
  "DESCRIPTION": "gMan-Lessons - Just following the lessons\nfrom Youtube.",
  "CREDIT": "hugo-w (ported from https://www.vertexshaderart.com/art/3QtDqanQXHR4KXBo2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.10980392156862745,
    0.10980392156862745,
    0.10980392156862745,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1619198718606
    }
  }
}*/

// Lesson at

// L2:
//

// Every shader needs a main
// number of vertices fixed up there

// Check the help to know which variables are available around

// some code to convert HSV to RGB
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1., 2.0/ 3.0, 1.0/3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  // Get x, y coordinates on a grid
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float xoff = sin(time + y * 0.2) * .1;
  float yoff = sin(time*1.1 + x * 0.3) * .1;

  // scale to get a fix number across the width
  float u = x / (across - 1.);
  float v = y / (across - 1.);
  // scale it back to [-1, 1]
  float ux = u*2. - 1. + xoff;
  float vy = v*2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0, 1); // x, y, z, (w) (each one from -1 to 1

  // Adjust size of points by time too
  float soff = sin(time*1.2 + x * y * 0.02) * 5.;

  gl_PointSize = 12.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float hue = u * .1 + sin(time * 1.3 + v * 20.) * 0.05;
  float sat = 1.;
  float val = sin(time * 1.4 * v * u * 20.) * .5 + .5; // check replace the "+" by a "*" in the sin

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1); // v_color is specific to vertexshader.com (it's the gl_FragColor) equivalent

}