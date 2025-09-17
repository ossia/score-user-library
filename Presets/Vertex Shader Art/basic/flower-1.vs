/*{
  "DESCRIPTION": "flower",
  "CREDIT": "yonatan (ported from https://www.vertexshaderart.com/art/NTmBiN65MW5gE5nBQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
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
    "ORIGINAL_VIEWS": 646,
    "ORIGINAL_LIKES": 5,
    "ORIGINAL_DATE": {
      "$date": 1537183968779
    }
  }
}*/

// 2D version at https://www.dwitter.net/d/9544:
// for(i=w=c.width=500;(i*=.9998)>w/2;x.fillRect(w/2+S(i+t)*q,j*300-C(i+t)*q,9,9))j=1-i/w,q=(2+S(i*5)**3)*j**4*w,x.fillStyle=R(a=j*600,a*2,a/2)

#define PI radians(180.)

vec2 rot(vec2 p, float a) {
  float s = sin(a);
  float c = cos(a);
  return vec2(p.x * s + p.y * c, p.y * s - p.x * c);
}

void main() {
  float v = sqrt(vertexId / vertexCount);
  float t = v + 1.5;
  float i = mod(t, 1.0) * 1000.0;
  float s = sin(i * 6.0);
  float q = (2.0 + s * s * s) * pow(t, 5.5) / 2000.0;

  vec2 aspect = vec2(1.0, resolution.x / resolution.y);
  vec3 p = vec3(
    sin(i) * q,
    cos(i) * q,
    (1.0-sqrt(v))
  );

  p = vec3(rot(p.xy, time), p.z);
  p = vec3(p.x, rot(p.zy, 3.5+cos(time)/3.));
  p.xy *= aspect;
  p.y += .3;
  gl_Position = vec4(p, 1);

  float a = min(255.0, pow(t, 2.6) * 25.0) / 255.0;
  v_color = vec4(a, a * 1.5, t * t * 15.0 / 255.0, 1.0);
  gl_PointSize = 3.0;
}
