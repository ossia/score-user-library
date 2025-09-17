/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "gitanely (ported from https://www.vertexshaderart.com/art/RfnraoGGxrRDND4T8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1505,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1569562376341
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  vec2 scr = vec2(
       vertexId / vertexCount * 2.0,
      vertexId / vertexCount * 2.0);

  gl_Position.x = scr.x - 1.;//cos(time * scr.x) * scr.x;
  gl_Position.y = sin(vertexId + time) * 1.;
  gl_Position.y = tan(gl_Position.y + time) * 0.1;
  gl_Position.z = 0.;

  gl_Position.w = 1.;
  gl_PointSize =2.5;

  v_color.xyz = hsv2rgb(vec3(time + scr.x * 0.1,1,1));

}