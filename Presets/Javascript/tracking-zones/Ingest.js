.pragma library
.import "Geometry.js" as Geom
// Ingest.js — turn whatever arrives on a source inlet into canonical entity records,
// then apply the source calibration (units, axes, origin, homography, rigid transform).
//
// Canonical entity (pre-engine): { id, pos:[x,y,z], vel:[x,y,z]|null, conf, cls, name, keypoints:[[x,y,z,c],...]|null,
//                                  kpFormat, size:[w,h,d]|null, height, heading, extra:{} }

var AXIS_PRESETS = {
  "xyz": "x,y,z",        // Z-up (ossia neutral, OpenTrackIO, most lidar)
  "yup": "x,-z,y",       // Y-up, Z towards viewer (OpenGL, PSN, OpenXR, Leap, Unity-ish)
  "camera": "x,z,-y",    // Y-down image-space depth cam? (rare) — x right, y down, z forward
  "camera-yup": "x,z,y", // x right, y up, z forward (Kinect/ZED/RealSense SDK default)
  "zup-yfwd": "x,y,z"
};

function defaultSource(i) {
  return {
    enabled: true, name: (typeof i === "string" ? i : "Source " + (i + 1)), units: "m", unitScale: 1.0, // unitScale used only when units === "custom"
    axes: "xyz", axisSpec: "", flipX: false, flipY: false, flipZ: false,
    originMode: "world",            // world | normalized | pixels
    scene: { w: 4, h: 3 },          // metres, for normalized sources (centred on the source position)
    pixels: { w: 1920, h: 1080, mpp: 0.002 },
    transform: { pos: [0, 0, 0], rot: [0, 0, 0], scale: [1, 1, 1] },
    homography: null,               // { src:[[x,y]x4], dst:[[x,y]x4] } in post-unit coordinates → world floor
    idMode: "auto",                 // auto | index
    dataFormat: "auto",             // auto | points2 | points3 | boxes_xywh | boxes_corners2 | boxes_corners3 — how *bare* numeric lists / vec4s are read; maps are self-describing
    idPrefix: "",
    defaultZ: 0,
    cls: "", tag: "",
    lostTimeout: 0.5,               // seconds without data before an entity is dropped
    smoothing: { enabled: false, minCutoff: 1.0, beta: 0.02 },
    maxJump: 0,                     // metres/tick, 0 = off; rejects teleports for index-id sources
    flatStride: 0                   // 0 = auto (2 or 3) for flat float lists
  };
}

// Values arriving over ossia cables come out of QJSEngine as array-LIKES: length and indices work,
// JSON.stringify prints an array, but Array.isArray is FALSE. Every list check on input data must use
// isList — Array.isArray silently rejects real cable data (it only passes in unit tests).
function isList(v) { return Array.isArray(v) || (v !== null && typeof v === "object" && typeof v.length === "number" && v.length >= 0 && typeof v.x !== "number"); }
function isBoxMap(v) { return v !== null && typeof v === "object" && !isList(v) && isNum(v.x) && isNum(v.y) && isNum(v.w) && isNum(v.h); }
function isVec(v) { return v !== null && typeof v === "object" && typeof v.x === "number" && !isList(v) && !(isNum(v.w) && isNum(v.h)); }
function isNum(v) { return typeof v === "number" && isFinite(v); }
function vecToArr(v) { return [v.x || 0, v.y || 0, typeof v.z === "number" ? v.z : 0, typeof v.w === "number" ? v.w : undefined]; }

function asPoint(v) {
  // -> [x,y,z] or null
  if (v === null || v === undefined) return null;
  if (isVec(v)) return [v.x || 0, v.y || 0, typeof v.z === "number" ? v.z : 0];
  if (isList(v)) {
    if (v.length >= 2 && isNum(v[0]) && isNum(v[1])) return [v[0], v[1], v.length > 2 && isNum(v[2]) ? v[2] : 0];
    return null;
  }
  if (typeof v === "object") {
    if (isNum(v.x) && isNum(v.y)) return [v.x, v.y, isNum(v.z) ? v.z : 0];
    if (isNum(v[0]) && isNum(v[1])) return [v[0], v[1], isNum(v[2]) ? v[2] : 0];
  }
  return null;
}

