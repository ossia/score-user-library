/*{
  "DESCRIPTION": "hexagon tile strings",
  "CREDIT": "jshrake (ported from https://www.vertexshaderart.com/art/nEpiQXnFSAvRvgwTY)",
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
    "ORIGINAL_VIEWS": 573,
    "ORIGINAL_LIKES": 6,
    "ORIGINAL_DATE": {
      "$date": 1636465752571
    }
  }
}*/

// Hexagon Tile Strings by Justin Shrake (https://twitter.com/j2rgb)
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

void main() {
  // Loop timings
  float loop_len = 4.0;
  float time_off = 0.0;
  float loop_pct = mod(time + time_off, loop_len) / (loop_len - 1.0);
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

  // Calculate the position of each particle in the tile
  float ngon = 6.0;
  float swirl = 0.5;
  // The animation interpolates a point in the hexagon to another point in the hexagon
  vec2 tile_a = parametric_ngon(ngon, tile_ppct);
  vec2 tile_b = parametric_ngon(ngon, tile_ppct + swirl);
  // Animation delay outwards w/ some magic numbers for taste
  float anim_delay = mix(0.0, 0.6, length(tile_center + 0.0001)/(0.93*sqrt(2.0))) + mix(0.0, 0.2, tile_ppct);
  float anim_len = 0.2;
  float m = smoothstep(0.0 + anim_delay, 0.0 + anim_delay + anim_len, loop_pct);
  vec2 tile = mix(tile_a, tile_b, m);
  tile = rot2(0.25*TAU)*tile;
  tile *= tile_scale;
  tile.x += 1.0 * eo * tile_scale.x;
  tile.y += 1.0*size;

  // Outputs
  gl_Position.xy = tile_center + tile;
  gl_Position.zw = vec2(0.0, 1.0);
  gl_PointSize = 3.0;
  v_color = vec4(1.0);
}