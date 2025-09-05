/*{
  "DESCRIPTION": "etch a sketch",
  "CREDIT": "chriscamplin (ported from https://www.vertexshaderart.com/art/Xf8ywY5kqr6qLRr2F)",
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
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 58,
    "ORIGINAL_DATE": {
      "$date": 1676920361059
    }
  }
}*/


struct point {
  vec3 position;
  float a;
  float b;
  float rad;
  float snd;
};

mat4 rotX(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0, -s, c, 0,
      0, 0, 0, 1);
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

mat4 rotZ(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1);
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
}

void main() {
  float numPointsPerCircle = 3.;
  float circleId = floor(vertexId / numPointsPerCircle);
  float numCircles = floor(vertexCount / numPointsPerCircle);

  float sliceId = floor(vertexId / 6.0);
  float oddSlice = mod(sliceId, 2.0); // ) if it's even, one if it's odd
  float cols = floor(sqrt(numCircles));
  float rows = floor(numCircles / cols);
  // vertex ID is number of the vertex
  float x = mod(circleId, rows); // divide by 10 keep the remainder,
  float y = floor(circleId / rows); //. floor throws away the remainder 0000 1111 2222

  float snd = pow(texture(sound, vec2(0.00025, 0.00025)).r, 20.);

  float v=vertexId/10.0;
  int num=int(mouse.x*15.0+15.0+snd);
  int den=int(exp(mouse.y*5.0+5.0*snd)+snd);
  float frac=1.0-float(num)/float(den);
  vec3 xyz=vec3(sin(v),cos(v)*sin(v*frac), cos(v))*2.0;

  for(int i = 0; i < 1; i++) {
    xyz*=abs(xyz)/dot(xyz, xyz)-vec3(snd);
    //xyz*=abs(xyz)/dot(xyz, xyz)-vec3(snd);
  }
  vec3 aspect = vec3(1, resolution.x / resolution.y, 1);
   vec4 pos = vec4(xyz * aspect, 1);
   mat4 mat = ident();
   //mat *= scale(vec3(1, aspect, 1));
    mat *= rotX(time);
    mat *= rotY(radians(-45.)*time*.5);
   mat *= rotZ(time);
  gl_Position = pos*mat;

    vec4 color = vec4(1,1,snd, 1);

   vec4 finalColor = mix(color, background, snd);
  v_color = finalColor;
}