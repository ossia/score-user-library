/*{
  "DESCRIPTION": "noise with time",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/2zrDmPHr7XSL9Smeh)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5000,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1568769748187
    }
  }
}*/

// hash function from https://www.shadertoy.com/view/4djSRW
float noise(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

void main() {
  float u = vertexId / vertexCount;
  vec2 xy = vec2(
    noise(u + time),
    noise(u * 0.6223)) * 2.0 - 1.0;
  gl_Position = vec4(xy, 0, 1);

  gl_PointSize = 2.0;
  v_color = vec4(1);
}