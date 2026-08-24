.pragma library
.import "Geometry.js" as Geom
// UiUtil.js — helpers for the editor (hit testing, formatting, colours, zone edits)

function fmt(v, d) { if (v === undefined || v === null || isNaN(v)) return "-"; return Number(v).toFixed(d === undefined ? 2 : d); }
function fmtTime(s) { if (!isFinite(s)) return "-"; var m = Math.floor(s / 60); var r = s - m * 60; return (m ? m + ":" : "") + (m ? (r < 10 ? "0" : "") : "") + r.toFixed(1); }

function withAlpha(hex, a) {
  var c = String(hex || "#888888");
  if (c.length === 7) { var r = parseInt(c.substr(1, 2), 16), g = parseInt(c.substr(3, 2), 16), b = parseInt(c.substr(5, 2), 16); return "rgba(" + r + "," + g + "," + b + "," + a + ")"; }
  return c;
}
function srcColor(i) { var cols = ["#7ad3ff", "#ffb86b", "#c48bff", "#8bff9d", "#ffd166", "#ff8fa3"]; if (typeof i === "string") { var h = 0; for (var k = 0; k < i.length; k++) h = (h * 31 + i.charCodeAt(k)) & 0x7fffffff; return cols[h % cols.length]; } return cols[(i || 0) % cols.length]; }
function srcLabel(i) { return typeof i === "string" ? i : (i === 4 ? "sim" : "s" + (i + 1)); }

function zoneFrame(z) { return Geom.makeFrame(z.pos || [0, 0, 0], z.rot || [0, 0, 0], [1, 1, 1]); }

// world point -> local 2D, picking with tolerance (metres)
function hitZone(z, wx, wy, tolM) {
  var f = zoneFrame(z);
  var lp = Geom.toLocal(f, [wx, wy, (z.pos && z.pos[2]) || 0]);
  var t = z.shape.type;
  var sd;
  if (t === "line") sd = Geom.shapeSDF2D(z.shape, lp[0], lp[1]) - tolM;      // near the segment
  else if (t === "path") sd = Geom.shapeSDF2D(z.shape, lp[0], lp[1]);
  else sd = Geom.shapeSDF2D(z.shape, lp[0], lp[1]);
  return sd <= tolM;
}

// handles for the selected zone, in local coords: [{kind, idx, x, y}]
function zoneHandles(z) {
  var s = z.shape; var h = [];
  switch (s.type) {
  case "rect": case "box": {
    var hw = (s.w || 1) / 2, hh = (s.h || 1) / 2;
    h.push({ kind: "corner", idx: 0, x: -hw, y: -hh }, { kind: "corner", idx: 1, x: hw, y: -hh }, { kind: "corner", idx: 2, x: hw, y: hh }, { kind: "corner", idx: 3, x: -hw, y: hh });
    h.push({ kind: "rot", idx: 0, x: 0, y: hh + 0.35 });
    break;
  }
  case "circle": case "sphere": case "cylinder": {
    var rx = s.rx || s.r || 1, ry = s.ry || s.r || rx;
    h.push({ kind: "radius", idx: 0, x: rx, y: 0 }, { kind: "radius", idx: 1, x: 0, y: ry });
    h.push({ kind: "rot", idx: 0, x: 0, y: ry + 0.35 });
    break;
  }
  case "polygon": case "prism": case "path": case "line": {
    var pts = s.points || [];
    for (var i = 0; i < pts.length; i++) h.push({ kind: "vertex", idx: i, x: pts[i][0], y: pts[i][1] });
    if (s.type !== "line") { for (var j = 0; j < pts.length; j++) { if (s.type === "path" && j === pts.length - 1) break; var a = pts[j], b = pts[(j + 1) % pts.length]; h.push({ kind: "mid", idx: j, x: (a[0] + b[0]) / 2, y: (a[1] + b[1]) / 2 }); } }
    // whole-shape rotation and uniform scale
    var x0 = Infinity, y0 = Infinity, x1 = -Infinity, y1 = -Infinity;
    for (var q = 0; q < pts.length; q++) { if (pts[q][0] < x0) x0 = pts[q][0]; if (pts[q][1] < y0) y0 = pts[q][1]; if (pts[q][0] > x1) x1 = pts[q][0]; if (pts[q][1] > y1) y1 = pts[q][1]; }
    if (isFinite(x0)) { h.push({ kind: "rot", idx: 0, x: 0, y: y1 + 0.35 }); h.push({ kind: "scale", idx: 0, x: x1 + 0.3, y: y1 + 0.3 }); }
    break;
  }
  }
  return h;
}

