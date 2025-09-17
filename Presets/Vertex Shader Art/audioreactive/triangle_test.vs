/*{
  "DESCRIPTION": "triangle test",
  "CREDIT": "trevor (ported from https://www.vertexshaderart.com/art/p3XWczEaFrc4XJCKu)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1502265183847
    }
  }
}*/

#define PI radians(180.)
#define TAU radians(360.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {

  float pointsPerLoop = 30.;
  float deg = radians(vertexId / pointsPerLoop * 180. + vertexId * 0.1925 + (time * 20.));
  float sx = mod(vertexId,pointsPerLoop) / pointsPerLoop;
  float sy = floor(vertexId / pointsPerLoop) / floor(vertexCount / pointsPerLoop);
  float snd = texture(sound,vec2(sx*0.125,sy)).r;
  float radius = (1.85 + pow(snd,2.)*2.) * (1.-sy);

  float x = sin(radius);
  float y = cos(deg) * radius;
  float z = vertexId * 0.125;
  vec3 pos = vec3(x,y,z);

  float aspect = resolution.y / resolution.x;

  mat4 camera = mat4(
    aspect, 1., 0, -0.5,
        -1, 1., 0., 0,
        0, 0.1, 0.1, 0.1,
        4., 2., -1, 0.1);

  gl_Position = camera * vec4(pos.x-4.5,pos.y-2.,pos.z,1.);
  float hue = (time * 0.01 + radius * 1.001);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
  //v_color = vec4(1., (vertexId/vertexCount) / 2. + .5, 1., 1. );

}