.pragma library
// Geometry.js — pure geometry helpers for Tracking Zones.
// Conventions: world is metres, Z up, right-handed. Points are [x, y, z] arrays.
// Signed distances are negative inside a zone, positive outside, in metres.

var DEG = Math.PI / 180;

function v3(x, y, z) { return [x || 0, y || 0, z || 0]; }
function add(a, b) { return [a[0] + b[0], a[1] + b[1], a[2] + b[2]]; }
function sub(a, b) { return [a[0] - b[0], a[1] - b[1], a[2] - b[2]]; }
function scale(a, s) { return [a[0] * s, a[1] * s, a[2] * s]; }
function dot(a, b) { return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]; }
function len(a) { return Math.sqrt(dot(a, a)); }
function len2d(a) { return Math.sqrt(a[0] * a[0] + a[1] * a[1]); }
function dist(a, b) { return len(sub(a, b)); }
function dist2d(a, b) { var dx = a[0] - b[0], dy = a[1] - b[1]; return Math.sqrt(dx * dx + dy * dy); }
function lerp(a, b, t) { return a + (b - a) * t; }
function clamp(x, lo, hi) { return x < lo ? lo : (x > hi ? hi : x); }
function cross2(ax, ay, bx, by) { return ax * by - ay * bx; }

// ---------- Rotation / transforms (row-major 3x3 rotation + translation) ----------
// Euler angles in degrees, applied as Rz(yaw) * Ry(pitch) * Rx(roll).
function rotationMatrix(rot) {
  var rx = (rot && rot[0] || 0) * DEG, ry = (rot && rot[1] || 0) * DEG, rz = (rot && rot[2] || 0) * DEG;
  var cx = Math.cos(rx), sx = Math.sin(rx), cy = Math.cos(ry), sy = Math.sin(ry), cz = Math.cos(rz), sz = Math.sin(rz);
  // R = Rz * Ry * Rx
  return [
    cz * cy, cz * sy * sx - sz * cx, cz * sy * cx + sz * sx,
    sz * cy, sz * sy * sx + cz * cx, sz * sy * cx - cz * sx,
    -sy, cy * sx, cy * cx
  ];
}
function matVec(m, p) {
  return [m[0] * p[0] + m[1] * p[1] + m[2] * p[2],
          m[3] * p[0] + m[4] * p[1] + m[5] * p[2],
          m[6] * p[0] + m[7] * p[1] + m[8] * p[2]];
}
function transpose(m) { return [m[0], m[3], m[6], m[1], m[4], m[7], m[2], m[5], m[8]]; }
function matMul(a, b) {
  var r = new Array(9);
  for (var i = 0; i < 3; i++) for (var j = 0; j < 3; j++)
    r[i * 3 + j] = a[i * 3] * b[j] + a[i * 3 + 1] * b[3 + j] + a[i * 3 + 2] * b[6 + j];
  return r;
}

// A "frame" = { pos:[x,y,z], rot:[rx,ry,rz] deg, scale:[sx,sy,sz] } ; local -> world: p_w = R * (S * p_l) + pos
function makeFrame(pos, rot, scl) {
  var R = rotationMatrix(rot || [0, 0, 0]);
  var s = scl || [1, 1, 1];
  return { pos: pos || [0, 0, 0], rot: rot || [0, 0, 0], scale: [s[0] || 1, s[1] || 1, s[2] || 1], R: R, Rt: transpose(R) };
}
function toWorld(f, p) {
  var q = [p[0] * f.scale[0], p[1] * f.scale[1], p[2] * f.scale[2]];
  return add(matVec(f.R, q), f.pos);
}
function toLocal(f, p) {
  var q = matVec(f.Rt, sub(p, f.pos));
  return [q[0] / f.scale[0], q[1] / f.scale[1], q[2] / f.scale[2]];
}
// rotate a direction (no translation/scale)
function dirToWorld(f, d) { return matVec(f.R, d); }
function composeFrames(parent, child) {
  // world = parent(child(p)) ; returns a frame with combined R and pos (scale composed component-wise, assumes axis-aligned scale)
  var R = matMul(parent.R, child.R);
  var pos = toWorld(parent, child.pos);
  var s = [parent.scale[0] * child.scale[0], parent.scale[1] * child.scale[1], parent.scale[2] * child.scale[2]];
  return { pos: pos, rot: null, scale: s, R: R, Rt: transpose(R) };
}

