/*{
  "DESCRIPTION": "fov test - This demo is for experimenting with the FOV part of a perspective camera matrix.",
  "CREDIT": "sylistine (ported from https://www.vertexshaderart.com/art/J3bwBPducoTXfnDLs)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Effects"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1501614774135
    }
  }
}*/

#define PI radians(180.)

void main()
{
  float deg = vertexId + (time / 2.);
  vec3 pos = vec3(sin(deg), cos(deg), floor(vertexId / (PI * 2.)));

  // Applied a sin wave to the tex2d sample as a smoothing operation
  float fov = sin(radians(texture(sound, vec2(.4, 0)).r) * 2.) / 1.;

  mat4 camera = mat4(
    resolution.y / resolution.x, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, fov, fov,
    0, 0, 0, 1);

  gl_Position = camera * vec4(pos.xyz, 1);
  v_color = vec4(1, (vertexId / vertexCount) / 2. + 0.5, 1, 1);
}