// Apply a handle drag. lp = new local position of the handle. Mutates z.
function applyHandle(z, hnd, lp, snapFn) {
  var s = z.shape;
  switch (hnd.kind) {
  case "corner": {
    // resize keeping opposite corner fixed: adjust size and shift center in local frame
    var sx = (hnd.idx === 1 || hnd.idx === 2) ? 1 : -1, sy = (hnd.idx >= 2) ? 1 : -1;
    var hw = (s.w || 1) / 2, hh = (s.h || 1) / 2;
    var ox = -sx * hw, oy = -sy * hh; // opposite corner (fixed)
    var nw = Math.max(0.05, Math.abs(lp[0] - ox)), nh = Math.max(0.05, Math.abs(lp[1] - oy));
    var ncx = (ox + lp[0]) / 2, ncy = (oy + lp[1]) / 2;
    var f = zoneFrame(z); var wc = Geom.toWorld(f, [ncx, ncy, 0]);
    s.w = nw; s.h = nh; z.pos = [wc[0], wc[1], z.pos[2]];
    break;
  }
  case "radius": {
    var r = Math.max(0.05, hnd.idx === 0 ? Math.abs(lp[0]) : Math.abs(lp[1]));
    if (s.type === "circle" && (s.rx || s.ry)) { if (hnd.idx === 0) s.rx = r; else s.ry = r; }
    else s.r = r;
    break;
  }
  case "rot": {
    // incremental: rotate by the angle between the handle's current spot and the mouse
    var prev = Math.atan2(hnd.y, hnd.x);
    var ang = (Math.atan2(lp[1], lp[0]) - prev) * 180 / Math.PI;
    z.rot = [z.rot[0] || 0, z.rot[1] || 0, ((z.rot[2] || 0) + ang)];
    break;
  }
  case "scale": {
    // uniform scale of point-based shapes about the zone origin
    var f0 = Math.hypot(hnd.x, hnd.y) || 1e-6, f1 = Math.hypot(lp[0], lp[1]);
    var k = Math.max(0.02, f1 / f0);
    var pp = s.points || [];
    for (var si = 0; si < pp.length; si++) pp[si] = [pp[si][0] * k, pp[si][1] * k];
    if (s.width) s.width = Math.max(0.01, s.width * k);
    break;
  }
  case "vertex": { s.points[hnd.idx] = [lp[0], lp[1]]; break; }
  }
}

function insertVertex(z, idx, lp) { z.shape.points.splice(idx + 1, 0, [lp[0], lp[1]]); }
function removeVertex(z, idx) { var min = z.shape.type === "line" ? 2 : (z.shape.type === "path" ? 2 : 3); if (z.shape.points.length > min) z.shape.points.splice(idx, 1); }

// world bounds of a zone (xy), for fit/zoom
function zoneWorldBounds(z) {
  var b = Geom.shapeBounds(z.shape); var f = zoneFrame(z);
  var out = [Infinity, Infinity, -Infinity, -Infinity];
  for (var i = 0; i < 4; i++) { var x = (i & 1) ? b[3] : b[0], y = (i & 2) ? b[4] : b[1]; var w = Geom.toWorld(f, [x, y, 0]); if (w[0] < out[0]) out[0] = w[0]; if (w[1] < out[1]) out[1] = w[1]; if (w[0] > out[2]) out[2] = w[0]; if (w[1] > out[3]) out[3] = w[1]; }
  return out;
}

function snapValue(v, step) { return step > 0 ? Math.round(v / step) * step : v; }

function incrementName(name) {
  var m = String(name).match(/^(.*?)(\d+)$/);
  if (m) return m[1] + (parseInt(m[2]) + 1);
  return name + " 2";
}

// Torus mesh in the XY plane (ring axis = Z) for ProceduralMesh: {positions:[[x,y,z]...], normals:[[...]...], indices:[...]}
function torusMesh(R, r, segs, sides) {
  var pos = [], nor = [], idx = [];
  segs = segs || 48; sides = sides || 10;
  for (var i = 0; i <= segs; i++) {
    var u = i / segs * Math.PI * 2, cu = Math.cos(u), su = Math.sin(u);
    for (var j = 0; j <= sides; j++) {
      var v = j / sides * Math.PI * 2, cv = Math.cos(v), sv = Math.sin(v);
      pos.push([(R + r * cv) * cu, (R + r * cv) * su, r * sv]);
      nor.push([cv * cu, cv * su, sv]);
    }
  }
  for (var a = 0; a < segs; a++) for (var b = 0; b < sides; b++) {
    var p0 = a * (sides + 1) + b, p1 = p0 + sides + 1;
    idx.push(p0, p1, p0 + 1, p1, p1 + 1, p0 + 1);
  }
  return { positions: pos, normals: nor, indices: idx };
}

