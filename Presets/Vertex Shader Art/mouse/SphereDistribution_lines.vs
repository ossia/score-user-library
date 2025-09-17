/*{
  "DESCRIPTION": "SphereDistribution lines",
  "CREDIT": "ersh (ported from https://www.vertexshaderart.com/art/2FpAyYRgGQytFrcAM)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 16265,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 56,
    "ORIGINAL_DATE": {
      "$date": 1689316865040
    }
  }
}*/

//// RESET TIME!

// 1. or 2.
#define LINES 2.

#define PI radians(180.)

mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(PI * 0.5 - 0.5 * fov);
  float rangeInv = 1.0 / (zNear - zFar);

  return mat4(
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1,
    0, 0, zNear * zFar * rangeInv * 2., 0);
}

mat4 rotY(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

vec3 SampleSpherePos(float idx, float num) {
  idx += 0.5;
  //float phi = 10.166407384630519631619018026484 * idx;
  float phi = 2.399949895 * idx;
  float th_cs = 1.0 - 2.0*idx/num;
  float th_sn = sqrt(clamp(1.0 - th_cs*th_cs, 0.0, 1.0));
  return vec3( cos(phi)*th_sn, sin(phi)*th_sn, th_cs );
}

float gcd(in float a, in float b) {
  a = floor(a); b = floor(b);
  if (b < 1.) { return 1.; }
  for (int n = 0; n < 10; n++) {
    if (b < 0.0001) break;
    float bb = mod(a, b);
    a = b;
    b = bb;
  }
  return a;
}

float shuffle(float n, float count, float st) {
  float mult = st + gcd(count, st) / count;
  float nn = n * mult;
  return floor(mod(nn, count));
}

//float shuffles[] = float[](8., 13., 21., 34., 42., 47., 55., 68., 76., 84., 89., 97., 102., 144.);
float getShuf(float t) {
  t = mod(floor(t), 10.);
  return
    t < 1. ? 8. :
    t < 2. ? 13. :
    t < 3. ? 21. :
    t < 4. ? 34. :
    t < 5. ? 55. :
    t < 6. ? 89. :
    t < 7. ? 144. :
    t < 8. ? 233. :
    t < 9. ? 335. :
    t < 10. ? 568. :
    5.
    ;
}

void main() {
  float count = min(ceil(time*100.), vertexCount / LINES);
  if (vertexId / LINES >= count) { return; }
  float line_id = floor(vertexId / count);
  float id = shuffle(mod(vertexId, count), count, getShuf(time/(8.) + line_id));
  //float id = shuffle(vertexId, count, 568.);
  //float id = shuffle(vertexId, count, ceil(time));
  //float id = shuffle(vertexId, count, floor((mouse.x+1.)*100.));
  vec4 vertPos = rotY(time*0.1) * vec4(SampleSpherePos(id, count), 1.0) + vec4(0,0,-3.0,0);

  gl_Position = persp(PI*0.25, resolution.x/resolution.y, 0.1, 100.0) * vertPos;
  gl_PointSize = 3.0;

  v_color = vec4(1.3 + vertPos.z * 0.3);
}