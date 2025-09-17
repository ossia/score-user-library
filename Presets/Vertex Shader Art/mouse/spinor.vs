/*{
  "DESCRIPTION": "spinor",
  "CREDIT": "attila (ported from https://www.vertexshaderart.com/art/AXjMauM4Aq37fkzLf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 14400,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 12,
    "ORIGINAL_DATE": {
      "$date": 1493840515638
    }
  }
}*/

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 quad(vec3 origin, vec3 center, vec3 tangent, int vert_of_quad) {
  vec3 bitangent = cross(center, tangent);
  center += origin;
  if (vert_of_quad == 0)
    return center + tangent + bitangent;
  else if (vert_of_quad == 1)
    return center + tangent - bitangent;
  else if (vert_of_quad == 2)
    return center - tangent + bitangent;
  else if (vert_of_quad == 3)
    return center - tangent - bitangent;
  else if (vert_of_quad == 4)
    return center + tangent - bitangent;
  else if (vert_of_quad == 5)
    return center - tangent + bitangent;
  return center;
}

vec3 cube_quad(vec3 center, vec3 tangent, int vert_of_quad) {
  return quad(vec3(0.0), center, tangent, vert_of_quad);
}

struct Quad {
  vec3 v0, v1, v2, v3;
  vec3 nor;
  int mat_id;
};

vec3 vert_of_quad(Quad q, int vert_of_quad) {
  if (vert_of_quad == 0)
    return q.v0;
  else if (vert_of_quad == 1)
    return q.v1;
  else if (vert_of_quad == 2)
    return q.v2;
  else if (vert_of_quad == 3)
    return q.v0;
  else if (vert_of_quad == 4)
    return q.v2;
  else if (vert_of_quad == 5)
    return q.v3;
  return q.v0;
}

vec3 norm_of_quad(Quad q, int vert_of_quad) {
  return normalize((vert_of_quad < 3)
    ? cross(q.v0 - q.v1, q.v2 - q.v1)
    : cross(q.v0 - q.v2, q.v3 - q.v2));
}

struct Ring {
  vec3 s0, s1, s2, s3;
  vec3 e0, e1, e2, e3;
};

Quad quad_of_ring(Ring r, int quad_in_ring)
{
  Quad q;

  if (quad_in_ring == 0) {
    q.v0 = r.s0;
    q.v1 = r.s1;
    q.v2 = r.e1;
    q.v3 = r.e0;
    q.nor = normalize(r.s1 - r.s2);
  } else if (quad_in_ring == 1) {
    q.v0 = r.s1;
    q.v1 = r.s2;
    q.v2 = r.e2;
    q.v3 = r.e1;
    q.nor = normalize(r.s2 - r.s3);
  } else if (quad_in_ring == 2) {
    q.v0 = r.s2;
    q.v1 = r.s3;
    q.v2 = r.e3;
    q.v3 = r.e2;
    q.nor = normalize(r.s3 - r.s0);
  } else if (quad_in_ring == 3) {
    q.v0 = r.s3;
    q.v1 = r.s0;
    q.v2 = r.e0;
    q.v3 = r.e3;
    q.nor = normalize(r.s0 - r.s1);
  }

  q.mat_id = quad_in_ring;

  return q;
}

struct Segment {
  vec3 d0, d1;
  vec3 p0, p1;
  vec3 n0, n1;
};

Ring ring_from_segment(Segment s) {
  vec3 b0 = normalize(cross(s.d0, s.n0)) * 0.5;
  vec3 b1 = normalize(cross(s.d1, s.n1)) * 0.5;

  vec3 n0 = normalize(s.n0) * 0.25;
  vec3 n1 = normalize(s.n1) * 0.25;

  Ring r;

  r.s0 = s.p0 + n0 - b0;
  r.s1 = s.p0 + n0 + b0;
  r.s2 = s.p0 - n0 + b0;
  r.s3 = s.p0 - n0 - b0;

  r.e0 = s.p1 + n1 - b1;
  r.e1 = s.p1 + n1 + b1;
  r.e2 = s.p1 - n1 + b1;
  r.e3 = s.p1 - n1 - b1;

  return r;
}

