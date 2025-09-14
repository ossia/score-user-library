/*{
  "DESCRIPTION": "Spiral-Spring",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/ixr3Pka4ChbtDzobh)",
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
  "INPUTS": [ { "LABEL": "Touch", "NAME": "touch", "TYPE": "image" }, { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 3892,
    "ORIGINAL_LIKES": 9,
    "ORIGINAL_DATE": {
      "$date": 1446571560918
    }
  }
}*/

//
//
// Move the mouse
//

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float tm = sin(time) * 20.;
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  float t = (vertexId*2.0+mod(vertexId,2.0))*0.01;
  float phase = -tm+mod(vertexId,2.0);
  float a = 0.5;
  float b = 0.3063489;
  float x = a * exp(b*t*0.2)*cos(t+phase)*0.015;
  float y = a * exp(b*t*0.2)*sin(t+phase)*0.015;
  vec4 m = texture(touch, vec2(0., vertexId * 0.00005));
  vec2 xy = vec2(x, y);
  gl_Position = vec4(xy * aspect + m.xy, 0, 1);

  float hue = (floor(vertexId * -.005) * 0.5 - time * 0.01);
  float sat = 1.;
  float val = 0.5+mod(vertexId,2.0)*0.5;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}