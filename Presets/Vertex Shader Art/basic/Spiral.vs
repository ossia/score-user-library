/*{
  "DESCRIPTION": "Spiral",
  "CREDIT": "Axesider (ported from https://www.vertexshaderart.com/art/9wKMAeACxZ3WoJc2m)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 16384,
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
    "ORIGINAL_VIEWS": 987,
    "ORIGINAL_LIKES": 7,
    "ORIGINAL_DATE": {
      "$date": 1446565774993
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
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  float t = (vertexId*2.0+mod(vertexId,2.0))*0.01;
  float phase = -time+mod(vertexId,2.0);
  float a = 0.5;
  float b = 0.3063489;
  float x = a * exp(b*t)*cos(t+phase)*0.015;
  float y = a * exp(b*t)*sin(t+phase)*0.015;
  vec2 xy = vec2(x, y);
  gl_Position = vec4(xy * aspect, 0, 1);

  float hue = floor(time*0.0) / 0.23;
  float sat = 1.;
  float val = 0.5+mod(vertexId,2.0)*0.5;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}