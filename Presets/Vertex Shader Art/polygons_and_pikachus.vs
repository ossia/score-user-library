/*{
  "DESCRIPTION": "polygons and pikachus - Sunday morning sketch that I just had to get out of my head.",
  "CREDIT": "jshrake (ported from https://www.vertexshaderart.com/art/gb4JMDjdT2iyyCLdE)",
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
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 992,
    "ORIGINAL_LIKES": 7,
    "ORIGINAL_DATE": {
      "$date": 1551023797336
    }
  }
}*/

#define maxN 7.0
#define zoom 0.8
#define sprite_min_scale 0.005
#define sprite_max_scale 0.05
#define PI 3.14159265359

mat2 rot(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat2(c, s, -s, c);
}

// from http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// From https://www.shadertoy.com/view/4dS3Wd
float hash(float n) { return fract(sin(n) * 1e4); }

#define S(o) hash(shape_id + (o))

void main () {
    float points_per_shape = 200.0;
    float point_id = float(vertexId);
    float shape_id = floor(point_id / points_per_shape);
    float shape_count = floor(vertexCount / points_per_shape);
    float point_pct = point_id / points_per_shape - shape_id;

    // shape animaton params
    float shape_rot = 2.0 * PI * S(2.1);
    vec2 shape_offset = 2.0 * vec2(S(30.1), S(400.1)) - 1.0;
    float shape_speed = 0.2 * S(5.222) + 0.001;
    float shape_rot_speed = 1.0*(S(16.3133) - 0.5);

    // Parametric equation of a polygon courtesy of
    // https://math.stackexchange.com/a/41954
    // Generate random values of n for each shape_id between 3.0 and 7.0
    float n = floor((maxN - 3.0)*S(7.22125) + 3.0);
    float theta = mod(2.0 * PI * (point_pct), 2.0*PI);
    float r = cos(PI / n)/cos(mod(theta, 2.0 * PI / n) - PI / n);
    float x = r * cos(theta);
    float y = r * sin(theta);

    float s = texture(sound, vec2(S(3042.33) * .1, 0)).r;
    s = smoothstep(0.6, 1.0, s);

    // Apply animation params
    vec2 xy = rot(0.5*PI + shape_rot_speed*time)*vec2(x,y);
    xy *= ((s*sprite_max_scale - sprite_min_scale) * S(78.01) + sprite_min_scale);
    xy.y *= resolution.x/resolution.y;
    xy.x += 1.0*(2.0 * S(3.311222) - 1.0);
    xy.y -= 1.0*S(439.11035) + shape_speed * time;
    xy.y = mod(xy.y + 1.0, 2.0) - 1.0;

    gl_Position = vec4(xy, 0.0, zoom);
    gl_PointSize = 0.0035*resolution.y;
    v_color.rgb = hsv2rgb(vec3(0.1 + 0.05*S(452.011), 1.0, 1.0));
    v_color.a = 1.0;
}
