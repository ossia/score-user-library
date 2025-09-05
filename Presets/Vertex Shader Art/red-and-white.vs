/*{
  "DESCRIPTION": "red-and-white",
  "CREDIT": "liaminjapan (ported from https://www.vertexshaderart.com/art/KCb2cGRMiF3zp2P9E)",
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
    0.47843137254901963,
    0.03137254901960784,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 47,
    "ORIGINAL_DATE": {
      "$date": 1512100837188
    }
  }
}*/

vec3 hsv2rgb(vec3 c)
{
  c = vec3(c.x, clamp(c.yz, .0, 1.));
  vec4 K = vec4(1., 2. / 3., 1. / 3., 3.);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6. - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, .0, 1.), c.y);

}

#define PI radians(180.0)

mat4 rotZ(float angleInRadians)
{
  float s = sin(angleInRadians);
  float c = cos(angleInRadians);

  return mat4(
    c, -s, 0,0,
    s, c, 0,0,
    0,0,1,0,
    0,0,0,1);
}

mat4 trans(vec3 trans)
{
  return mat4(
    1,0,0,0,
    0,1,0,0,
    0,0,1,0,
    trans, 1);
}

mat4 ident()
{
  return mat4(
    1,0,0,0,
    0,1,0,0,
    0,0,1,0,
    0,0,0,1);
}

mat4 scale(vec3 s)
{
  return mat4(
    s[0], 0,0,0,
    0,s[1],0,0,
    0,0,s[2],0,
    0,0,0,1);
}

mat4 uniformScale(float s)
{
  return mat4(
    s,0,0,0,
    0,s,0,0,
    0,0,s,0,
    0,0,0,1);
}

vec2 getCirclePoint(float id, float numCircleSegments)
{
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);

  float angle = ux /numCircleSegments * PI * 2.;
  float c = cos(angle);
  float s = sin(angle);

  float radius = vy;

  float x = c * radius;
  float y = s * radius;

  return vec2(x,y);
}

void main()
{
  float numCircleSegments = 64.;
  vec2 circleXY = getCirclePoint(vertexId, numCircleSegments);

  float numPointsPerCircle = numCircleSegments * 6.;
  float circleId = floor(vertexId / numPointsPerCircle);
  float numCircles = floor(vertexCount / numPointsPerCircle);

  float down = floor(sqrt(numCircles));
  float across = floor(numCircles / down);

  float x = mod(circleId, across);
  float y = floor(circleId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = 0.;//sin(time + y * .2) * .1;
  float yoff = 0.;//sin(time + x * .3) * .2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  float su = abs(u - .5) * 2.;
  float sv = abs(v - .5) * 2.;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au * 0.05, av * 0.25)).r;

  float aspect = resolution.x / resolution.y;
  float sc = pow(snd + 0.2, 5.);

  vec4 pos = vec4(circleXY, 0, 1);
  mat4 mat = ident();
  mat *= scale(vec3(1,aspect,1));
  mat *= trans(vec3(ux, vy, 0));
  mat *= uniformScale(0.025 * sc);

  gl_Position = mat * pos;

  float soff = 0.;//sin(time + x * y * .02) * 5.;

  float pump = step(0.8, snd);
  //float hue = u * .1 + snd *.2 + time * .1;//sin(time + v * 20.) * .05;
  //float sat = mix(0., 1., pump);
  //float val = mix(.1, pow(snd + .2, 5.), pump);//pow(snd + .2, 5.);//sin(time + v * u * 20.0) * .5 + .5;

  //v_color = vec4(hsv2rgb(vec3(hue,sat,val)),1);
  v_color = vec4(1,1,1,1);
}
