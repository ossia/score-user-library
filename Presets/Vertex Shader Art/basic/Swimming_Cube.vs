/*{
  "DESCRIPTION": "Swimming Cube",
  "CREDIT": "aaron1924 (ported from https://www.vertexshaderart.com/art/fGCtwoQy8Mc8RK2pY)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 25000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1535281716982
    }
  }
}*/

#define TAU 6.28318530718

float box(vec3 p)
{
  p = abs(p);
  return max(p.x, max(p.y, p.z));
}

mat2 rot(float a)
{
  float s=sin(a), c=cos(a);
  return mat2(c,s,-s,c);
}

vec3 cube(float id, float count)
{
  id += time;
  vec3 m = vec3(0.73287, 0.91706, 0.29328);
  vec3 p = fract(m * id) - 0.5;
  p /= box(p);

  p.xz *= rot(time);
  p.yz *= rot(0.5 * time);

  return 0.3 * p;
}

vec3 scanline(float id, float count)
{
  float segs = 8.;
  float a = 0.5 * TAU * fract(floor(segs * id/count) / segs + 0.1 * time);
  float b = TAU * id/count * segs - time;

  vec3 p = vec3(sin(a) * cos(b), cos(a), sin(a) * sin(b));

  float off = fract(time+1.2345*vertexId);
  p.xy *= 1.0 + sin(a) * off;

  return p;
}

vec3 ambient(float id, float count)
{
  float w = sqrt(count);
  vec2 u = vec2(mod(id, w), floor(id / w)) / w;

  u.y = fract(u.y - 0.1 * time);
  u = 12. * (u - 0.5);

  vec3 p = vec3(u, 0.1 * cos(8. * u.x) + 0.1 * cos(3. * u.y));

  /*vec3 p = fract(8. * fract(vec3(67.502, 36.565, 66.536) * id) + id/count);
  p.y -= 0.1 * time;
  p = 8. * (fract(p) - 0.5);*/

  return p;
}

void main() {
  vec3 p = vec3(0);

  float count = vertexCount / 3.;

  if(3.*vertexId < vertexCount)p = scanline(vertexId, count);
  else if(3.*vertexId < 2. * vertexCount) p = cube(vertexId - count, count);
  else p = ambient(vertexId - 2. * count, count);

  p.z += 2.;

  vec2 uv = p.xy / p.z;
  uv.x *= resolution.y / resolution.x;

  gl_PointSize = 4. / p.z;
  gl_Position = vec4(uv, 0, 1);

  v_color = vec4(1);
}