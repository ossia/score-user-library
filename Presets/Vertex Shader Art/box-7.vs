/*{
  "DESCRIPTION": "box",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/gWF8YEaiS44osT2K7)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 843,
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
    "ORIGINAL_VIEWS": 53,
    "ORIGINAL_DATE": {
      "$date": 1670784276195
    }
  }
}*/

float h(float p)
{
    return fract(fract(p * 7.3983) * fract(p * .4427) * 95.4337);
}

vec2 r(vec2 p, float a)
{
    return vec2(-1, 1) * p.yx * sin(a) + p.xy * cos(a);
}

void main()
{
    float t = time;
    float o = resolution.x / resolution.y;
    float s = vertexId + t;

    vec3 b = abs((fract(vec3(.95, .5, .125) * t) - .5) * 2.);
    vec3 u = 1. - step(.5, b) * 2.;
    vec3 a = (pow(vec3(2.), (40. * b - 20.) * u) * u - u + 1.) * .5;

    vec3 p = vec3(h(s), h(s * .731), h(s * .719)) * 1. - 1.;
    vec3 d = 1. - step(vec3(1, 2, 3), vec3(h(s * 0.911) * 3.));
    vec3 v = d - vec3(0, d.xy);

    p = mix(step(0., p) * 2. - 1., p, mix(1. - v, v, a.y));
    p *= mix(1. / length(p), 1., dot(a, p) * a.z - sin(t * .2) * 2. * (a.x + .5));
    p.xy = r(p.xy, t * .2 + a.x * .2);
    p.xz = r(p.xz, t * .3 + a.y);

    v_color = vec4(a * .8 + .2, 1.);
    gl_Position = vec4(p.x, p.y * o, p.z, p.z + 5.);
    gl_PointSize = 2.;
}