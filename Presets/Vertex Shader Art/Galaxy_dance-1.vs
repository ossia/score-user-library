/*{
  "DESCRIPTION": "Galaxy dance",
  "CREDIT": "gearcode (ported from https://www.vertexshaderart.com/art/huDQEAMcWYoP6hWGS)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Nature"
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
    "ORIGINAL_VIEWS": 972,
    "ORIGINAL_LIKES": 7,
    "ORIGINAL_DATE": {
      "$date": 1498743349644
    }
  }
}*/

#define PI 3.141

float dis(float n)
{
  return fract(sin(n)*1.50);
}

void main ()
{
  float Id = dis(vertexId);
  float fr = dis(Id);
  float tex = texture(sound, vec2(fr, Id)).r * cos(Id);

  tex = pow(tex, 2.);

  float pang = vertexId;
  float view = .5 * 1.2;
  float t = (time * (fr + .1))*10.;
  float x = Id * sin(pang + t);
  float y = Id * cos(pang + t);

  y += .25 * tex * (1. - y);
  y *= .78;

  float sizeAfter = tex / (y + 1.);

  gl_Position = vec4(x, y, 0., 1.);
  gl_PointSize = 6. * sizeAfter;

  v_color = vec4(tex * .1 * (3. - fr), tex * .9 * cos(fr * PI), tex * 9., sizeAfter);

}