var POS_KEYS = ["position", "pos", "centroid", "point", "translation", "palm", "center", "centre", "xyz", "xy", "location"];
var ID_KEYS = ["id", "track_id", "trackId", "session_id", "sessionId", "pid", "uid", "uuid", "name", "slot"];
var CONF_KEYS = ["confidence", "score", "conf", "probability", "mean_confidence", "status", "validity"];
var VEL_KEYS = ["velocity", "vel", "speed_vector"];
var CLS_KEYS = ["class_id", "classId", "cls", "class", "label", "type_id", "class_name"];

function pick(obj, keys) { for (var i = 0; i < keys.length; i++) { if (obj[keys[i]] !== undefined && obj[keys[i]] !== null) return obj[keys[i]]; } return undefined; }

// Does this map look like ONE entity (rather than a container of entities or of sources)?
// Used by the exec to decide whether a map on an inlet is {name: payload} sources or entity data.
function looksLikeEntity(m) {
  return m !== null && typeof m === "object" && !isList(m)
      && (pick(m, POS_KEYS) !== undefined || m.keypoints !== undefined || m.landmarks !== undefined
          || m.box !== undefined || m.bbox !== undefined || m.boundingRect !== undefined
          || (isNum(m.x) && isNum(m.y)));
}

function keypointsOf(obj) {
  var kps = obj.keypoints || obj.landmarks || obj.joints || obj.skeleton;
  if (!isList(kps) || kps.length === 0) return null;
  // sparse keypoints carrying their own index (legacy YOLO-pose: {kp, x, y}) — scatter so anchors stay aligned
  if (kps[0] && typeof kps[0] === "object" && isNum(kps[0].kp)) {
    var maxIdx = 0; for (var si = 0; si < kps.length; si++) if (isNum(kps[si].kp) && kps[si].kp > maxIdx) maxIdx = kps[si].kp;
    var nk = maxIdx >= 17 ? maxIdx + 1 : 17;  // COCO-17 unless indices go higher
    var sparse = []; for (var sj = 0; sj < nk; sj++) sparse.push([0, 0, 0, 0]);
    for (var sk = 0; sk < kps.length; sk++) { var kk = kps[sk]; if (isNum(kk.kp) && kk.kp >= 0 && kk.kp < nk) sparse[kk.kp] = [kk.x || 0, kk.y || 0, kk.z || 0, isNum(kk.confidence) ? kk.confidence : 1]; }
    return sparse;
  }
  var out = [];
  for (var i = 0; i < kps.length; i++) {
    var k = kps[i]; var p = null, c = 1;
    if (isList(k)) { p = asPoint(k); c = k.length > 3 && isNum(k[3]) ? k[3] : 1; } // list check FIRST: arrays are typeof "object" too
    else if (k && typeof k === "object") {
      if (k.position !== undefined) { p = asPoint(k.position); c = isNum(k.visibility) ? k.visibility : (isNum(k.confidence) ? k.confidence : 1); }
      else { p = asPoint(k); c = isNum(k.confidence) ? k.confidence : (isNum(k.visibility) ? k.visibility : (isNum(k.score) ? k.score : 1)); }
    }
    if (p) out.push([p[0], p[1], p[2], c]); else out.push([0, 0, 0, 0]);
  }
  return out;
}

