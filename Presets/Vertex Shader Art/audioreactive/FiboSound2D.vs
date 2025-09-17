/*{
  "DESCRIPTION": "FiboSound2D - Try different mdoes: triangles, lines or points for different effect",
  "CREDIT": "hugo-w (ported from https://www.vertexshaderart.com/art/9GqsA2ooryruyLSRG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 2048,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1619545027078
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
  float scale = .5; // repeats/extends
  float size = 0.001; // stretch/squeeze
  float rad_max = (vertexCount * size);

  float theta = PHI_A * vertexId;// * PHI_A;
  //float snd = texture(sound, vec2(cos(theta)/2.+.5, abs(sin(theta))*0.25));
  float snd = texture(sound, vec2(fract(theta / 128.0), fract(theta / 20000.0))).r;
  float radius = sqrt(vertexId * size) + snd;

  radius = radius * scale;

  float xoff = sin(time*0.8) * 0.8;
  float yoff = sin(time*1.3) * 0.1;
  gl_Position = vec4(cos(theta) * radius,
        sin(theta) * radius,
        0, 1);
  gl_PointSize = 5. * sqrt(pow(resolution.x, 2.) + pow(resolution.y, 2.)) / 600.;

  float hue = snd*0.01 + time * 0.1;
  v_color = vec4(hsv2rgb(vec3(radius + hue, 1,
        mix(1., 0., step(snd, 0.8))
        )), 1);
}