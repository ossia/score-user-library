/*{
  "DESCRIPTION": "Spiral-Spring dNCE1",
  "CREDIT": "zugzwang404 (ported from https://www.vertexshaderart.com/art/3Csyw9ecsH7rXLkok)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 47538,
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
    "ORIGINAL_VIEWS": 117,
    "ORIGINAL_DATE": {
      "$date": 1498817947099
    }
  }
}*/

//
//
// Move the mouse
//

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0* 7., 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 2.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 0.6), c.y);
}

void main() {
  float tm = cos(time) *20.;
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  float t = (vertexId* 0.9+mod(vertexId,2.0))*0.03;
  float phase = -tm*mod(vertexId,2.0);
  float a = 0.173;
  float b = 0.3063489;
  float x = a * exp(b+t*1.3)*cos(t+phase)*0.015;
  float y = a * exp(-b*1.3)*sin(t*phase)*0.015;
  vec4 m = texture(touch, vec2(0., vertexId * 0.005));
  vec2 xy = vec2(x, y);
  gl_Position = vec4(xy * aspect + m.xy, 0, 1);

  float hue = (floor(vertexId * -.5) * 0.5 - time * 0.01);
  float sat = 1.;
  float val = 0.5+mod(vertexId,2.0)*0.8;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 0);
}