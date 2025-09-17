/*{
  "DESCRIPTION": "otbs",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/uDBqerAHTiHEjQMdR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 975,
    "ORIGINAL_LIKES": 6,
    "ORIGINAL_DATE": {
      "$date": 1545822688245
    }
  }
}*/

/*

 _____, ____, ___, ___, __ _,
(-| | | (-|_, (-|_) (-|_) (-\ |
 _| | |_, _|__, _| \_, _| \_, \|
( ( ( ( (__/
   ____ __ _, ___, ____, ____ ____, _____, ___, ____
  (-/ ` (-|__| (-|_) (-| (-(__`(-| (-| | | (-|_\_,(-(__`
    \___, _| |_, _| \_, _|__, ____) _| _| | |_, _| ) ____)
        ( ( ( ( ( ( ( (

*/

#define PI radians(180.0)

void main() {
  float t = vertexId / vertexCount + fract(time * 8.) * -0.0025;
  float sideId = mod(vertexId, 2.);
  float twist = vertexCount / 200.0;

  t = cos(t * PI * .5);

  float m = t * PI * twist + sideId * PI;
  float r = t * .75;

  m += mod(time / vertexCount, 1.);

  float x = r * cos(m);
  float z = r * sin(m);

  float aspect = resolution.x / resolution.y;
  gl_Position = vec4(
      vec3(
        x / aspect,
        t * -2. + 1.,
        z) * 0.8,
      1);
  gl_PointSize = 3.0;
  v_color.rgb = mix(vec3(1,0,0), vec3(0,1,1), sideId);
  v_color.a = mix(.5, 1., sin(m) * .5 * .5);
  v_color.a = mix(.2, 1., step(0., -sin(m)));
  v_color.rgb *= v_color.a;
}
