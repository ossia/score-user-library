/*{
  "DESCRIPTION": "The power of bugs",
  "CREDIT": "illus0r (ported from https://www.vertexshaderart.com/art/cCmnbDXAePT5wsvRQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 82644,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 20,
    "ORIGINAL_DATE": {
      "$date": 1626892102364
    }
  }
}*/

#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))
#define rnd(x) fract(54321.987 * sin(987.12345 * mod(x,89.134)))
#define f(x) (pow(x,x+sin(time)))

vec3 hsv(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float n = 6.;
  float radius = mouse.x*.5;
  vec2 point = vec2(rnd(vertexId+time),rnd(vertexId-time));
  v_color = vec4(point, 1 ,1);
  point=point*2.-1.;
  for(float i = 0.; i<3.; i++){
    float angle = floor(rnd(vertexId)*n)/n*6.2831;
    vec2 target = vec2(0.,radius)*rot(angle);
    vec2 dir = normalize(target-point);
    vec2 move = dir*f(length(point));
    point += move;
  }
  gl_Position = vec4(point, 0, 1);
  gl_PointSize=1.;
}