// ---------- Polygons ----------
function polygonArea(pts) {
  var a = 0;
  for (var i = 0, n = pts.length; i < n; i++) { var p = pts[i], q = pts[(i + 1) % n]; a += p[0] * q[1] - q[0] * p[1]; }
  return a * 0.5;
}
function polygonCentroid(pts) {
  var n = pts.length; if (n === 0) return [0, 0];
  var A = polygonArea(pts); if (Math.abs(A) < 1e-12) { var sx = 0, sy = 0; for (var i = 0; i < n; i++) { sx += pts[i][0]; sy += pts[i][1]; } return [sx / n, sy / n]; }
  var cx = 0, cy = 0;
  for (var j = 0; j < n; j++) { var p = pts[j], q = pts[(j + 1) % n]; var f = p[0] * q[1] - q[0] * p[1]; cx += (p[0] + q[0]) * f; cy += (p[1] + q[1]) * f; }
  return [cx / (6 * A), cy / (6 * A)];
}
function pointInPolygon(x, y, pts) {
  var inside = false;
  for (var i = 0, j = pts.length - 1; i < pts.length; j = i++) {
    var xi = pts[i][0], yi = pts[i][1], xj = pts[j][0], yj = pts[j][1];
    if (((yi > y) !== (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi + 0.0) + xi)) inside = !inside;
  }
  return inside;
}
function distToSegment2(px, py, ax, ay, bx, by) {
  var dx = bx - ax, dy = by - ay; var l2 = dx * dx + dy * dy;
  var t = l2 > 0 ? clamp(((px - ax) * dx + (py - ay) * dy) / l2, 0, 1) : 0;
  var cx = ax + t * dx - px, cy = ay + t * dy - py;
  return cx * cx + cy * cy;
}
function polygonSDF(x, y, pts) {
  var n = pts.length; if (n < 3) return 1e9;
  var d2 = Infinity;
  for (var i = 0, j = n - 1; i < n; j = i++) d2 = Math.min(d2, distToSegment2(x, y, pts[j][0], pts[j][1], pts[i][0], pts[i][1]));
  var d = Math.sqrt(d2);
  return pointInPolygon(x, y, pts) ? -d : d;
}
function polygonBounds(pts) {
  var b = [Infinity, Infinity, -Infinity, -Infinity];
  for (var i = 0; i < pts.length; i++) { var p = pts[i]; if (p[0] < b[0]) b[0] = p[0]; if (p[1] < b[1]) b[1] = p[1]; if (p[0] > b[2]) b[2] = p[0]; if (p[1] > b[3]) b[3] = p[1]; }
  return b;
}
function segmentsIntersect(a, b, c, d) {
  function ccw(p, q, r) { return (r[1] - p[1]) * (q[0] - p[0]) > (q[1] - p[1]) * (r[0] - p[0]); }
  return (ccw(a, c, d) !== ccw(b, c, d)) && (ccw(a, b, c) !== ccw(a, b, d));
}
function polygonSelfIntersects(pts) {
  var n = pts.length; if (n < 4) return false;
  for (var i = 0; i < n; i++) {
    var a = pts[i], b = pts[(i + 1) % n];
    for (var j = i + 2; j < n; j++) {
      if (i === 0 && j === n - 1) continue;
      if (segmentsIntersect(a, b, pts[j], pts[(j + 1) % n])) return true;
    }
  }
  return false;
}

// ---------- Shape SDFs in zone-local space ----------
// zone.shape: { type, w, h, d, r, rx, ry, points:[[x,y],...], zmin, zmax, useZ, width }
function zBandSDF(z, zmin, zmax) { return Math.max(zmin - z, z - zmax); }

