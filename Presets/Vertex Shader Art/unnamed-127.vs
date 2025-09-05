/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "gitanely (ported from https://www.vertexshaderart.com/art/dWK8BJdJy3MCus377)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10151,
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1569573403472
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
  vec4 pos = gl_Position;

  pos.x = -1. + scr.x;
  pos.y = sin(vertexId + time) * pos.x;
  pos.y = pow(pos.x,pos.y) - 1.;
  pos.z = 0.;

  pos.x += -.5;
  gl_Position = pos;
  gl_Position.w = 1.;
  gl_PointSize =2.5;

  v_color.xyz = hsv2rgb(vec3(time + scr.x * 0.1,1,1));

}