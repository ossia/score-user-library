/*{
  "DESCRIPTION": "Rose Quartz",
  "CREDIT": "zugzwang404 (ported from https://www.vertexshaderart.com/art/PnfhNHTd9N2nBjoiw)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Abstract"
  ],
  "POINT_COUNT": 10971,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1503025342718
    }
  }
}*/


#define TAU radians(360.)
#define PI radians(180.)

void main()
{

  float pointsPerLoop = 30.;
  float deg = radians(vertexId / pointsPerLoop * 360. + vertexId * 1.625 + (time * 30.));
  float sx = mod(vertexId, pointsPerLoop /2.) / pointsPerLoop;
  float sy = floor(vertexId / pointsPerLoop) / floor(vertexCount / pointsPerLoop);
  float radius = (.85 + pow(texture(sound, vec2(sx * 0.0365, sy)).r, 4.) * 2.) * (1. - sy);

  float x = sin(deg) * radius * 1.9;
  float y = cos(deg) * radius * 1.9;
  float z = vertexId * sx * 0.0125;
  vec3 pos = vec3(x, y, z);

  float aspect = resolution.y / resolution.x;
  mat4 camera = mat4(
    aspect, 0.1*mouse.y, 1.-radius-mouse.y, 0,
    -0.3*radius, -1.1*mouse.x*radius, .1, 0,
    -0.06, 0.01, 0.31-mouse.y*0.1, 0.1,
    0, 0, -0.5, 1)/radius*2.;

  mix(gl_Position = camera * vec4(pos.xyz, 0.5),
  gl_Position = camera * vec4(1.-pos.xyz, 0.5), 0.5);
  v_color = vec4(.1, (vertexId / vertexCount *2.) / 2.5 * 2.1, 0.4, 0.1);
}
