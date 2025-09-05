/*{
  "DESCRIPTION": "hexagon tile strings 3D",
  "CREDIT": "jshrake (ported from https://www.vertexshaderart.com/art/yQxBYWw4sFSMS2gsp)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
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
    "ORIGINAL_VIEWS": 1737,
    "ORIGINAL_LIKES": 7,
    "ORIGINAL_DATE": {
      "$date": 1636899862273
    }
  }
}*/

// Hexagon Tile Strings by Justin Shrake (https://twitter.com/j2rgb)
// Inspired by https://twitter.com/etiennejcb/status/974037218330382336?s=20
// CC BY-NC 4.0 https://creativecommons.org/licenses/by-nc/4.0/

// Submission for https://twitter.com/sableRaph #WCCChallenge
// Topic: non-rectangular tiles
// https://www.twitch.tv/sableraph

#ifndef TAU
#define TAU 6.28318530718
#endif
#ifndef PI
#define PI 3.14159265359
#endif

// Raskolnikov (https://math.stackexchange.com/users/3567/raskolnikov), Is there
// an equation to describe regular polygons?, URL (version: 2016-06-18):
// https://math.stackexchange.com/q/41954 https://math.stackexchange.com/a/41954
// Licensed under CC BY-SA 3.0
float mmod(float x, float m) { return mod(mod(x, m) + m, m); }
vec2 parametric_ngon(float n, float theta) {
  theta = mod(TAU * theta, TAU);
  float r = cos(PI / n) / cos(mmod(theta, 2.0 * PI / n) - PI / n);
  float x = r * cos(theta);
  float y = r * sin(theta);
  return vec2(x, y);
}

vec4 grid2(float id, float w, float h) {
  float ux = w == 1.0 ? 0.0 : mod(id, w);
  float uy = h == 1.0 ? 0.0 : mod(floor(id / w), h);
  float x = w == 1.0 ? 0.0 : 2.0 * ux / (w - 1.0) - 1.0;
  float y = h == 1.0 ? 0.0 : 2.0 * uy / (h - 1.0) - 1.0;
  return vec4(x, y, ux, uy);
}

mat2 rot2(float t) {
  float ct = cos(t);
  float st = sin(t);
  return mat2(ct, -st, st, ct);
}

mat4 frustum(float left, float right, float bottom, float top, float near,
        float far) {
  float x = 2.0 * near / (right - left);
  float y = 2.0 * near / (top - bottom);
  float A = (right + left) / (right - left);
  float B = (top + bottom) / (top - bottom);
  float C = -(far + near) / (far - near);
  float D = -2.0 * far * near / (far - near);
  // clang-format off
    return mat4(
    x, 0, 0, 0,
    0, y, 0, 0,
    A, B, C, -1,
    0, 0, D, 0
    );
  // clang-format on
}

mat4 perspective(float hfov_deg, float aspect, float near, float far) {
  float hfov_rad = radians(hfov_deg);
  float vfov_rad = 2.0 * atan(tan(hfov_rad * 0.5) / aspect);
  // Tangent of half-FOV
  float tangent = tan(0.5 * vfov_rad);
  // Half the height of the near plane
  float height = near * tangent;
  // Half the width of the near plane
  float width = height * aspect;
  return frustum(-width, width, -height, height, near, far);
}

float quadraticInOut(float t) {
  float p = 2.0 * t * t;
  return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
}

//
// GLSL textureless classic 2D noise "cnoise",
// with an RSL-style periodic variant "pnoise".
// Author: Stefan Gustavson (stefan.gustavson@liu.se)
// Version: 2011-08-22
//
// Many thanks to Ian McEwan of Ashima Arts for the
// ideas for permutation and gradient selection.
//
// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
// Distributed under the MIT license. See LICENSE file.
// https://github.com/stegu/webgl-noise
//

vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }

vec4 permute(vec4 x) { return mod289(((x * 34.0) + 10.0) * x); }

vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

vec2 fade(vec2 t) { return t * t * t * (t * (t * 6.0 - 15.0) + 10.0); }

// Classic Perlin noise
float perlin(vec2 P) {
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod289(Pi); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;

  vec4 i = permute(permute(ix) + iy);

  vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0;
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;

  vec2 g00 = vec2(gx.x, gy.x);
  vec2 g10 = vec2(gx.y, gy.y);
  vec2 g01 = vec2(gx.z, gy.z);
  vec2 g11 = vec2(gx.w, gy.w);

  vec4 norm = taylorInvSqrt(
      vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;

  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));

  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}

