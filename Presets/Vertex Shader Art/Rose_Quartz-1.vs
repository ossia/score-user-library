/*{
  "DESCRIPTION": "Rose Quartz - learning from https://www.vertexshaderart.com/art/ZZj9dLPDqjWny5kJW",
  "CREDIT": "bluesky (ported from https://www.vertexshaderart.com/art/EJEPgF3KWdF9Bysia)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 4617,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.19215686274509805,
    0.12941176470588237,
    0.1411764705882353,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1624729787424
    }
  }
}*/

#define PI radians(180.)
#define TAU radians(360.)

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main()
{

  float pointsPerLoop = 30.;
  float deg = radians(vertexId / pointsPerLoop * 360. + vertexId * 0.0625 + (time * 20.));
  float sx = mod(vertexId, pointsPerLoop) / pointsPerLoop;
  float sy = floor(vertexId / pointsPerLoop) / floor(vertexCount / pointsPerLoop);
  float radius = (1.85 + pow(texture(sound, vec2(sx * 0.125, sy)).r, 2.) * 2.) * (1. - sy);

  radius *= rand(vec2(sx, sy)) * cos(time* sy);

  float x = cos(deg) * radius;
  float y = sin(deg) * radius;
  float z = vertexId * 0.01;
  vec3 pos = vec3(x, y, z);

  float aspect = resolution.y / resolution.x;
  mat4 camera = mat4(
    aspect, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 0., 0.1,
    0, 0, 0, 1);

  gl_Position = camera * vec4(pos.xyz, 1);
  v_color = vec4(1, (vertexId / vertexCount) / 2. + 0.5, 1, 1);
}