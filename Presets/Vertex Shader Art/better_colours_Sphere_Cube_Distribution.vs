/*{
  "DESCRIPTION": "<better colours> Sphere + Cube Distribution",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/88XwsAMToJSkDiwaB)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10042,
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
    "ORIGINAL_VIEWS": 385,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1568547009230
    }
  }
}*/

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

float anim(float t) {
  float st = sin(t);
  return (sign(st)*( 1.0-pow(1.0-abs(st), 5.0) ))*0.5+0.5;
}

vec3 SampleSpherePos(float idx, float num) {
  idx += 0.5;
  float phi = 10.166407384630519631619018026484 * idx;
  float th_cs = 1.0 - 2.0*idx/num;
  float th_sn = sqrt(clamp(1.0 - th_cs*th_cs, 0.0, 1.0));
  return vec3( cos(phi)*th_sn, sin(phi)*th_sn, th_cs );
}

vec3 SampleCubePos(float idx, float num) {
  float side = floor(pow(num, 1.0/3.0)+0.5);
  vec3 res;
  res.x = mod(idx, side);
  res.y = floor( mod(idx, side*side)/side );
  res.z = floor( mod(idx, side*side*side)/side/side );
  res -= vec3(side * 0.5);
  res *= 1.5/side;
  return res;
}

void main() {
  vec3 samplePos = mix(SampleCubePos(vertexId, vertexCount), SampleSpherePos(vertexId, vertexCount), anim(time));

  vec4 vertPos = rotY(time*0.1) * vec4(samplePos, 1.0) + vec4(0,0,-3.0,0);

  gl_Position = persp(PI*0.25, resolution.x/resolution.y, 0.1, 100.0) * vertPos;
  gl_PointSize = sin(time*4.+20.*samplePos.x*samplePos.y*samplePos.z)*4.+4.;

  v_color = vec4(samplePos.y*samplePos.y + 0.5,samplePos.x*samplePos.x + 0.5,samplePos.z*samplePos.z + 0.5,1);
}