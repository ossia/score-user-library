/*{
  "DESCRIPTION": "slowmess",
  "CREDIT": "daniel (ported from https://www.vertexshaderart.com/art/mc9ScBATcEnpry3q2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10000,
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
    "ORIGINAL_VIEWS": 203,
    "ORIGINAL_DATE": {
      "$date": 1527181897722
    }
  }
}*/


void main()
{

  float ux = floor(vertexId / 6.0) + mod(vertexId, 2.0);
  float vy = mod(floor(vertexId / 2.0) + floor (vertexId / 3.0), 3.0);

  float angle = ux / 50. * radians(180.0) * 2.0;
  float radius = vy + 1.0;

  float x = radius * cos(0.2 * sin(0.015 * time) * angle);
  float y = radius * sin(0.2 * sin(0.01 * time) * angle);

  vec2 xy = vec2(x,y);
  float snd = texture(sound, 0.5 * xy).r;
  gl_Position= vec4(snd * xy * 0.2,0, 0.1 * sin(time) + 0.5);
  v_color = vec4((sin(0.5 * time)), (sin(time) + 0.5), (sin(cos(0.2 * time)) + 2.) / 2., 1);
}