function shapeSDF2D(shape, x, y) {
  switch (shape.type) {
  case "rect": {
    var hw = (shape.w || 1) * 0.5, hh = (shape.h || 1) * 0.5;
    var qx = Math.abs(x) - hw, qy = Math.abs(y) - hh;
    var ox = Math.max(qx, 0), oy = Math.max(qy, 0);
    return Math.sqrt(ox * ox + oy * oy) + Math.min(Math.max(qx, qy), 0);
  }
  case "circle": {
    var rx = shape.rx || shape.r || 0.5, ry = shape.ry || shape.r || rx;
    if (Math.abs(rx - ry) < 1e-9) return Math.sqrt(x * x + y * y) - rx;
    // ellipse approximation: scale to unit circle, rescale by min radius
    var k = Math.sqrt((x / rx) * (x / rx) + (y / ry) * (y / ry));
    return (k - 1) * Math.min(rx, ry);
  }
  case "polygon": case "prism":
    return polygonSDF(x, y, shape.points || []);
  case "box": return shapeSDF2D({ type: "rect", w: shape.w, h: shape.h }, x, y);
  case "sphere": return Math.sqrt(x * x + y * y) - (shape.r || 0.5);
  case "cylinder": return Math.sqrt(x * x + y * y) - (shape.r || 0.5);
  case "path": {
    var pts = shape.points || []; if (pts.length < 2) return 1e9;
    var d2 = Infinity;
    for (var i = 0; i + 1 < pts.length; i++) d2 = Math.min(d2, distToSegment2(x, y, pts[i][0], pts[i][1], pts[i + 1][0], pts[i + 1][1]));
    return Math.sqrt(d2) - (shape.width || 1) * 0.5;
  }
  case "line": {
    var a = shape.points && shape.points[0] || [0, 0], b = shape.points && shape.points[1] || [1, 0];
    return Math.sqrt(distToSegment2(x, y, a[0], a[1], b[0], b[1])) - (shape.width || 0.1) * 0.5;
  }
  default: return 1e9;
  }
}

// full signed distance including z handling. Returns metres.
function shapeSDF(shape, p) {
  var x = p[0], y = p[1], z = p[2];
  var t = shape.type;
  if (t === "sphere") {
    var r = shape.r || 0.5; return Math.sqrt(x * x + y * y + z * z) - r;
  }
  if (t === "box") {
    var hw = (shape.w || 1) * 0.5, hh = (shape.h || 1) * 0.5, hd = (shape.d || 1) * 0.5;
    var qx = Math.abs(x) - hw, qy = Math.abs(y) - hh, qz = Math.abs(z) - hd;
    var ox = Math.max(qx, 0), oy = Math.max(qy, 0), oz = Math.max(qz, 0);
    return Math.sqrt(ox * ox + oy * oy + oz * oz) + Math.min(Math.max(qx, Math.max(qy, qz)), 0);
  }
  if (t === "cylinder") {
    var hd2 = (shape.d || 1) * 0.5;
    var dr = Math.sqrt(x * x + y * y) - (shape.r || 0.5), dz = Math.abs(z) - hd2;
    var orr = Math.max(dr, 0), ozz = Math.max(dz, 0);
    return Math.sqrt(orr * orr + ozz * ozz) + Math.min(Math.max(dr, dz), 0);
  }
  var d2d = shapeSDF2D(shape, x, y);
  if (shape.useZ) {
    var zs = zBandSDF(z, shape.zmin || 0, (shape.zmax === undefined ? 2 : shape.zmax));
    // box-like combination
    var o1 = Math.max(d2d, 0), o2 = Math.max(zs, 0);
    return Math.sqrt(o1 * o1 + o2 * o2) + Math.min(Math.max(d2d, zs), 0);
  }
  return d2d;
}

