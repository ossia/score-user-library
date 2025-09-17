/*{
  "DESCRIPTION": "Vertex Shader Art: Lesson 3 - Working with colors",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/NTihgba8cFq4fMyQF)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1524510084980
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float down = floor(sqrt(vertexCount)); // gets the count of rows
  float across = floor(vertexCount / down); // gets the count of columns

  // vertexId is the
  float x = mod(vertexId, across); // always use floats
  float y = floor(vertexId / across); // rounds numbers down 0.1 = 0, 10 = 1

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float xOffset = sin(time * 1.7 + y * 0.2) * 0.1;
  float yOffset = sin(time * 0.5 + x * 0.3) * 0.2;

  float ux = u * 2.0 - 1.0 + xOffset; // gets value from -1 to 1
  float uy = v * 2.0 - 1.0 + yOffset; // gets value from -1 to 1

  vec2 xy = vec2(ux, uy) * 1.3;

  float sizeOffset = sin(time * 3.5 + x * y * 0.02) * 5.0;

  gl_Position = vec4(xy, 0.0, 1.0);
  gl_PointSize = 200.0 / across; // set point size
  gl_PointSize *= resolution.x / 600.0 + sizeOffset;

  float hue = u * 0.1 + sin(time * 1.25 + v * 20.0) * 0.05;
  float sat = 1.;
  float value = sin(time * 2.0 + v * u * 20.0) * 0.5 + 0.5;

  v_color = vec4(hsv2rgb(vec3(hue, sat, value)), 1); // this is unique to vertex shader art
}