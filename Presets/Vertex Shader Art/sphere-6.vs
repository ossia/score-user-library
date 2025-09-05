/*{
  "DESCRIPTION": "sphere",
  "CREDIT": "anuar (ported from https://www.vertexshaderart.com/art/zddxPxkny7JNAE7jK)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
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
      "$date": 1518223995387
    }
  }
}*/

void main()
{
  float angleOffset = 5.0;
  float theta = radians(mod(vertexId * angleOffset, 180.0));
  float fi = radians(mod(floor(vertexId / (180.0 / angleOffset)) * angleOffset, 360.0));

  float x = sin(theta) * cos(fi);
  float y = sin(theta) * sin(fi);
  float z = cos(theta);

  vec3 pos = vec3(x, y, z) * (texture(sound, vec2(0.225, 0)).r);

  mat4 rotx = mat4(1.0);
  rotx[1][1] = cos(time);
  rotx[2][1] = -sin(time);
  rotx[1][2] = sin(time);
  rotx[2][2] = cos(time);

  mat4 rotz = mat4(1.0);
  rotz[0][0] = cos(time);
  rotz[1][0] = -sin(time);
  rotz[0][1] = sin(time);
  rotz[1][1] = cos(time);

  gl_Position = rotz * rotx * vec4(pos, 1.0);
  gl_PointSize = 2.0;
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
}