// Local bounding box of a shape: [minx,miny,minz,maxx,maxy,maxz]
function shapeBounds(shape) {
  var zmin = shape.useZ ? (shape.zmin || 0) : -1e6, zmax = shape.useZ ? (shape.zmax === undefined ? 2 : shape.zmax) : 1e6;
  switch (shape.type) {
  case "rect": return [-(shape.w || 1) / 2, -(shape.h || 1) / 2, zmin, (shape.w || 1) / 2, (shape.h || 1) / 2, zmax];
  case "circle": { var rx = shape.rx || shape.r || .5, ry = shape.ry || shape.r || rx; return [-rx, -ry, zmin, rx, ry, zmax]; }
  case "box": return [-(shape.w || 1) / 2, -(shape.h || 1) / 2, -(shape.d || 1) / 2, (shape.w || 1) / 2, (shape.h || 1) / 2, (shape.d || 1) / 2];
  case "sphere": { var r = shape.r || .5; return [-r, -r, -r, r, r, r]; }
  case "cylinder": { var r2 = shape.r || .5, hd = (shape.d || 1) / 2; return [-r2, -r2, -hd, r2, r2, hd]; }
  case "polygon": case "prism": case "path": case "line": {
    var b = polygonBounds(shape.points || []); var m = (shape.width || 0) / 2;
    if (!isFinite(b[0])) return [0, 0, zmin, 0, 0, zmax];
    return [b[0] - m, b[1] - m, zmin, b[2] + m, b[3] + m, zmax];
  }
  }
  return [-1, -1, zmin, 1, 1, zmax];
}

// Normalised coordinates of a local point in the shape: {u,v,w in 0..1 (bbox), r (0..1 radial where meaningful), angle (deg), progress, offset}
function shapeUVW(shape, p) {
  var b = shapeBounds(shape);
  var out = {};
  var w = b[3] - b[0], h = b[4] - b[1], d = b[5] - b[2];
  out.u = w > 1e-9 ? (p[0] - b[0]) / w : 0.5;
  out.v = h > 1e-9 ? (p[1] - b[1]) / h : 0.5;
  out.w = (d > 1e-9 && d < 1e5) ? (p[2] - b[2]) / d : 0.5;
  var rr = Math.sqrt(p[0] * p[0] + p[1] * p[1]);
  var R = shape.r || shape.rx || Math.max(w, h) * 0.5 || 1;
  out.r = rr / R;
  out.angle = Math.atan2(p[1], p[0]) / DEG;
  if (shape.type === "path") {
    var pr = pathProgress(shape.points || [], p[0], p[1]);
    out.progress = pr.progress; out.offset = pr.offset;
  }
  return out;
}

// progress 0..1 along polyline + signed lateral offset (left positive) for the closest segment
function pathProgress(pts, x, y) {
  if (pts.length < 2) return { progress: 0, offset: 0 };
  var total = 0, lens = [];
  for (var i = 0; i + 1 < pts.length; i++) { var l = Math.sqrt((pts[i + 1][0] - pts[i][0]) * (pts[i + 1][0] - pts[i][0]) + (pts[i + 1][1] - pts[i][1]) * (pts[i + 1][1] - pts[i][1])); lens.push(l); total += l; }
  var best = Infinity, bestProg = 0, bestOff = 0, acc = 0;
  for (var j = 0; j + 1 < pts.length; j++) {
    var ax = pts[j][0], ay = pts[j][1], bx = pts[j + 1][0], by = pts[j + 1][1];
    var dx = bx - ax, dy = by - ay, l2 = dx * dx + dy * dy;
    var t = l2 > 0 ? clamp(((x - ax) * dx + (y - ay) * dy) / l2, 0, 1) : 0;
    var cx = ax + t * dx, cy = ay + t * dy;
    var d2 = (cx - x) * (cx - x) + (cy - y) * (cy - y);
    if (d2 < best) {
      best = d2; bestProg = total > 0 ? (acc + t * lens[j]) / total : 0;
      var side = cross2(dx, dy, x - ax, y - ay); bestOff = (side >= 0 ? 1 : -1) * Math.sqrt(d2);
    }
    acc += lens[j];
  }
  return { progress: bestProg, offset: bestOff };
}

// Line crossing helper. Returns side sign of point relative to segment a->b (+1 left, -1 right), and whether the projection is within the segment.
function lineSide(a, b, x, y, extended) {
  var dx = b[0] - a[0], dy = b[1] - a[1];
  var s = cross2(dx, dy, x - a[0], y - a[1]);
  var l2 = dx * dx + dy * dy;
  var t = l2 > 0 ? ((x - a[0]) * dx + (y - a[1]) * dy) / l2 : 0;
  return { side: s > 0 ? 1 : (s < 0 ? -1 : 0), within: extended ? true : (t >= 0 && t <= 1), t: t };
}