vec3 curve_x_pos(float t) {
  float alpha = smoothstep(0.3, 0.4, t);
  float beta = smoothstep(0.3, 0.4, t) - smoothstep(0.5, 0.75, t);

  float phi = alpha * PI - time;

  float d = 5.0 * t;

  float A = alpha * d;

  float delta_x = -beta * (sin(time/2.0) * 0.5 + 0.5);
  float delta_y = -beta*2.0 * (-sin(time));
  float delta_z = -beta*3.0 * sin(time);

  return vec3(A + delta_x * 2.0, delta_y, delta_z);
}

vec3 curve_x_nor(float t) {
  float r = t;//abs(t - 0.5) * 2.0;
  float angle = 0.0;//-smoothstep(0.3, 0.6, r) * PI;

  return vec3(sin(angle), 0.0, cos(angle));
}

vec3 curve_y_pos(float t) {
  return vec3(0.0);//, -10.0 + 20.0 * t, 0.0);
}
vec3 curve_y_nor(float t) {
  return vec3(0.0);//sin(t*10.0), 0.0, cos(t*10.0));
}

vec3 curve_z_pos(float t) {
  return vec3(0.0);//, 0.0, -10.0 + 20.0 * t);
}
vec3 curve_z_nor(float t) {
  return vec3(sin(t*10.0), cos(t*10.0), 0.0);
}

Segment segment_x(float t1, float t2) {
  Segment s;

  float d = (t2 - t1) * 0.1;

  s.d0 = curve_x_pos(t1+d) - curve_x_pos(t1-d);
  s.d1 = curve_x_pos(t2+d) - curve_x_pos(t2-d);

  s.p0 = curve_x_pos(t1);
  s.p1 = curve_x_pos(t2);

  s.n0 = curve_x_nor(t1);
  s.n1 = curve_x_nor(t2);

  return s;
}

Segment segment_y(float t1, float t2) {
  Segment s;

  float d = (t2 - t1) * 0.1;

  s.d0 = curve_y_pos(t1+d) - curve_y_pos(t1-d);
  s.d1 = curve_y_pos(t2+d) - curve_y_pos(t2-d);

  s.p0 = curve_y_pos(t1);
  s.p1 = curve_y_pos(t2);

  s.n0 = curve_y_nor(t1);
  s.n1 = curve_y_nor(t2);

  return s;
}

Segment segment_z(float t1, float t2) {
  Segment s;

  float d = (t2 - t1) * 0.1;

  s.d0 = curve_z_pos(t1+d) - curve_z_pos(t1-d);
  s.d1 = curve_z_pos(t2+d) - curve_z_pos(t2-d);

  s.p0 = curve_z_pos(t1);
  s.p1 = curve_z_pos(t2);

  s.n0 = curve_z_nor(t1);
  s.n1 = curve_z_nor(t2);

  return s;
}

Quad quad_of_strip(int strip_id, int i, int n) {
  int num_rings = n / 4;
  int ring_id = i / 4;
  int quad_in_ring = i - 4 * ring_id;

  Segment s;

  float t1 = float(ring_id) / float(num_rings);
  float t2 = (float(ring_id) + 1.0) / float(num_rings);

  if (strip_id == 0)
   s = segment_x(t1, t2);
  else if (strip_id == 1)
   s = segment_y(t1, t2);
  else if (strip_id == 2)
   s = segment_z(t1, t2);

  Ring r = ring_from_segment(s);

  Quad q = quad_of_ring(r, quad_in_ring);
  q.nor = (s.n0 + s.n1) / 2.0;
  return q;
}

