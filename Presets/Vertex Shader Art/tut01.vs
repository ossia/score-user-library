/*{
  "DESCRIPTION": "tut01 - read sections of texture frequencies?",
  "CREDIT": "soporus (ported from https://www.vertexshaderart.com/art/imESwJiuP9QDzXiWF)",
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
    "ORIGINAL_VIEWS": 39,
    "ORIGINAL_DATE": {
      "$date": 1586825436197
    }
  }
}*/

#define PI radians(180.0)
vec3 hsv2rgb(vec3 c){
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
        sin(_angle),cos(_angle));
}

mat2 scaler(vec2 _scale){
    return mat2(_scale.x,0.0,
        0.0,_scale.y);
}

vec2 getCirclePoint(float id, float numCircleSegments){
  float ux = floor(id /6.0) + mod(id, 2.0);
  //odd and even vertexes
  float vy = mod(floor(id / 2.0) + floor(id / 3.0), 2.0);

  float angle = ux/numCircleSegments * PI * 2.0;
  float c = cos(angle);
  float s = sin(angle);
  float radius = vy + 1.0;

  float x = c * radius;
  float y = s * radius;

  return vec2(x, y);

}

void main() {
  float numCircleSegments = 5.0;
  vec2 circleXY = getCirclePoint(vertexId, numCircleSegments);

  float numPointsPerCircle = numCircleSegments * 6.0;
  float circleId = floor(vertexId / numPointsPerCircle);
  float numCircles = floor(vertexCount / numPointsPerCircle);

  float down = floor(sqrt(numCircles));
  float across = floor(numCircles/down);

  float x = mod(circleId, across);
  float y = floor(circleId/ across);

  float u = x / (across-1.0);
  float v = y / (across-1.0);

  float xoff = sin(time + y * 0.2) * 0.025;
  float yoff = cos(time + x * 0.3) * 0.025;

  float ux = u * 2.0 -1.0 + xoff;
  float vy = v * 2.0 -1.0 + yoff;

  float su = abs(u - 0.5) * 2.0;
  float sv = abs(v - 0.5) * 2.0;

  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));

  float snd = texture(sound, vec2(au * 0.05, av * 0.25)).r;

  float aspect = resolution.x / resolution.y;
  float scale = pow(snd + 0.2, 3.0);
  vec2 xy = circleXY * 0.05 *scale + vec2(ux, vy);

  xy *= rotate2d(sin(time*0.1)*PI);
  xy *= scaler(vec2(1.33333));
  gl_Position = vec4(xy,0,1) * vec4(1, aspect, 1, 1);

  float pump = step(0.75, snd);
  float hue = u*0.1*snd+0.5;
  float sat = step(0.666,snd);
  float val = mix(snd*0.25+0.125,snd,pump);

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}