.pragma library
.import "Ingest.js" as Ingest
// Model.js — document schema, defaults and factories shared by the exec script, the UI and tests.

var VERSION = 1;
var PALETTE = ["#c58014", "#5b9bd5", "#7fc45a", "#d96b6b", "#9b7bd6", "#2bb3a3", "#e08cc7", "#c7b24d", "#4dc0e0", "#e07d4d"];

var ZONE_TYPES = ["rect", "circle", "polygon", "line", "path", "box", "sphere", "cylinder", "prism"];
var ANCHORS = ["center", "feet", "head", "hands", "any", "all"];
var CONTAINMENTS = ["point", "radius", "bbox"];
var SELECTIONS = ["all", "nearest", "first_in", "last_in", "max_n"];
var ROLES = ["event", "exclude", "include"];
var FRAMES = ["world", "entity", "zone", "source"];

var _counter = 0;
function uid(prefix) { _counter++; return (prefix || "z") + "-" + Date.now().toString(36) + "-" + (_counter).toString(36) + Math.floor(Math.random() * 1e4).toString(36); }

function defaultSettings() {
  return {
    activeSet: "",                 // "" = all sets
    uiRate: 30,
    lostTimeout: 0.5,
    heatmap: { enabled: false, x: 0, y: 0, w: 8, h: 6, cols: 16, rows: 12, decay: 0.2 },
    units: "m",
    upAxis: "z",
    worldTransform: { pos: [0, 0, 0], rot: [0, 0, 0] }, // "World tool": applied to every source
    showMode: false,
    proximity: { enabled: false, distance: 1.0, crossSourcesOnly: false }, // entity↔entity proximity events
    backdrop: { path: "", x: 0, y: 0, w: 10, h: 7.5, opacity: 0.5, rotation: 0 },
    grid: 1.0,
    monitor: { maxEvents: 400, maxEventsPerSec: 100 }  // event log limits (rows kept / rows added per second)
  };
}

function defaultShape(type) {
  switch (type) {
  case "rect": return { type: "rect", w: 2, h: 2, useZ: false, zmin: 0, zmax: 2 };
  case "circle": return { type: "circle", r: 1, rx: 0, ry: 0, useZ: false, zmin: 0, zmax: 2 };
  case "polygon": return { type: "polygon", points: [[-1, -1], [1, -1], [1, 1], [-1, 1]], useZ: false, zmin: 0, zmax: 2 };
  case "prism": return { type: "polygon", points: [[-1, -1], [1, -1], [1, 1], [-1, 1]], useZ: true, zmin: 0, zmax: 2 };
  case "line": return { type: "line", points: [[-1, 0], [1, 0]], width: 0.1, direction: "both", extended: false, useZ: false, zmin: 0, zmax: 2 };
  case "path": return { type: "path", points: [[-2, 0], [0, 1], [2, 0]], width: 1, useZ: false, zmin: 0, zmax: 2 };
  case "box": return { type: "box", w: 2, h: 2, d: 2 };
  case "sphere": return { type: "sphere", r: 1 };
  case "cylinder": return { type: "cylinder", r: 1, d: 2 };
  }
  return { type: "rect", w: 2, h: 2, useZ: false, zmin: 0, zmax: 2 };
}

function makeZone(type, index) {
  var t = type || "rect";
  var z = {
    id: uid("z"), name: (t.charAt(0).toUpperCase() + t.slice(1)) + " " + ((index || 0) + 1),
    color: PALETTE[(index || 0) % PALETTE.length],
    enabled: true, visible: true, locked: false, tags: [], set: "", group: "",
    frame: "world", frameRef: "",
    pos: [0, 0, t === "box" || t === "sphere" || t === "cylinder" ? 1 : 0], rot: [0, 0, 0],
    shape: defaultShape(t),
    role: "event",
    anchor: "center", containment: "point", radius: 0.25,
    filters: { cls: "", tags: "", sources: [], minConf: 0, minAge: 0, heightMin: 0, heightMax: 0, speedMin: 0, speedMax: 0, maxCount: 0 },
    hysteresis: { margin: 0.05, enterMs: 0, exitMs: 0, enterFrames: 1, exitFrames: 1, holdMs: 0, cooldownMs: 0 },
    dwell: { loiterS: 0 },
    occupancy: { setThreshold: 1, clearThreshold: 0, capacity: 0 },
    selection: "all", maxN: 1,
    line: { confirmFrames: 2, countOnce: false },
    soft: { enabled: false, falloff: 0.5 },
    stationary: { speed: 0.1, timeS: 2 },
    outputs: { perId: true, tree: true }
  };
  return z;
}

function cloneZone(z) { return JSON.parse(JSON.stringify(z)); }

