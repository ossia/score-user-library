/*{
  "DESCRIPTION": "Rose Quartz",
  "CREDIT": "sylistine (ported from https://www.vertexshaderart.com/art/ZZj9dLPDqjWny5kJW)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Abstract"
  ],
  "POINT_COUNT": 13879,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    0.26666666666666666,
    0.4117647058823529,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 177,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1501925528057
    }
  }
}*/

#define PI radians(180.)
#define TAU radians(360.)

void main()
{

  float pointsPerLoop = 30.;
  float deg = radians(vertexId / pointsPerLoop * 360. + vertexId * 0.0625 + (time * 20.));
  float sx = mod(vertexId, pointsPerLoop) / pointsPerLoop;
  float sy = floor(vertexId / pointsPerLoop) / floor(vertexCount / pointsPerLoop);
  float radius = (1.85 + pow(texture(sound, vec2(sx * 0.125, sy)).r, 2.) * 2.) * (1. - sy);

  float x = sin(deg) * radius;
  float y = cos(deg) * radius;
  float z = vertexId * 0.125;
  vec3 pos = vec3(x, y, z);

  float aspect = resolution.y / resolution.x;
  mat4 camera = mat4(
    aspect, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 0.1, 0.1,
    0, 0, 0, 1);

  gl_Position = camera * vec4(pos.xyz, 1);
  v_color = vec4(1, (vertexId / vertexCount) / 2. + 0.5, 1, 1);
}