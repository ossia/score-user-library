/*{
  "DESCRIPTION": "hexagon tile strings",
  "CREDIT": "jshrake (ported from https://www.vertexshaderart.com/art/PyWaWYkpMMnc2GQBc)",
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
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1636465470472
    }
  }
}*/

// Hash without Sine
// MIT License...
/* Copyright (c)2014 David Hoskins.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.*/

//----------------------------------------------------------------------------------------
// 1 out, 1 in...
float hash11(float p) {
  p = fract(p * .1031);
  p *= p + 33.33;
  p *= p + p;
  return fract(p);
}

// Raskolnikov (https://math.stackexchange.com/users/3567/raskolnikov), Is there
// an equation to describe regular polygons?, URL (version: 2016-06-18):
// https://math.stackexchange.com/q/41954 https://math.stackexchange.com/a/41954
// Licensed under CC BY-SA 3.0

#ifndef TAU
#define TAU 6.28318530718
#endif
#ifndef PI
#define PI 3.14159265359
#endif

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

void main() {
  float gridw = 10.;
  float gridh = 10.;
  float particles_per_tile = 1000.0;
  float i = vertexId;
  float pct = i / (vertexCount - 1.0);

  float tile_i = floor(i / particles_per_tile);
  float tile_count = gridw * gridh;

  float tile_pi = mod(i, particles_per_tile);
  float tile_ppct = tile_pi / particles_per_tile;

  float row = floor(tile_i/gridw);
  float col = mod(tile_i, gridw);

  float size = 2.0/(gridw - 1.0);
  vec2 grid_scale = 1.3*vec2(1.0*sqrt(3.0)*size, 1.5*size);
  vec2 tile_scale = vec2(size);
  vec2 center = grid_scale*(grid2(tile_i, gridw, gridh).zw - 0.5*vec2(gridw, gridh));
  float loop_len = 4.0;
  float time_off = 0.0;
  float loop_pct = mod(time + time_off, loop_len) / (loop_len - 1.0);

  float ngon = 6.0;
  vec2 shape_a = parametric_ngon(ngon, tile_ppct);
  vec2 shape_b = parametric_ngon(ngon, tile_ppct + 0.5);
  float anim_delay = mix(0.0, 0.6, length(center + 0.0001)/(0.93*sqrt(2.0))) + mix(0.0, 0.2, tile_ppct);
  float anim_len = 0.2;
  float m = smoothstep(0.0 + anim_delay, 0.0 + anim_delay + anim_len, loop_pct);
  vec2 shape = mix(shape_a, shape_b, m);
  float eo = mod(row, 2.0);
  float rotoff = 0.0*(max(abs(center.x), abs(center.y)));
  shape = rot2(0.25*TAU)*shape;
  shape *= tile_scale;
  shape.x += 1.0 * eo * tile_scale.x;
  shape.y += 1.0*size;
  gl_Position.xy = center + shape;
  gl_Position.zw = vec2(0.0, 1.0);

  float scale = 0.006;
  gl_PointSize = 1000.0*scale;

  v_color = vec4(1.0);
}