// Keypoint format guess by count, used for feet/head anchors.
function kpFormat(n) {
  if (n === 17) return "coco17";
  if (n === 33 || n === 39) return "blazepose";
  if (n === 18) return "openpose18";
  if (n === 25) return "body25";
  if (n === 26) return "halpe26";
  if (n === 32) return "azure32";
  if (n === 34) return "zed34";
  if (n === 133) return "wholebody133";
  return "unknown";
}
// returns {feet:[idx], head:[idx], handL:[idx], handR:[idx], hips:[idx]}
function kpIndices(fmt) {
  switch (fmt) {
  case "coco17": case "wholebody133": return { feet: [15, 16], head: [0], handL: [9], handR: [10], hips: [11, 12] };
  case "halpe26": return { feet: [15, 16], head: [17], handL: [9], handR: [10], hips: [11, 12] };
  case "blazepose": return { feet: [27, 28], head: [0], handL: [15], handR: [16], hips: [23, 24] };
  case "openpose18": return { feet: [10, 13], head: [0], handL: [7], handR: [4], hips: [8, 11] };
  case "body25": return { feet: [11, 14], head: [0], handL: [7], handR: [4], hips: [8] };
  case "azure32": return { feet: [20, 24], head: [26], handL: [8], handR: [15], hips: [0] };
  case "zed34": return { feet: [20, 24], head: [26], handL: [8], handR: [15], hips: [0] };
  }
  return null;
}

function entityFromMap(m, fallbackId) {
  var e = { id: null, pos: null, vel: null, conf: 1, cls: "", name: "", keypoints: null, kpFormat: "", size: null, height: null, heading: null, extra: {} };
  if (m.active === false || m.tracked === false) return null;
  var pv = pick(m, POS_KEYS);
  var p = asPoint(pv);
  // box-only detections (ONNX {box:{x,y,w,h}}, CV {bbox}, Augmenta {boundingRect})
  var box = m.box || m.bbox || m.boundingRect || m.geometry;
  var bc = box ? boxCentreSize(box) : null;
  if (!p && bc) p = bc.centre.slice();
  if (bc) e.size = bc.size;
  var kps = keypointsOf(m);
  if (!p && kps) {
    // average of valid keypoints
    var sx = 0, sy = 0, sz = 0, n = 0;
    for (var i = 0; i < kps.length; i++) { if (kps[i][3] > 0.2) { sx += kps[i][0]; sy += kps[i][1]; sz += kps[i][2]; n++; } }
    if (n > 0) p = [sx / n, sy / n, sz / n];
  }
  if (!p) {
    // maybe x/y fields directly
    if (isNum(m.x) && isNum(m.y)) p = [m.x, m.y, isNum(m.z) ? m.z : 0];
  }
  if (!p) return null;
  e.pos = p;
  e.keypoints = kps; if (kps) e.kpFormat = kpFormat(kps.length);
  var idv = pick(m, ID_KEYS);
  if (idv === undefined || idv === null || idv === -1) idv = fallbackId;
  e.id = String(idv);
  if (typeof m.name === "string") e.name = m.name;
  var cv = pick(m, CONF_KEYS); if (isNum(cv)) e.conf = cv;
  var vv = pick(m, VEL_KEYS); var vp = asPoint(vv); if (vp) e.vel = vp;
  var cl = pick(m, CLS_KEYS); if (cl !== undefined) e.cls = String(cl);
  if (isNum(m.height)) e.height = m.height;
  if (isNum(m.orientation)) e.heading = m.orientation;
  else if (isNum(m.heading)) e.heading = m.heading;
  if (m.state !== undefined) e.extra.state = m.state;
  if (m.age !== undefined) e.extra.age = m.age;
  if (m.provisional !== undefined) e.extra.provisional = m.provisional;
  return e;
}

