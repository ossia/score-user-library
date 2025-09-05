/*{
  "DESCRIPTION": "fov test - This demo is for experimenting with the FOV part of a perspective camera matrix.",
  "CREDIT": "sylistine (ported from https://www.vertexshaderart.com/art/4LYwmawuudnFoyRng)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Effects"
  ],
  "POINT_COUNT": 2678,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 44,
    "ORIGINAL_DATE": {
      "$date": 1501896512092
    }
  }
}*/

#define PI radians(180.)
#define TAU radians(360.)

void main()
{
  float pointsPerLoop = 5.;
  float deg = radians(vertexId / pointsPerLoop * 360. + vertexId * TAU + (time * 20.));
  float z = vertexId * 0.25;
  float sx = (deg - floor(deg - TAU) * TAU) / TAU;
  float sy = z / (vertexCount * 0.5);
  float radius = 1. + pow(texture(sound, vec2(sx * 0.5, sy * 0.5)).r, 5.);
  vec3 pos = vec3(sin(deg) * radius, cos(deg) * radius, z);

  // Applied a sin wave to the tex2d sample as a smoothing operation
  //float fov = (sin(radians(texture(sound, vec2(sx * 0.5, 0)).r) * 90.) + 0.1) / 256.;

  mat4 camera = mat4(
    resolution.y / resolution.x, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 0.1, 0.1,
    0, 0, 0, 1);

  gl_Position = camera * vec4(pos.xyz, 1);
  v_color = vec4(1, (vertexId / vertexCount) / 2. + 0.5, 1, 1);
}