// ---------- Homography (4 point correspondences, DLT) ----------
// src: [[x,y]x4] dst: [[x,y]x4] -> 3x3 row-major or null
function computeHomography(src, dst) {
  if (!src || !dst || src.length < 4 || dst.length < 4) return null;
  var A = [];
  for (var i = 0; i < 4; i++) {
    var x = src[i][0], y = src[i][1], X = dst[i][0], Y = dst[i][1];
    A.push([-x, -y, -1, 0, 0, 0, x * X, y * X, X]);
    A.push([0, 0, 0, -x, -y, -1, x * Y, y * Y, Y]);
  }
  // Solve A h = 0 with h[8] = 1: 8x8 linear system
  var M = [], bvec = [];
  for (var r = 0; r < 8; r++) { M.push(A[r].slice(0, 8)); bvec.push(-A[r][8]); }
  var h = solveLinear(M, bvec); if (!h) return null;
  h.push(1);
  return h;
}
function solveLinear(M, b) {
  var n = b.length; var a = M.map(function (row, i) { return row.concat([b[i]]); });
  for (var c = 0; c < n; c++) {
    var piv = c; for (var r = c + 1; r < n; r++) if (Math.abs(a[r][c]) > Math.abs(a[piv][c])) piv = r;
    if (Math.abs(a[piv][c]) < 1e-12) return null;
    var tmp = a[c]; a[c] = a[piv]; a[piv] = tmp;
    for (var r2 = 0; r2 < n; r2++) { if (r2 === c) continue; var f = a[r2][c] / a[c][c]; for (var k = c; k <= n; k++) a[r2][k] -= f * a[c][k]; }
  }
  var x = new Array(n); for (var i = 0; i < n; i++) x[i] = a[i][n] / a[i][i];
  return x;
}
function applyHomography(H, x, y) {
  var w = H[6] * x + H[7] * y + H[8]; if (Math.abs(w) < 1e-12) w = 1e-12;
  return [(H[0] * x + H[1] * y + H[2]) / w, (H[3] * x + H[4] * y + H[5]) / w];
}

// ---------- One Euro filter ----------
function OneEuro(minCutoff, beta, dCutoff) {
  this.minCutoff = minCutoff || 1.0; this.beta = beta || 0.0; this.dCutoff = dCutoff || 1.0;
  this.x = null; this.dx = 0; this.t = null;
}
OneEuro.prototype.alpha = function (cutoff, dt) { var tau = 1 / (2 * Math.PI * cutoff); return 1 / (1 + tau / dt); };
OneEuro.prototype.filter = function (x, t) {
  if (this.x === null || this.t === null) { this.x = x; this.t = t; this.dx = 0; return x; }
  var dt = t - this.t; if (dt <= 0) return this.x; this.t = t;
  var dx = (x - this.x) / dt;
  var ad = this.alpha(this.dCutoff, dt); this.dx = ad * dx + (1 - ad) * this.dx;
  var cutoff = this.minCutoff + this.beta * Math.abs(this.dx);
  var a = this.alpha(cutoff, dt); this.x = a * x + (1 - a) * this.x;
  return this.x;
};

// Extrude a 2D polygon to a triangle mesh (for 3D display). Returns {positions:[x,y,z,...], indices:[...]} in local coords.
function extrudePolygon(pts, zmin, zmax) {
  var n = pts.length; var pos = [], idx = [];
  if (n < 3) return { positions: pos, indices: idx };
  // side walls
  for (var i = 0; i < n; i++) {
    var p = pts[i];
    pos.push(p[0], p[1], zmin, p[0], p[1], zmax);
  }
  for (var j = 0; j < n; j++) {
    var a = j * 2, b = ((j + 1) % n) * 2;
    idx.push(a, b, a + 1, b, b + 1, a + 1);
  }
  // caps via fan (works for convex; acceptable for display)
  var base = pos.length / 3;
  var c = polygonCentroid(pts);
  pos.push(c[0], c[1], zmin); pos.push(c[0], c[1], zmax);
  for (var k = 0; k < n; k++) {
    var a2 = k * 2, b2 = ((k + 1) % n) * 2;
    idx.push(base, b2, a2);
    idx.push(base + 1, a2 + 1, b2 + 1);
  }
  return { positions: pos, indices: idx };
}
