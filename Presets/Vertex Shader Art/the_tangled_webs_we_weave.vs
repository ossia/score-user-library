/*{
  "DESCRIPTION": "the tangled webs we weave",
  "CREDIT": "jshrake (ported from https://www.vertexshaderart.com/art/BtkrDbo3o9cSAoXeW)",
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
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1185,
    "ORIGINAL_LIKES": 6,
    "ORIGINAL_DATE": {
      "$date": 1550159640832
    }
  }
}*/

// hash functions
#define HASHSCALE1 .1031
#define HASHSCALE3 vec3(.1031, .1030, .0973)
#define HASHSCALE4 vec4(.1031, .1030, .0973, .1099)

float hash11(float p) {
  vec3 p3 = fract(vec3(p) * HASHSCALE1);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.x + p3.y) * p3.z);
}

// from http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  // write the position
  float vertex_id = vertexId;
  float quad_id = vertexId;
  float quad_count = vertexCount;
  float quad_pct = quad_id / quad_count;
  float quads_per_trail = 1000.0;
  float trail_id = floor(quad_id / quads_per_trail);
  float trail_count = floor(quad_count / quads_per_trail);
  float trail_pct = trail_id / trail_count;
  float quad_trail_pct = quad_id / quads_per_trail - trail_id;
  float quad_size = 1.0;
  float trail_length = 1.0; //2.0*hash11(trail_id + 0.9872);

  float x = -1.0 + 2.0*quad_trail_pct*trail_length + 0.05*hash11(trail_id + 0.5123)*time;
  x = mod(x + 1.0, 2.0) - 1.0;
  float quad_x_pct = (x + 1.0) / 2.0;
  float toggle = 0.2; //smoothstep(0.3, 1.0, 0.5 * (sin(iTime) + 1.0));
  float how_much_quad = 0.3*(hash11(trail_id + 0.734)) * toggle;
  float y = 1.0*mix(
      0.2*hash11(trail_id + 0.1353)*sin(10.0*(x - trail_id)),
      how_much_quad*(2.0 * hash11(quad_id) - 1.0) + (1.0 - how_much_quad)*(2.0 * hash11(trail_id) - 1.0), smoothstep(0.1, 0.5, quad_x_pct) - smoothstep(0.2, 0.9 - 0.1*hash11(trail_id + 0.223), quad_x_pct));
  float z = 0.0;

  gl_Position = vec4(x,y,z,1.0);
  gl_PointSize = quad_size;

  // write the color
  vec3 hsv = vec3(mix(0.6 + 0.3*trail_pct, 0.5 + 0.1*trail_pct, quad_x_pct), 1.0, 1.0);
  v_color = vec4(hsv2rgb(hsv), 1.0);
}
