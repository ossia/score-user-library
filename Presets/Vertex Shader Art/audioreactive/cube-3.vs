/*{
  "DESCRIPTION": "cube",
  "CREDIT": "jorenvo (ported from https://www.vertexshaderart.com/art/kR26egNf7BwrsJHyM)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math"
  ],
  "POINT_COUNT": 46,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.011764705882352941,
    0.054901960784313725,
    0.24705882352941178,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1557779073661
    }
  }
}*/

// from https://www.laurivan.com/rgb-to-hsv-to-rgb-for-shaders/
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float norm_sin(float x) {
  return (sin(x) + 1.) / 2.;
}

float flip(float n) {
  return n > 0.5 ? 0. : 1.;
}

/*
  6----7
 /| /|
2----3 |
| 4 | 5
|/ |/
0----1

*/
// render with 8 * 6 vertices in LINES
#define V_PER_LINE 2.
#define V_PER_FACE 4.
#define V_PER_CORNER 6.
#define V_PER_CUBE 8.
#define AVG_SAMPLES 4
#define FREQ_BUCKETS 1
void main() {
  float vertex_id = floor(vertexId / V_PER_CORNER);
  float face_id = mod(vertex_id, V_PER_FACE);
  float corner_id = mod(vertex_id, V_PER_FACE);
  vec3 c = vec3(mod(vertex_id, V_PER_LINE),
        floor(corner_id / V_PER_LINE),
        1);

  float is_backface = floor(vertex_id / V_PER_FACE);
  if(mod(vertexId, 2.) != 0.) {
   float line_point = mod(vertexId, V_PER_CORNER);
    if (line_point >= 5.){
      c.x = flip(c.x);
    } else if (line_point >= 3.) {
      c.y = flip(c.y);
    } else if (line_point >= 1.) {
   is_backface = 1.;
    }
  }

  float yoffset = 0.;
  if(c.y == 10.0) { // bottom
    for(int i = 0; i < AVG_SAMPLES; i++) {
      float ampl = texture(sound, vec2(0, i)).r;
      yoffset += ampl;// > .90 ? ampl : ampl * .95;
    }

   yoffset /= float(AVG_SAMPLES);
   float m = 100.;
   c.y -= pow(yoffset * m, 4.) / pow(m, 4.) * 125.;
  }

  yoffset = 0.;
  if(c.y == 1.0) { // top
    for(int i = 0; i < AVG_SAMPLES; i++) {
      float ampl = texture(sound, vec2(i, 50)).r;
      yoffset += ampl;
    }

   yoffset /= float(AVG_SAMPLES);
   float m = 100.;
   c.y += pow(yoffset * m, 4.) / pow(m, 4.) * 125.;
  }

  float face_offset = .35 * is_backface;
  c += face_offset;

  // go from [0,1] -> [0,2]
  c *= 2.0;

  // go from [0,2] -> [-1, 1]
  c -= 1.0;

  c *= .2;

  gl_Position = vec4(c, 1);

  gl_PointSize = 5.;
  v_color = vec4(hsv2rgb(vec3(1, 1, 1)), 1);
}