// Parse a raw inlet value into a list of canonical (uncalibrated) entities.
function parseEntities(raw, src) {
  var out = [];
  if (raw === undefined || raw === null) return out;
  if (typeof raw === "string") { try { raw = JSON.parse(raw); } catch (err) { return out; } }
  if (isVec(raw)) { var pv = asPoint(raw); if (pv) out.push(mkSimple("0", pv)); return out; }
  if (isList(raw)) {
    if (raw.length === 0) return out;
    // flat numbers?
    var fmt = (src && src.dataFormat) || "auto";
    if (isNum(raw[0])) {
      var allNum = true; for (var i = 0; i < raw.length; i++) if (!isNum(raw[i])) { allNum = false; break; }
      if (allNum) {
        var stride = fmtStride(fmt);
        if (!stride) stride = src && src.flatStride > 0 ? src.flatStride : (raw.length % 3 === 0 && raw.length % 2 !== 0 ? 3 : (raw.length % 2 === 0 ? 2 : 3));
        if (fmt === "auto" && (raw.length === 2 || raw.length === 3)) { out.push(mkSimple("0", [raw[0], raw[1], raw.length > 2 ? raw[2] : 0])); return out; }
        for (var j = 0; j + stride <= raw.length; j += stride) {
          var bx = boxFromNums(String(j / stride), fmt, raw, j);
          out.push(bx ? bx : mkSimple(String(j / stride), [raw[j], raw[j + 1], stride > 2 ? raw[j + 2] : 0]));
        }
        return out;
      }
    }
    for (var k = 0; k < raw.length; k++) {
      var el = raw[k];
      if (el === null || el === undefined) continue;
      if (isVec(el)) {
        if ((fmt === "boxes_xywh" || fmt === "boxes_corners2") && typeof el.w === "number") { out.push(boxFromNums(String(k), fmt, [el.x, el.y, el.z, el.w], 0)); continue; }
        var p2 = asPoint(el); if (p2) { var s = mkSimple(String(k), p2); if (typeof el.w === "number" && el.w !== undefined && typeof el.z === "number") { /* vec4: xyz + conf */ s.conf = el.w; } out.push(s); }
      }
      else if (isList(el)) {
        if (el.length >= 2 && isNum(el[0]) && isNum(el[1])) {
          var need = fmtStride(fmt);
          if (need && fmt.indexOf("boxes") === 0 && el.length >= need) { out.push(boxFromNums(String(k), fmt, el, 0)); continue; }
          var s2 = mkSimple(String(k), [el[0], el[1], (el.length > 2 && fmt !== "points2") ? el[2] : 0]); if (el.length > 3 && fmt === "auto") s2.conf = el[3]; out.push(s2);
        }
        else { var sub = parseEntities(el, src); for (var q = 0; q < sub.length; q++) { sub[q].id = k + "." + sub[q].id; out.push(sub[q]); } }
      }
      else if (typeof el === "object") { var e = entityFromMap(el, String(k)); if (e) out.push(e); }
    }
    return out;
  }
  if (typeof raw === "object") {
    // single entity map?
    var single = entityFromMap(raw, "0");
    if (single && (pick(raw, POS_KEYS) !== undefined || raw.keypoints || raw.box || raw.bbox || isNum(raw.x))) { out.push(single); return out; }
    // container map: {"0": {...}, "1": {...}} or {"trackers": {...}}
    var keys = Object.keys(raw);
    for (var c = 0; c < keys.length; c++) {
      var key = keys[c]; var val = raw[key];
      // an inactive child (Leap /left/active false, PSN untracked...) hides everything below it,
      // even when the position lives deeper (/left/palm/position)
      if (val && typeof val === "object" && (val.active === false || val.tracked === false)) continue;
      if (val && typeof val === "object" && !isVec(val) && !isList(val)) {
        var ent = entityFromMap(val, key);
        if (ent) { if (ent.id === key || pick(val, ID_KEYS) === undefined) ent.id = key; out.push(ent); }
        else {
          // nested container (e.g. device root with "trackers": {...}) — one level deeper
          var subKeys = Object.keys(val); var nested = false;
          for (var d = 0; d < subKeys.length; d++) { var sv = val[subKeys[d]]; if (sv && typeof sv === "object" && !isVec(sv) && !isList(sv) && pick(sv, POS_KEYS) !== undefined) { nested = true; break; } }
          if (nested) { var subs = parseEntities(val, src); for (var z = 0; z < subs.length; z++) { subs[z].id = key + "." + subs[z].id; out.push(subs[z]); } }
        }
      } else if (isList(val) && val.length && typeof val[0] === "object") {
        var subs2 = parseEntities(val, src); for (var y = 0; y < subs2.length; y++) { subs2[y].id = key + "." + subs2[y].id; out.push(subs2[y]); }
      }
    }
  }
  return out;
}
function mkSimple(id, p) { return { id: id, pos: p, vel: null, conf: 1, cls: "", name: "", keypoints: null, kpFormat: "", size: null, height: null, heading: null, extra: {} }; }
function boxEnt(id, cx, cy, cz, w, h, d) { var e = mkSimple(id, [cx, cy, cz]); e.size = [Math.abs(w), Math.abs(h), Math.abs(d || 0)]; return e; }
function boxFromNums(id, fmt, a, o) {
  o = o || 0;
  if (fmt === "boxes_xywh") return boxEnt(id, a[o] + a[o + 2] / 2, a[o + 1] + a[o + 3] / 2, 0, a[o + 2], a[o + 3]);
  if (fmt === "boxes_corners2") return boxEnt(id, (a[o] + a[o + 2]) / 2, (a[o + 1] + a[o + 3]) / 2, 0, a[o + 2] - a[o], a[o + 3] - a[o + 1]);
  if (fmt === "boxes_corners3") return boxEnt(id, (a[o] + a[o + 3]) / 2, (a[o + 1] + a[o + 4]) / 2, (a[o + 2] + a[o + 5]) / 2, a[o + 3] - a[o], a[o + 4] - a[o + 1], a[o + 5] - a[o + 2]);
  return null;
}
function fmtStride(fmt) { return fmt === "points2" ? 2 : (fmt === "points3" ? 3 : (fmt === "boxes_xywh" || fmt === "boxes_corners2" ? 4 : (fmt === "boxes_corners3" ? 6 : 0))); }