function defaultDoc() {
  return {
    version: VERSION,
    zones: [],
    sets: [],
    groups: [],
    sources: [Ingest.defaultSource(0), Ingest.defaultSource(1), Ingest.defaultSource(2), Ingest.defaultSource(3)],
    settings: defaultSettings()
  };
}

// fill in missing fields (forward compat / partial JSON from users)
function normalizeDoc(doc) {
  var d = doc && typeof doc === "object" ? doc : {};
  var out = defaultDoc();
  if (Array.isArray(d.zones)) {
    out.zones = d.zones.map(function (z, i) { return normalizeZone(z, i); });
  }
  if (Array.isArray(d.sets)) out.sets = d.sets.slice();
  if (Array.isArray(d.groups)) out.groups = d.groups.slice();
  if (Array.isArray(d.sources)) {
    for (var i = 0; i < out.sources.length; i++) if (d.sources[i]) out.sources[i] = merge(out.sources[i], d.sources[i]);
  }
  if (d.settings) out.settings = merge(out.settings, d.settings);
  return out;
}
function normalizeZone(z, i) {
  var base = makeZone((z && z.shape && z.shape.type) || z.type || "rect", i);
  var m = merge(base, z || {});
  if (z && z.id) m.id = z.id;
  if (z && z.shape) m.shape = merge(defaultShape(z.shape.type || "rect"), z.shape);
  return m;
}
function merge(base, over) {
  if (Array.isArray(base) || Array.isArray(over)) return over !== undefined ? JSON.parse(JSON.stringify(over)) : base;
  if (typeof base !== "object" || base === null) return over !== undefined ? over : base;
  var out = {};
  var k;
  for (k in base) out[k] = base[k];
  for (k in over) {
    if (over[k] !== null && typeof over[k] === "object" && !Array.isArray(over[k]) && typeof base[k] === "object" && base[k] !== null && !Array.isArray(base[k])) out[k] = merge(base[k], over[k]);
    else out[k] = Array.isArray(over[k]) ? JSON.parse(JSON.stringify(over[k])) : over[k];
  }
  return out;
}

function is3D(shape) { if (!shape) return false; var t = shape.type; return !!(t === "box" || t === "sphere" || t === "cylinder" || shape.useZ); }
function isPointShape(shape) { var t = shape.type; return !(t === "line" || t === "path"); }

