/*{
  "DESCRIPTION": "Hyperbolic grid",
  "CREDIT": "antoine (ported from https://www.vertexshaderart.com/art/dzCu7QoEjYiNTWqFD)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
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
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1491226764896
    }
  }
}*/

vec3 ToPolar(vec3 uv, float K, float percent) {
  float R = sqrt(dot(uv,uv)) + K;
  R = mix(1.0, R, percent);
  return vec3(uv / R);
}

vec2 ToCartesian(vec2 uv, float K) {
  return vec2(uv.x / sqrt(uv.x*uv.x + K*K), uv.y / sqrt(uv.y*uv.y + K*K));
}

void main() {
  float planecount = floor(vertexId / 10000.0);
  float restplane = mod(vertexId, 10000.0);
  vec3 point = (vec3(floor(restplane / 100.0) , mod(restplane, 100.0), planecount*5.0) - 50.0) * 0.035;

  vec2 aspect = vec2(1, resolution.x / resolution.y);

  float K = 0.5;
  float percent = sin(time * 1.0) * 0.5 + 0.5;

  vec3 xyz = ToPolar(point, K, percent);
  vec2 xy = xyz.xy;// / xyz.z;
  //gl_Position = vec4(xy * aspect + mouse * 0.5, 0, 1);
  gl_Position = vec4(xy * aspect + mouse * 0.5, xyz.z, 1.0);
  gl_PointSize = 4.0;

  v_color = vec4(abs(sin(xy*10.0)),abs(point.z*0.5), 1.0);
}