// ---------- Calibration ----------
var UNIT_SCALE = { m: 1, cm: 0.01, mm: 0.001, ft: 0.3048, "in": 0.0254, px: 1, norm: 1 };

function parseAxisSpec(spec) {
  // "x,-z,y" -> [[0,1],[2,-1],[1,1]] : world axis i takes input axis idx with sign
  var parts = (spec || "x,y,z").split(",");
  var map = [];
  for (var i = 0; i < 3; i++) {
    var s = (parts[i] || "xyz"[i]).trim(); var sign = 1;
    if (s[0] === "-") { sign = -1; s = s.substr(1); } else if (s[0] === "+") s = s.substr(1);
    var idx = s === "x" ? 0 : (s === "y" ? 1 : 2);
    map.push([idx, sign]);
  }
  return map;
}

function makeCalibrator(src) {
  var spec = src.axisSpec && src.axisSpec.length ? src.axisSpec : (AXIS_PRESETS[src.axes] || "x,y,z");
  var amap = parseAxisSpec(spec);
  var us = (src.units === "custom" && src.unitScale > 0) ? src.unitScale : (UNIT_SCALE[src.units] || 1);
  var tr = src.transform || {};
  var frame = Geom.makeFrame(tr.pos || [0, 0, 0], tr.rot || [0, 0, 0], tr.scale || [1, 1, 1]);
  var H = null;
  if (src.homography && src.homography.src && src.homography.dst) H = Geom.computeHomography(src.homography.src, src.homography.dst);
  var fx = src.flipX ? -1 : 1, fy = src.flipY ? -1 : 1, fz = src.flipZ ? -1 : 1;
  var mode = src.originMode || "world";
  var scene = src.scene || { w: 4, h: 3 };
  var px = src.pixels || { w: 1920, h: 1080, mpp: 0.002 };
  function point(p, isDir) {
    var x = p[0], y = p[1], z = p[2] || 0;
    var q;
    if (mode === "normalized") {
      // image-style 0..1, origin top-left, y down -> centred metres, y up
      q = [(x - 0.5) * scene.w, (0.5 - y) * scene.h, z * (scene.d || 1)];
      if (isDir) q = [x * scene.w, -y * scene.h, z * (scene.d || 1)];
    } else if (mode === "pixels") {
      var mpp = px.mpp || 0.002;
      q = [(x - px.w / 2) * mpp, (px.h / 2 - y) * mpp, z * mpp];
      if (isDir) q = [x * mpp, -y * mpp, z * mpp];
    } else {
      var inv = [x * us, y * us, z * us];
      q = [amap[0][1] * inv[amap[0][0]], amap[1][1] * inv[amap[1][0]], amap[2][1] * inv[amap[2][0]]];
    }
    q = [q[0] * fx, q[1] * fy, q[2] * fz];
    if (H && !isDir) { var hp = Geom.applyHomography(H, q[0], q[1]); q = [hp[0], hp[1], q[2]]; }
    return isDir ? Geom.dirToWorld(frame, q) : Geom.toWorld(frame, q);
  }
  return {
    point: point,
    apply: function (e) {
      var p = point(e.pos, false);
      if (src.defaultZ && (e.pos[2] === 0 || e.pos[2] === undefined) && mode !== "world") p[2] += src.defaultZ;
      e.pos = p;
      if (e.vel) e.vel = point(e.vel, true);
      if (e.keypoints) { for (var i = 0; i < e.keypoints.length; i++) { var k = e.keypoints[i]; var w = point([k[0], k[1], k[2]], false); e.keypoints[i] = [w[0], w[1], w[2], k[3]]; } }
      if (e.size) { var sv = point(e.size, true); e.size = [Math.abs(sv[0]), Math.abs(sv[1]), Math.abs(sv[2])]; }
      if (e.height !== null && e.height !== undefined) e.height = e.height * (mode === "world" ? us : 1);
      return e;
    }
  };
}