// Presets / templates -----------------------------------------------------------
function template(name) {
  var zs = [];
  switch (name) {
  case "door": {
    var l = makeZone("line", 0); l.name = "Door"; l.shape.points = [[-0.6, 0], [0.6, 0]]; l.shape.direction = "both"; l.pos = [0, 0, 0]; zs.push(l);
    var a = makeZone("rect", 1); a.name = "Approach"; a.shape.w = 2; a.shape.h = 1.5; a.pos = [0, -1.2, 0]; zs.push(a);
    break;
  }
  case "stage": {
    var names = ["Upstage", "Midstage", "Downstage"];
    for (var i = 0; i < 3; i++) { var r = makeZone("rect", i); r.name = names[i]; r.shape.w = 8; r.shape.h = 2; r.pos = [0, 2 - i * 2, 0]; zs.push(r); }
    break;
  }
  case "funnel": {
    var radii = [1, 2.5, 4.5]; var n2 = ["Interaction", "Viewing", "Passing by"];
    for (var j = 0; j < 3; j++) { var c = makeZone("circle", j); c.name = n2[j]; c.shape.r = radii[j]; c.pos = [0, 0, 0]; zs.push(c); }
    break;
  }
  case "grid": return gridZones(0, 0, 6, 4, 3, 2, 0);
  // ---- camera / hand-tracking templates (a normalised camera source maps to a 4 m x 3 m scene by default) ----
  case "camera-grid": return gridZones(0, 0, 4, 3, 3, 3, 0);            // 9 cells of the camera image
  case "camera-quadrants": return gridZones(0, 0, 4, 3, 2, 2, 0);
  case "camera-columns": return gridZones(0, 0, 4, 3, 8, 1, 0);         // fader bank: 8 vertical strips
  case "camera-rows": return gridZones(0, 0, 4, 3, 1, 5, 0);            // 5 horizontal bands
  case "piano": case "piano2": {
    // white keys across the scene, black keys narrower on the upper half; black keys come last so they draw on top
    var octaves = name === "piano2" ? 2 : 1; var W = 4, H = 3;
    var whites = 7 * octaves; var kw = W / whites; var k = 0;
    var wn = ["C", "D", "E", "F", "G", "A", "B"]; var blackAfter = { C: "C#", D: "D#", F: "F#", G: "G#", A: "A#" };
    var blacks = [];
    for (var o = 0; o < octaves; o++) for (var wi = 0; wi < 7; wi++) {
      var x = -W / 2 + (o * 7 + wi + 0.5) * kw;
      var wz = makeZone("rect", k++); wz.name = wn[wi] + (4 + o); wz.shape.w = kw * 0.96; wz.shape.h = H; wz.pos = [x, 0, 0]; wz.color = "#e8e4d8"; zs.push(wz);
      var bname = blackAfter[wn[wi]];
      if (bname) blacks.push({ name: bname + (4 + o), x: x + kw / 2 });
    }
    for (var b = 0; b < blacks.length; b++) { var bz = makeZone("rect", k++); bz.name = blacks[b].name; bz.shape.w = kw * 0.6; bz.shape.h = H * 0.55; bz.pos = [blacks[b].x, H * 0.225, 0]; bz.color = "#3a3835"; zs.push(bz); }
    break;
  }
  case "xy-pad": {
    // one big zone whose per-entity u,v act as a 2D controller, plus 4 corner triggers
    var pad = makeZone("rect", 0); pad.name = "Pad"; pad.shape.w = 3; pad.shape.h = 2.2; pad.pos = [0, 0, 0]; zs.push(pad);
    var cn = ["Top left", "Top right", "Bottom left", "Bottom right"];
    for (var ci = 0; ci < 4; ci++) { var cz = makeZone("circle", ci + 1); cz.name = cn[ci]; cz.shape.r = 0.35; cz.pos = [(ci % 2 ? 1 : -1) * 1.6, (ci < 2 ? 1 : -1) * 1.1, 0]; zs.push(cz); }
    break;
  }
  case "swipe": {
    // two tripwires: left/right and up/down hand swipes in the camera image
    var sv = makeZone("line", 0); sv.name = "Swipe left/right"; sv.shape.points = [[0, -1.2], [0, 1.2]]; sv.pos = [0, 0, 0]; zs.push(sv);
    var sh = makeZone("line", 1); sh.name = "Swipe up/down"; sh.shape.points = [[-1.6, 0], [1.6, 0]]; sh.pos = [0, 0, 0]; zs.push(sh);
    break;
  }
  case "depth-layers": {
    // near / mid / far slabs in Z for 3D hand or body tracking (Leap, ZED, Kinect)
    var dn = ["Near", "Mid", "Far"]; var zr = [[0, 0.2], [0.2, 0.45], [0.45, 0.8]];
    for (var di = 0; di < 3; di++) { var dz = makeZone("box", di); dz.name = dn[di]; dz.shape.w = 1; dz.shape.h = 1; dz.shape.d = zr[di][1] - zr[di][0]; dz.pos = [0, 0, (zr[di][0] + zr[di][1]) / 2]; zs.push(dz); }
    break;
  }
  }
  return zs;
}
function gridZones(cx, cy, w, h, cols, rows, startIndex) {
  var zs = []; var cw = w / cols, ch = h / rows; var k = startIndex || 0;
  for (var r = 0; r < rows; r++) for (var c = 0; c < cols; c++) {
    var z = makeZone("rect", k++); z.name = "Cell " + (r + 1) + "x" + (c + 1); z.shape.w = cw; z.shape.h = ch;
    z.pos = [cx - w / 2 + cw * (c + 0.5), cy + h / 2 - ch * (r + 0.5), 0]; z.group = "grid"; zs.push(z);
  }
  return zs;
}
function sectorZones(cx, cy, rInner, rOuter, sectors, startIndex) {
  var zs = []; var k = startIndex || 0; var step = 2 * Math.PI / sectors;
  for (var s = 0; s < sectors; s++) {
    var a0 = s * step, a1 = (s + 1) * step; var pts = [];
    var n = 8;
    for (var i = 0; i <= n; i++) { var a = a0 + (a1 - a0) * i / n; pts.push([Math.cos(a) * rOuter, Math.sin(a) * rOuter]); }
    if (rInner > 0) for (var j = n; j >= 0; j--) { var b = a0 + (a1 - a0) * j / n; pts.push([Math.cos(b) * rInner, Math.sin(b) * rInner]); }
    else pts.push([0, 0]);
    var z = makeZone("polygon", k++); z.name = "Sector " + (s + 1); z.shape.points = pts; z.pos = [cx, cy, 0]; z.group = "sectors"; zs.push(z);
  }
  return zs;
}
// A full disc cut into `slices` equal wedges (slice 1 starts at +X and goes counter-clockwise).
function pieZones(cx, cy, r, slices, startIndex) {
  var zs = sectorZones(cx, cy, 0, r, slices, startIndex);
  for (var i = 0; i < zs.length; i++) { zs[i].name = "Slice " + (i + 1); zs[i].group = "pie"; }
  return zs;
}