void main() {
  vec3 pos = vec3(0.0);
  vec3 nor = vec3(0.0, 0.0, 0.0);

  int tri_id = int(floor(vertexId / 3.0));
  int vert_in_tri = int(vertexId) - 3 * tri_id;

  int quad_id = tri_id / 2;
  int tri_in_quad = int(tri_id) - 2 * quad_id;

  int mat_id = 0;

  vec3 cube_x = vec3(cos(time), sin(time), 0.0);
  vec3 cube_y = vec3(-sin(time), cos(time), 0.0);

  if (quad_id < 6) {
    int dim_id = quad_id / 2;
    int side_in_dim = quad_id - 2 * dim_id;

    if (dim_id == 0) {
      pos = cube_quad(vec3(0.0, 0.0, 1.0), cube_x, vert_in_tri + tri_in_quad*3);
      nor = vec3(0.0, 0.0, 1.0);
    } else if (dim_id == 1) {
      pos = cube_quad(cube_y, cube_x, vert_in_tri + tri_in_quad*3);
      nor = cube_y;
    } else if (dim_id == 2) {
      pos = cube_quad(cube_x, cube_y, vert_in_tri + tri_in_quad*3);
      nor = cube_x;
    }
    mat_id = dim_id;

    if (side_in_dim == 1)
      pos *= -1.0;

  }
  else {
    int vert_remaining = int(vertexCount) - 36;
    int vert_per_strip = vert_remaining / 3;
    int quad_per_strip = vert_per_strip / 6;

    int lvi = int(vertexId) - 36;

    int strip = lvi / vert_per_strip;
    int first_vert_of_strip = 36 + strip * vert_per_strip;
    int vert_in_strip = int(vertexId) - first_vert_of_strip;

    int quad_in_strip = vert_in_strip / 6;
    int vert_in_quad = vert_in_strip - quad_in_strip * 6;

    Quad q;

    q = quad_of_strip(strip, quad_in_strip, quad_per_strip);

      /*
    q.center = vec3(2.0, 0.0, 1.0);
      q.tangent = vec3(1.0, 0.0, 0.0);
    q.bitangent = vec3(0.0, 0.0, 1.0);
      q.normal = vec3(0.0, 1.0, 0.0);
    */
    pos = vert_of_quad(q, vert_in_quad);
    nor = q.nor;//norm_of_quad(q, vert_in_quad);
    mat_id = q.mat_id;
  }

  vec3 base_x = vec3(cos(mouse.x*3.0), 1.0, sin(mouse.x*3.0));
  vec3 base_y = vec3(sin(mouse.x*3.0), 1.0, -cos(mouse.x*3.0));

  base_x *= vec3(cos(mouse.y*3.0), sin(mouse.y*3.0), cos(mouse.y * 3.0));
  base_y *= vec3(cos(mouse.y*3.0), sin(mouse.y*3.0), cos(mouse.y * 3.0));

  vec3 base_z = cross(base_x, base_y);
  base_x = cross(base_z, base_y);

  base_x = normalize(base_x) * 0.1;
  base_y = normalize(base_y) * 0.1;
  base_z = normalize(base_z) * 0.1;

  vec3 nor_mapped = normalize(nor.x * base_x + nor.y * base_y + nor.z * base_z);

  vec3 col = hsv2rgb(vec3(0.08 + float(mat_id) * 0.25, 1, 1));

  vec3 lightdir = normalize(vec3(-1, 1, -1));

  float diff = 0.25 + 0.75 * abs(dot(nor_mapped, lightdir));
  v_color = vec4(col * diff, 1.0);

  vec3 pos_mapped = pos.x * base_x + pos.y * base_y + pos.z * base_z;
  pos_mapped.x /= 1.0 + pos_mapped.z * 0.75;
  pos_mapped.y /= 1.0 + pos_mapped.z * 0.75;
  pos_mapped.x /= (resolution.x / resolution.y);
  gl_Position = vec4(pos_mapped, 1.0);
}