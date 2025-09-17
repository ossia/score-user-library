/*{
  "DESCRIPTION": "Spiral",
  "CREDIT": "molotovbliss (ported from https://www.vertexshaderart.com/art/DYWEJu3J6uupTuopS)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 6240,
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
      "$date": 1658416426956
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  gl_PointSize = 12.;
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  float t = (vertexId*2.0+mod(vertexId,3.0))*0.01;
  float phase = -time+mod(vertexId,2.0);
  float a = .5;
  float b = .0434;
  float x = a * exp(b*t)*cos(t+phase)*0.15;
  float y = a * exp(b*t)*sin(t+phase)*0.035;
  vec2 xy = vec2(x, y);
  gl_Position = vec4(xy * aspect, 0, 1);

  float hue = mod(.1, .4);
  float sat = 0.;
  float val = 1.3+mod(vertexId, .1);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}