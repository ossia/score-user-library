/*{
  "DESCRIPTION": "cccc",
  "CREDIT": "vtastek (ported from https://www.vertexshaderart.com/art/9CuFBCB2ddb7NzNRQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 24571,
  "PRIMITIVE_MODE": "TRIANGLES",
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
      "$date": 1642797848795
    }
  }
}*/

const mat4 ModelViewProjection = mat4(
  0.974278, 0.000000, 0.000000, 0.000000,
  0.000000, 1.326827, -0.643173, -0.642787,
  0.000000, 1.113340, 0.766504, 0.766044,
-14.614178, -9.836445, 23.760851, 24.346418
);

vec3 BezierCurve (vec3 a, vec3 b, vec3 c, vec3 d, float t)
{
  float x = a.x * (1.0 - t) * (1.0 - t) * (1.0 - t) + 3.0 * b.x * t * (1.0 - t) * (1.0 - t) + 3.0 * c.x * t * t * (1.0 - t) + d.x * t * t * t;
  float y = a.y * (1.0 - t) * (1.0 - t) * (1.0 - t) + 3.0 * b.y * t * (1.0 - t) * (1.0 - t) + 3.0 * c.y * t * t * (1.0 - t) + d.y * t * t * t;
  float z = a.z * (1.0 - t) * (1.0 - t) * (1.0 - t) + 3.0 * b.z * t * (1.0 - t) * (1.0 - t) + 3.0 * c.z * t * t * (1.0 - t) + d.z * t * t * t;
  return vec3 (x, y, z);
}

vec3 BezierPatch (float u, float v)
{
  vec3 a = BezierCurve (vec3(00.0, 00.0, 00.0), vec3(10.0, 00.0, 00.0), vec3(20.0, 00.0, 00.0), vec3(30.0, 00.0, 00.0), u);
  vec3 b = BezierCurve (vec3(00.0, 00.0, 10.0), vec3(10.0, 30.0 * cos(time * 0.5), 10.0), vec3(20.0, 40.0 * cos(time * 0.6), 10.0), vec3(30.0, 00.0, 10.0), u);
  vec3 c = BezierCurve (vec3(00.0, 00.0, 20.0), vec3(10.0, 30.0 * sin(time * 0.9), 20.0), vec3(20.0, 20.0 * sin(time * 0.7), 20.0), vec3(30.0, 00.0, 20.0), u);
  vec3 d = BezierCurve (vec3(00.0, 00.0, 30.0), vec3(10.0, 00.0, 30.0), vec3(20.0, 00.0, 30.0), vec3(30.0, 00.0, 30.0), u);
  return BezierCurve(a, b, c, d, v);
}

vec3 BezierPatchNormal (float u, float v)
{
  vec3 a = BezierCurve (vec3(00.0, 00.0, 00.0), vec3(10.0, 00.0, 00.0), vec3(20.0, 00.0, 00.0), vec3(30.0, 00.0, 00.0), u);
  vec3 b = BezierCurve (vec3(00.0, 00.0, 10.0), vec3(10.0, 30.0 * cos(time * 0.5), 10.0), vec3(20.0, 40.0 * cos(time * 0.6), 10.0), vec3(30.0, 00.0, 10.0), u);
  vec3 c = BezierCurve (vec3(00.0, 00.0, 20.0), vec3(10.0, 30.0 * sin(time * 0.9), 20.0), vec3(20.0, 20.0 * sin(time * 0.7), 20.0), vec3(30.0, 00.0, 20.0), u);
  vec3 d = BezierCurve (vec3(00.0, 00.0, 30.0), vec3(10.0, 00.0, 30.0), vec3(20.0, 00.0, 30.0), vec3(30.0, 00.0, 30.0), u);
  vec3 dv = -3.0 * (1.0 - v) * (1.0 - v) * a + (3.0 * (1.0 - v) * (1.0 - v) - 6.0 * v * (1.0 - v)) * b + (6.0 * v * (1.0 - v) - 3.0 * v * v) * c + 3.0 * v * v * d;
  vec3 e = BezierCurve (vec3(00.0, 00.0, 00.0), vec3(00.0, 00.0, 10.0), vec3(00.0, 00.0, 20.0), vec3(00.0, 00.0, 30.0), v);
  vec3 f = BezierCurve (vec3(10.0, 00.0, 00.0), vec3(10.0, 30.0 * cos(time * 0.5), 10.0), vec3(10.0, 30.0 * sin(time * 0.9), 20.0), vec3(10.0, 00.0, 30.0), v);
  vec3 g = BezierCurve (vec3(20.0, 00.0, 00.0), vec3(20.0, 40.0 * cos(time * 0.6), 10.0), vec3(20.0, 20.0 * sin(time * 0.7), 20.0), vec3(20.0, 00.0, 30.0), v);
  vec3 h = BezierCurve (vec3(30.0, 00.0, 00.0), vec3(30.0, 00.0, 10.0), vec3(30.0, 00.0, 20.0), vec3(30.0, 00.0, 30.0), v);
  vec3 du = -3.0 * (1.0 - u) * (1.0 - u) * e + (3.0 * (1.0 - u) * (1.0 - u) - 6.0 * u * (1.0 - u)) * f + (6.0 * u * (1.0 - u) - 3.0 * u * u) * g + 3.0 * u * u * h;
  return normalize(cross(dv, du));
}

vec3 hash(float p)
{
  vec3 p3 = fract(vec3(p) * vec3(.1031, .1030, .0973));
  p3 += dot(p3, p3.yzx+33.33);
  return fract((p3.xxy+p3.yzz)*p3.zyx);
}

void main()
{
  int tessellationFactor = 64; // vertex count = _TessellationFactor * _TessellationFactor * 6
  int instance = int(floor(vertexId / 6.0));
  float x = sign(mod(float(vertexId), 2.0));
  float y = sign(mod(126.0, mod(float(vertexId), 6.0) + 6.0));
  float u = (float(instance / tessellationFactor) + x) / float(tessellationFactor);
  float v = (mod(float(instance), float(tessellationFactor)) + y) / float(tessellationFactor);
  gl_Position = ModelViewProjection * vec4(BezierPatch(u,v) , 1);
  vec3 lightDir = normalize(vec3(10,10,-10));
  vec3 normalDir = BezierPatchNormal(u,v);
  float d = max(dot(lightDir, normalDir), 0.2);
  v_color = vec4(hash(float(instance + 123)), 1.0) * vec4(d, d, d, 1.0);
}