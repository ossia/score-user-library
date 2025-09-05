/*{
  "DESCRIPTION": "FiboSound2D_2 - Try different mdoes: triangles, lines or points for different effect",
  "CREDIT": "hugo-w (ported from https://www.vertexshaderart.com/art/AXAuvTYrFKQwTgykw)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 3834,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1619546132490
    }
  }
}*/

#define PI radians(180.)
#define PHI_A (3.-sqrt(5.))* PI

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float phi = ((sin(0.08*time)*0.5+0.5)*3./resolution.x-sqrt(5.))* PI;
  float scale = 0.35; // repeats/extends
  float size = 0.001; // stretch/squeeze
  float rad_max = (vertexCount * size);

  float theta = phi * vertexId;// * PHI_A * vertexId;
  //float snd = texture(sound, vec2(cos(theta)/2.+.5, abs(sin(theta))*0.25));
  float snd = texture(sound, vec2(fract(theta / 35.0), fract(theta / 80000.0))).r;
  float radius = sqrt(vertexId * size) + snd*0.1;

  radius = radius * scale;

  float xoff = sin(time*0.8) * 0.8;
  float yoff = sin(time*1.3) * 0.1;
  gl_Position = vec4(cos(theta) * radius,
        sin(theta) * radius,
        0, 1);
  float soff = pow(snd + 0.2, 8.);
  gl_PointSize = (soff + 2.) * sqrt(pow(resolution.x, 2.) + pow(resolution.y, 2.)) / 600.;

  float hue = snd*0.01 + time * 0.1;
  v_color = vec4(hsv2rgb(vec3(radius + hue, 1,
        1. // change step to 0. (all pass) for no blackening
        )), pow(snd, 5.));
}