// Classic Perlin noise, periodic variant
float pnoise(vec2 P, vec2 rep) {
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, rep.xyxy); // To create noise with explicit period
  Pi = mod289(Pi); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;

  vec4 i = permute(permute(ix) + iy);

  vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0;
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;

  vec2 g00 = vec2(gx.x, gy.x);
  vec2 g10 = vec2(gx.y, gy.y);
  vec2 g01 = vec2(gx.z, gy.z);
  vec2 g11 = vec2(gx.w, gy.w);

  vec4 norm = taylorInvSqrt(
      vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;

  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));

  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}

mat4 rot3(vec3 axis, float angle) {
  axis = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;

  return mat4(
      oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s,
      oc * axis.z * axis.x + axis.y * s, 0.0, oc * axis.x * axis.y + axis.z * s,
      oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0.0,
      oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s,
      oc * axis.z * axis.z + c, 0.0, 0.0, 0.0, 0.0, 1.0);
}

void main() {
  // Loop timings
  float loop_len = 4.0;
  float time_off = 0.0;
  float loop_pct = mod(time + time_off, loop_len) / (loop_len);
  // The size of the hexagon tile grid
  float gridw = 20.;
  float gridh = 20.;
  // The number of particles per hexagon
  float particles_per_tile = 250.0;
  // The particle index
  float i = vertexId;
  // The particle perctange
  float pct = i / (vertexCount - 1.0);

  // The hexagon index
  float tile_i = floor(i / particles_per_tile);
  // The total number of hexagons
  float tile_count = gridw * gridh;

  // The particle index wrt the hexagon
  float tile_pi = mod(i, particles_per_tile);
  // The particle percentage wrt the hexagon
  float tile_ppct = tile_pi / particles_per_tile;

  float row = floor(tile_i/gridw);
  float col = mod(tile_i, gridw);
  float eo = mod(row, 2.0);

  float ar = resolution.y < resolution.x ? resolution.x/resolution.y : resolution.y/resolution.x;

  // Hexagon tile size
  float size = 1.0/(gridw - 1.0);
  // padding between hexagons, 1.0 for no padding
  float padding = 1.2;
  // hexagon math courtesy of https://www.redblobgames.com/grids/hexagons/
  vec2 grid_scale = padding*vec2(1.0*sqrt(3.0)*size, 1.5*ar*size);
  vec2 tile_scale = vec2(size, size*ar);
  // The center of the hexagon
  vec2 tile_center = grid_scale*(grid2(tile_i, gridw, gridh).zw - 0.5*vec2(gridw, gridh));
  tile_center.y += 2.5;
  // Calculate the position of each particle in the tile
  float ngon = 6.0;
  float swirl = 0.5;
  // The animation interpolates a point in the hexagon to another point in the hexagon
  vec2 tile_a = parametric_ngon(ngon, tile_ppct);
  float pn = 0.5*perlin(vec2(3.3)*tile_center) + 0.5;
  float anim_delay = mix(0.0, 0.7, pn) + mix(0.0, 0.1, tile_ppct);
  float anim_len = 0.2;
  float m = smoothstep(0.0 + anim_delay, 0.0 + anim_delay + anim_len, loop_pct);
  vec3 tile = vec3(tile_a, 0.0);
  tile.xy = rot2(0.25*TAU)*tile.xy;
  tile.xy *= tile_scale;
  tile.x += 1.0 * eo * tile_scale.x;
  tile.y += 1.0*size;
  float amt = 1.0;
  float start_z = -0.6;
  tile.z = mix(start_z, start_z - amt, quadraticInOut(m));
  tile.z += mix(0.0, amt, (loop_pct));

  // Outputs
  vec4 pos;
  pos.xyz = vec3(tile_center, 0.0) + tile;
  pos.w = 1.0;
  pos = rot3(vec3(1.0, 0.0, 0.0), 0.75*0.25*TAU)*rot3(vec3(0.0, 0.0, 1.0), 0.0*TAU)*pos;
  mat4 p = perspective(60.0, 1.0, 0.01, 10.0);
  gl_Position = p * pos;
  gl_PointSize = 3.0;
  v_color = vec4(1.0);
}