// Any common box representation -> { centre:[x,y,z], size:[w,h,d] } or null:
//   {x,y,w,h[,d]} (top-left + size) · {x1,y1,x2,y2[,z1,z2]} · {xmin,ymin,xmax,ymax[,zmin,zmax]}
//   vec4 (xywh) · [x,y,w,h] · [x1,y1,z1,x2,y2,z2] (6 numbers = 3D corners)
function boxCentreSize(box) {
  if (box === null || box === undefined) return null;
  if (isList(box)) {
    if (box.length >= 6 && isNum(box[4]) && isNum(box[5])) return { centre: [(box[0] + box[3]) / 2, (box[1] + box[4]) / 2, (box[2] + box[5]) / 2], size: [Math.abs(box[3] - box[0]), Math.abs(box[4] - box[1]), Math.abs(box[5] - box[2])] };
    if (box.length >= 4) return { centre: [box[0] + box[2] / 2, box[1] + box[3] / 2, 0], size: [box[2], box[3], 0] };
    return null;
  }
  if (typeof box !== "object") return null;
  if (isNum(box.x1) && isNum(box.y1) && isNum(box.x2) && isNum(box.y2)) { var z1 = isNum(box.z1) ? box.z1 : 0, z2 = isNum(box.z2) ? box.z2 : 0; return { centre: [(box.x1 + box.x2) / 2, (box.y1 + box.y2) / 2, (z1 + z2) / 2], size: [Math.abs(box.x2 - box.x1), Math.abs(box.y2 - box.y1), Math.abs(z2 - z1)] }; }
  if (isNum(box.xmin) && isNum(box.ymin) && isNum(box.xmax) && isNum(box.ymax)) { var zn = isNum(box.zmin) ? box.zmin : 0, zx = isNum(box.zmax) ? box.zmax : 0; return { centre: [(box.xmin + box.xmax) / 2, (box.ymin + box.ymax) / 2, (zn + zx) / 2], size: [box.xmax - box.xmin, box.ymax - box.ymin, zx - zn] }; }
  if (isBoxMap(box)) return { centre: [box.x + box.w / 2, box.y + box.h / 2, isNum(box.z) && isNum(box.d) ? box.z + box.d / 2 : 0], size: [box.w, box.h, isNum(box.d) ? box.d : 0] };
  if (isVec(box) && typeof box.w === "number") return { centre: [box.x + box.z / 2, box.y + box.w / 2, 0], size: [box.z, box.w, 0] }; // vec4 xywh
  return null;
}
