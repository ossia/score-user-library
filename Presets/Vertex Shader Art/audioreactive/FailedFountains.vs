/*{
  "DESCRIPTION": "FailedFountains",
  "CREDIT": "8bitrick (ported from https://www.vertexshaderart.com/art/cgHCLAi7mKznjvENd)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1449289303183
    }
  }
}*/


#define PI 3.14159
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float m1p1(float v) { return v * 2. - 1.; }

void main()
{
  float ROWS = 5.;
  float cur_time = mod(time, 4.);
  float verts_per_row = vertexCount / ROWS;
  float vert_per = vertexId / (vertexCount - 1.);
  float row = floor(vertexId / verts_per_row);
  float row_per = row / (ROWS-1.);
  float freq = vert_per * 0.8 + 0.1;
  vec2 center = vec2(m1p1(hash(row_per)), m1p1(hash(hash(row_per))))* 0.5;

  float vertex_per = mod(vertexId, verts_per_row) / verts_per_row;
  float x = vertex_per;
  //float y = texture(sound,vec2(vertex_per*0.90+0.1,0.)).r;// + (row_per) - 1. + hash(row_per);
  float amp = texture(sound,vec2(freq, cur_time)).r;// + (row_per) - 1. + hash(row_per);

  float angle = x * 2. * PI;
  vec2 vel = vec2(m1p1(hash(vert_per))*0.25 * amp, amp);
  vec2 xy = (center + vel * cur_time) ;

  gl_PointSize = 10.0;
  gl_Position = vec4(xy,0,1);
  v_color = vec4(1.0);
// v_color = mix(vec4(hsv2rgb(vec3(y*0.21, 1.-y, 1.)), 1.-row_per), background, row_per - 0.2);
}