// Low-poly unit meshes for entity pins (shared geometry): cylinder along Z from z=0..1 radius 1; sphere radius 1.
function cylinderMesh(sides) {
  sides = sides || 8; var pos = [], idx = [];
  for (var i = 0; i < sides; i++) { var a = i / sides * Math.PI * 2; pos.push([Math.cos(a), Math.sin(a), 0]); pos.push([Math.cos(a), Math.sin(a), 1]); }
  pos.push([0, 0, 0]); pos.push([0, 0, 1]);
  var cb = sides * 2, ct = sides * 2 + 1;
  for (var j = 0; j < sides; j++) { var a0 = j * 2, b0 = ((j + 1) % sides) * 2; idx.push(a0, b0, a0 + 1, b0, b0 + 1, a0 + 1); idx.push(cb, b0, a0); idx.push(ct, a0 + 1, b0 + 1); }
  return { positions: pos, indices: idx };
}
function sphereMesh(segs, rings) {
  segs = segs || 8; rings = rings || 5; var pos = [], idx = [];
  for (var r = 0; r <= rings; r++) { var ph = r / rings * Math.PI; for (var s = 0; s <= segs; s++) { var th = s / segs * Math.PI * 2; pos.push([Math.sin(ph) * Math.cos(th), Math.sin(ph) * Math.sin(th), Math.cos(ph)]); } }
  for (var r2 = 0; r2 < rings; r2++) for (var s2 = 0; s2 < segs; s2++) { var p0 = r2 * (segs + 1) + s2, p1 = p0 + segs + 1; idx.push(p0, p1, p0 + 1, p1, p1 + 1, p0 + 1); }
  return { positions: pos, indices: idx };
}

// arraybuffer -> string (ascii/utf8-lite)
function bufToString(buf) {
  if (typeof buf === "string") return buf;
  var u8 = new Uint8Array(buf); var n = u8.length;
  // plain UTF-8 decoder (String.fromCharCode.apply over typed arrays is pathologically slow in QJSEngine)
  var parts = [], chunk = "", i = 0;
  while (i < n) {
    var b = u8[i++], c;
    if (b < 0x80) c = b;
    else if (b < 0xE0) { c = ((b & 0x1F) << 6) | (u8[i++] & 0x3F); }
    else if (b < 0xF0) { c = ((b & 0x0F) << 12) | ((u8[i++] & 0x3F) << 6) | (u8[i++] & 0x3F); }
    else { c = ((b & 0x07) << 18) | ((u8[i++] & 0x3F) << 12) | ((u8[i++] & 0x3F) << 6) | (u8[i++] & 0x3F); c -= 0x10000; chunk += String.fromCharCode(0xD800 + (c >> 10)); c = 0xDC00 + (c & 0x3FF); }
    chunk += String.fromCharCode(c);
    if (chunk.length >= 4096) { parts.push(chunk); chunk = ""; }
  }
  parts.push(chunk);
  return parts.join("");
}

function deepGet(obj, path) { var parts = path.split("."); var o = obj; for (var i = 0; i < parts.length; i++) { if (o === undefined || o === null) return undefined; o = o[parts[i]]; } return o; }
function deepSet(obj, path, value) { var parts = path.split("."); var o = obj; for (var i = 0; i < parts.length - 1; i++) { if (o[parts[i]] === undefined || o[parts[i]] === null) o[parts[i]] = {}; o = o[parts[i]]; } o[parts[parts.length - 1]] = value; }

// random walker step for the simulator
function walkerStep(w, dt, bounds, speed, noise) {
  if (!w.target || Geom.dist2d(w.pos, w.target) < 0.2 || Math.random() < 0.004) {
    w.target = [bounds.x - bounds.w / 2 + Math.random() * bounds.w, bounds.y - bounds.h / 2 + Math.random() * bounds.h, 0];
  }
  var dx = w.target[0] - w.pos[0], dy = w.target[1] - w.pos[1]; var d = Math.sqrt(dx * dx + dy * dy) || 1;
  var sp = speed * (w.speedMul || 1);
  var vx = dx / d * sp + (Math.random() - 0.5) * noise * 2, vy = dy / d * sp + (Math.random() - 0.5) * noise * 2;
  w.pos = [w.pos[0] + vx * dt, w.pos[1] + vy * dt, w.pos[2] || 0];
  w.vel = [vx, vy, 0];
  w.heading = Math.atan2(vy, vx) * 180 / Math.PI;
}
