.pragma library
.import "Geometry.js" as Geom
.import "Ingest.js" as Ingest
.import "Model.js" as Model
// ZoneEngine.js — the stateful evaluation core of Tracking Zones.
// Pure JS: no Qt types, no wall clock. Time is injected (seconds).
//
//   var eng = new Engine(); eng.setDoc(doc);
//   var res = eng.update([{src:0, entities:[...calibrated canonical...]}, ...], t);
//   res = { zones:[...], events:[...], entities:[...], counts:[...], occupied:[...], activity:[...], tree:{...}, count:N, heatmap:[...] }

function Engine() {
  this.doc = Model.defaultDoc();
  this.entities = {};     // key -> runtime entity
  this.zoneRt = {};       // zone id -> runtime
  this.zoneOrder = [];    // active zone ids in doc order
  this.frame = 0;
  this.lastT = null;
  this.heat = null;
  this.sourceStats = {};  // per source key {frames, lastT, fps}
  this.recentEvents = [];
}

Engine.prototype.setDoc = function (doc) {
  this.doc = Model.normalizeDoc(doc);
  var seen = {};
  for (var i = 0; i < this.doc.zones.length; i++) {
    var z = this.doc.zones[i]; seen[z.id] = true;
    if (!this.zoneRt[z.id]) this.zoneRt[z.id] = newZoneRt(z);
    var rt = this.zoneRt[z.id]; rt.cfg = z; rt.frameCache = null; rt.boundsCache = null; rt.aabbCache = null;
  }
  for (var id in this.zoneRt) if (!seen[id]) delete this.zoneRt[id];
  // drop per-entity zone states for removed zones
  for (var k in this.entities) { var e = this.entities[k]; for (var zid in e.zs) if (!seen[zid]) delete e.zs[zid]; }
  this.calibrators = null; // calibration is applied by the process before update()
  var ws = this.doc.settings.worldTransform;
  this.worldFrame = (ws && (ws.pos[0] || ws.pos[1] || ws.pos[2] || ws.rot[0] || ws.rot[1] || ws.rot[2])) ? Geom.makeFrame(ws.pos, ws.rot, [1, 1, 1]) : null;
  var hm = this.doc.settings.heatmap;
  if (hm && hm.enabled) { var n = hm.cols * hm.rows; if (!this.heat || this.heat.length !== n) { this.heat = new Array(n); for (var q = 0; q < n; q++) this.heat[q] = 0; } }
  else this.heat = null;
};

function newZoneRt(z) {
  return { cfg: z, occupied: false, occupiedSince: -1, lastExitT: -1e9, lastEnterEventT: -1e9, idleSince: 0, count: 0, ids: [],
    entered: [], exited: [], crossIn: 0, crossOut: 0, visits: 0, unique: {}, uniqueCount: 0, dwellMax: 0, dwellMean: 0, firstInId: "", lastOutId: "",
    activity: 0, centroid: null, nearestId: "", nearestDist: -1, weight: 0, frameCache: null, boundsCache: null, frameVersion: -1, lastCount: 0, selected: [], allIds: [] };
}

Engine.prototype.resetCounters = function (zoneId) {
  for (var id in this.zoneRt) {
    if (zoneId && zoneId !== id) continue;
    var rt = this.zoneRt[id]; rt.crossIn = 0; rt.crossOut = 0; rt.visits = 0; rt.unique = {}; rt.uniqueCount = 0; rt.dwellMax = 0;
    for (var k in this.entities) { var zs = this.entities[k].zs[id]; if (zs) zs.crossed = false; }
  }
  if (!zoneId && this.heat) for (var q = 0; q < this.heat.length; q++) this.heat[q] = 0;
};
Engine.prototype.clearEntities = function () { this.entities = {}; };

// ---------- helpers ----------
function entityKey(srcIndex, src, id) { var p = src && src.idPrefix ? src.idPrefix : (typeof srcIndex === "string" ? srcIndex : "s" + srcIndex); return p + ":" + id; }
// source config by index (fixed inlets) or by name (named sources on the "Sources" inlet)
Engine.prototype.sourceCfg = function (src) { if (typeof src === "string") return Ingest.defaultSource(src); return this.doc.sources[src] || Ingest.defaultSource(src); };

function inSet(z, activeSet) { return !activeSet || !z.set || z.set === activeSet; }

function classMatch(filter, cls) {
  if (!filter) return true;
  var parts = String(filter).split(/[,;\s]+/).filter(function (s) { return s.length; });
  if (!parts.length) return true;
  for (var i = 0; i < parts.length; i++) if (parts[i] === cls) return true;
  return false;
}

Engine.prototype.anchorPoints = function (e, zone) {
  // returns array of world points to test; and a mode "min" (any) or "max" (all)
  var a = zone.anchor || "center";
  var kps = e.keypoints; var idx = kps ? Ingest.kpIndices(e.kpFormat) : null;
  function avg(list) { var sx = 0, sy = 0, sz = 0, n = 0; for (var i = 0; i < list.length; i++) { var k = kps[list[i]]; if (k && k[3] > 0.2) { sx += k[0]; sy += k[1]; sz += k[2]; n++; } } return n ? [[sx / n, sy / n, sz / n]] : null; }
  switch (a) {
  case "feet": {
    if (kps && idx) { var f = avg(idx.feet); if (f) return { pts: f, mode: "min" }; }
    var h = e.height || 0; return { pts: [[e.pos[0], e.pos[1], e.pos[2] - (e.size ? 0 : 0)]], mode: "min" };
  }
  case "head": {
    if (kps && idx) { var hd = avg(idx.head); if (hd) return { pts: hd, mode: "min" }; }
    return { pts: [[e.pos[0], e.pos[1], e.pos[2] + (e.height || 0)]], mode: "min" };
  }
  case "hands": {
    if (kps && idx) { var pts = []; var l = avg(idx.handL), r = avg(idx.handR); if (l) pts.push(l[0]); if (r) pts.push(r[0]); if (pts.length) return { pts: pts, mode: "min" }; }
    return { pts: [e.pos], mode: "min" };
  }
  case "any": case "all": {
    if (kps && kps.length) { var list = []; for (var i = 0; i < kps.length; i++) if (kps[i][3] > 0.2) list.push([kps[i][0], kps[i][1], kps[i][2]]); if (list.length) return { pts: list, mode: a === "any" ? "min" : "max" }; }
    return { pts: [e.pos], mode: "min" };
  }
  default:
    if (a.indexOf("kp:") === 0 && kps) { var ki = parseInt(a.substr(3)); if (kps[ki]) return { pts: [[kps[ki][0], kps[ki][1], kps[ki][2]]], mode: "min" }; }
    return { pts: [e.pos], mode: "min" };
  }
};

Engine.prototype.zoneFrame = function (rt) {
  var z = rt.cfg;
  if (z.frame === "world" || !z.frame) {
    if (!rt.frameCache) rt.frameCache = Geom.makeFrame(z.pos, z.rot, [1, 1, 1]);
    return rt.frameCache;
  }
  var local = Geom.makeFrame(z.pos, z.rot, [1, 1, 1]);
  if (z.frame === "entity") {
    var e = this.findEntity(z.frameRef);
    if (!e) return null;
    var yaw = (e.heading !== null && e.heading !== undefined) ? e.heading : 0;
    var parent = Geom.makeFrame(e.pos, [0, 0, yaw], [1, 1, 1]);
    return Geom.composeFrames(parent, local);
  }
  if (z.frame === "zone") {
    var prt = this.zoneRt[z.frameRef];
    if (!prt || prt === rt) return local;
    var pf = this.zoneFrame(prt); if (!pf) return null;
    return Geom.composeFrames(pf, local);
  }
  if (z.frame === "source") {
    var s = this.sourceCfg(isNaN(parseInt(z.frameRef)) ? String(z.frameRef) : parseInt(z.frameRef)); if (!s) return local;
    var tr = s.transform || {}; var sf = Geom.makeFrame(tr.pos, tr.rot, [1, 1, 1]);
    return Geom.composeFrames(sf, local);
  }
  return local;
};
Engine.prototype.findEntity = function (ref) {
  if (!ref) return null;
  if (this.entities[ref]) return this.entities[ref];
  // allow bare id match across sources
  for (var k in this.entities) { var e = this.entities[k]; if (e.id === ref || e.name === ref) return e; }
  return null;
};

function passFilters(z, e, t, srcIndex) {
  var f = z.filters; if (!f) return true;
  if (f.sources && f.sources.length && f.sources.indexOf(srcIndex) < 0 && f.sources.indexOf(String(srcIndex)) < 0) return false;
  if (f.cls && !classMatch(f.cls, e.cls)) return false;
  if (f.tags && f.tags.length && !classMatch(f.tags, e.tag)) return false;
  if (f.minConf > 0 && e.conf < f.minConf) return false;
  if (f.minAge > 0 && (t - e.firstSeen) < f.minAge) return false;
  if (f.heightMin > 0 && (e.height || 0) < f.heightMin) return false;
  if (f.heightMax > 0 && (e.height || 0) > f.heightMax) return false;
  if (f.speedMin > 0 && e.speed < f.speedMin) return false;
  if (f.speedMax > 0 && e.speed > f.speedMax) return false;
  return true;
}

// ---------- main update ----------
Engine.prototype.update = function (inputs, t) {
  var self = this;
  var dt = this.lastT === null ? 0 : Math.max(0, Math.min(0.5, t - this.lastT));
  this.lastT = t; this.frame++;
  var events = [];
  var doc = this.doc, settings = doc.settings;

  // 1. ingest
  for (var ii = 0; ii < inputs.length; ii++) {
    var inp = inputs[ii]; var si = inp.src; var src = this.sourceCfg(si);
    if (!inp.entities || !inp.entities.length) { if (inp.entities && inp.entities.length === 0) this.touchSource(si, t, 0); continue; }
    this.touchSource(si, t, inp.entities.length);
    var seenIdx = {};
    for (var j = 0; j < inp.entities.length; j++) {
      var ce = inp.entities[j];
      if (src.idMode === "index") ce.id = String(j);
      var key = entityKey(si, src, ce.id);
      if (seenIdx[key]) { key = key + "#" + j; }
      seenIdx[key] = true;
      var e = this.entities[key];
      var p = ce.pos;
      if (this.worldFrame) { p = Geom.toWorld(this.worldFrame, p); if (ce.vel) ce.vel = Geom.dirToWorld(this.worldFrame, ce.vel); }
      if (!e) {
        e = { key: key, id: ce.id, src: si, pos: p.slice(), rawPos: p.slice(), prevPos: p.slice(), vel: ce.vel ? ce.vel.slice() : [0, 0, 0], speed: 0, conf: ce.conf, cls: ce.cls || src.cls || "", tag: src.tag || "", name: ce.name,
          keypoints: ce.keypoints, kpFormat: ce.kpFormat, size: ce.size, height: ce.height, heading: ce.heading, firstSeen: t, lastSeen: t, frames: 1, state: "new", zs: {}, zones: [],
          filters: null, stationarySince: -1, stationary: false, stationaryFired: false, jumpRejects: 0, extra: ce.extra };
        this.entities[key] = e;
      } else {
        var jumped = false;
        if (src.maxJump > 0 && e.frames > 1) {
          if (Geom.dist(e.rawPos, p) > src.maxJump && e.jumpRejects < 3) { jumped = true; e.jumpRejects++; }
          else e.jumpRejects = 0;
        }
        e.prevPos = e.pos.slice();
        if (!jumped) {
          e.rawPos = p.slice();
          e.pos = p.slice();
          e.keypoints = ce.keypoints; e.kpFormat = ce.kpFormat; e.size = ce.size; e.height = ce.height; e.heading = ce.heading;
        }
        e.conf = ce.conf; if (ce.cls) e.cls = ce.cls; e.name = ce.name; e.extra = ce.extra;
        e.lastSeen = t; e.frames++; if (e.state === "new" && e.frames > 1) e.state = "active";
        if (ce.vel) e.vel = ce.vel.slice();
        else if (dt > 0) { e.vel = [(e.pos[0] - e.prevPos[0]) / dt, (e.pos[1] - e.prevPos[1]) / dt, (e.pos[2] - e.prevPos[2]) / dt]; }
      }
      // smoothing
      if (src.smoothing && src.smoothing.enabled) {
        if (!e.filters) e.filters = [new Geom.OneEuro(src.smoothing.minCutoff, src.smoothing.beta), new Geom.OneEuro(src.smoothing.minCutoff, src.smoothing.beta), new Geom.OneEuro(src.smoothing.minCutoff, src.smoothing.beta)];
        e.pos = [e.filters[0].filter(e.rawPos[0], t), e.filters[1].filter(e.rawPos[1], t), e.filters[2].filter(e.rawPos[2], t)];
      }
      e.speed = Geom.len(e.vel);
      // stationary detection (per-entity, zone-level thresholds use default 0.1 m/s)
      if (e.speed < 0.1) { if (e.stationarySince < 0) e.stationarySince = t; } else { e.stationarySince = -1; e.stationary = false; e.stationaryFired = false; }
    }
  }

  // 2. lost entities
  for (var k in this.entities) {
    var le = this.entities[k];
    var lsrc = this.sourceCfg(le.src); var timeout = lsrc && lsrc.lostTimeout !== undefined ? lsrc.lostTimeout : settings.lostTimeout;
    if (t - le.lastSeen > timeout) {
      // implicit exits
      for (var zid in le.zs) {
        var zs = le.zs[zid]; var zrt = this.zoneRt[zid];
        if (zs.inside && zrt) { zs.inside = false; this.onExit(zrt, le, zs, t, events, true); }
      }
      delete this.entities[k];
    } else if (t - le.lastSeen > dt * 1.5 + 1e-6 && dt > 0) {
      le.state = "lost"; // coasting (no prediction by default)
    }
  }

  // 3. zones: active list + frames
  var activeSet = settings.activeSet || "";
  this.zoneOrder = [];
  var excludeZones = [], includeZones = [], eventZones = [];
  for (var zi = 0; zi < doc.zones.length; zi++) {
    var zc = doc.zones[zi]; var rt = this.zoneRt[zc.id]; if (!rt) continue;
    rt.frameNow = (zc.enabled && inSet(zc, activeSet)) ? this.zoneFrame(rt) : null;
    rt.activeNow = !!rt.frameNow;
    this.zoneOrder.push(zc.id);
    if (!rt.activeNow) { this.deactivateZone(rt, t, events); continue; }
    if (zc.frame === "world" || !zc.frame) { if (!rt.aabbCache) { rt.aabbCache = worldAABB(rt); rt.padCache = zonePad(zc); } rt.aabb = rt.aabbCache; rt.pad = rt.padCache; }
    else { rt.aabb = worldAABB(rt); rt.pad = zonePad(zc); }
    if (zc.role === "exclude") excludeZones.push(rt); else if (zc.role === "include") includeZones.push(rt); else eventZones.push(rt);
    rt.entered = []; rt.exited = []; rt._insideList = []; rt._weightMax = 0; rt._sumSpeed = 0; rt._cx = 0; rt._cy = 0; rt._cz = 0; rt._nearD = Infinity; rt._nearId = "";
  }

  // 4. evaluate entities
  var entityList = [];
  for (var ek in this.entities) entityList.push(this.entities[ek]);
  for (var ei = 0; ei < entityList.length; ei++) {
    var en = entityList[ei];
    // masks
    var masked = false;
    for (var xi = 0; xi < excludeZones.length && !masked; xi++) { var xrt = excludeZones[xi]; if (passFilters(xrt.cfg, en, t, en.src) && this.sdFor(xrt, en) <= 0) masked = true; }
    if (!masked && includeZones.length) {
      var incl = false;
      for (var ni = 0; ni < includeZones.length && !incl; ni++) { var irt = includeZones[ni]; if (this.sdFor(irt, en) <= 0) incl = true; }
      masked = !incl;
    }
    en.masked = masked;
    for (var qi = 0; qi < eventZones.length; qi++) {
      var ert = eventZones[qi]; var z = ert.cfg;
      var zsE = en.zs[z.id];
      if (!zsE && ert.aabb && !usesKeypoints(z, en) && outsideAABB(ert.aabb, ert.pad, en.pos)) continue; // far away and no history: skip entirely
      if (!zsE) { zsE = en.zs[z.id] = { inside: false, sd: 1e9, enterT: -1, enterFrames: 0, exitT: -1, exitFrames: 0, enteredAt: -1, lastExitAt: -1e9, dwellFired: false, side: 0, sideFrames: 0, pendingSide: 0, crossed: false, holdUntil: -1, uvw: null, weight: 0 }; }
      var eligible = !masked && passFilters(z, en, t, en.src);
      if (z.shape.type === "line") { this.evalLine(ert, en, zsE, eligible, t, events); continue; }
      this.evalArea(ert, en, zsE, eligible, t, dt, events);
    }
  }

  // 5. zone aggregates + events
  var zonesOut = [], counts = [], occupied = [], activity = [], tree = {};
  for (var oi = 0; oi < this.zoneOrder.length; oi++) {
    var ort = this.zoneRt[this.zoneOrder[oi]]; var oz = ort.cfg;
    if (ort.activeNow && oz.role === "event") this.finishZone(ort, t, dt, events);
    var zo = this.zoneOutput(ort);
    zonesOut.push(zo);
    counts.push(ort.count); occupied.push(ort.occupied ? 1 : 0); activity.push(ort.activity);
    if (oz.outputs && oz.outputs.tree !== false) {
      tree[oz.name] = { occupied: ort.occupied, count: ort.count, ids: ort.ids.slice(), activity: ort.activity, nearest: ort.nearestDist, crossings_in: ort.crossIn, crossings_out: ort.crossOut, dwell_max: ort.dwellMax, weight: ort.weight, idle: ort.occupied ? 0 : (ort.idleSince >= 0 ? t - ort.idleSince : 0) };
    }
  }

  // 6. heatmap
  if (this.heat) this.updateHeat(entityList, dt);

  // 6b. entity <-> entity proximity
  var pairsOut = [];
  var px = settings.proximity;
  if (px && px.enabled && px.distance > 0) {
    if (!this.pairs) this.pairs = {};
    var live = {};
    for (var pa = 0; pa < entityList.length; pa++) {
      var ea = entityList[pa]; if (!this.entities[ea.key]) continue;
      for (var pb = pa + 1; pb < entityList.length; pb++) {
        var eb = entityList[pb]; if (!this.entities[eb.key]) continue;
        if (px.crossSourcesOnly && ea.src === eb.src) continue;
        var dd = Geom.dist(ea.pos, eb.pos);
        var pk = ea.key < eb.key ? ea.key + "|" + eb.key : eb.key + "|" + ea.key;
        var was = !!this.pairs[pk];
        var now = was ? dd <= px.distance * 1.1 : dd <= px.distance; // 10 % hysteresis
        if (now) { live[pk] = true; pairsOut.push({ a: ea.id, b: eb.id, a_key: ea.key, b_key: eb.key, dist: dd }); if (!was) { this.pairs[pk] = t; events.push({ t: t, type: "proximity", zone: "", zone_id: "", id: ea.id, other: eb.id, src: ea.src, dist: dd, state: "start" }); } }
        else if (was) { events.push({ t: t, type: "proximity", zone: "", zone_id: "", id: ea.id, other: eb.id, src: ea.src, dist: dd, state: "end", duration: t - this.pairs[pk] }); }
      }
    }
    for (var pk2 in this.pairs) if (!live[pk2]) delete this.pairs[pk2];
  }

  // 7. entity outputs
  var entOut = [];
  for (var oe = 0; oe < entityList.length; oe++) {
    var ee = entityList[oe]; if (!this.entities[ee.key]) continue;
    var zl = [], zd = {};
    for (var zk in ee.zs) { var st = ee.zs[zk]; if (st.inside) { var zcfg = this.zoneRt[zk] ? this.zoneRt[zk].cfg : null; zl.push(zcfg ? zcfg.name : zk); if (st.uvw) zd[zcfg ? zcfg.name : zk] = { u: st.uvw.u, v: st.uvw.v, w: st.uvw.w, dist: -st.sd, dwell: st.enteredAt >= 0 ? t - st.enteredAt : 0, progress: st.uvw.progress !== undefined ? st.uvw.progress : 0, offset: st.uvw.offset || 0, weight: st.weight }; } }
    ee.zones = zl;
    entOut.push({ id: ee.id, key: ee.key, src: ee.src, pos: ee.pos, vel: ee.vel, speed: ee.speed, conf: ee.conf, cls: ee.cls, name: ee.name, state: ee.state, age: t - ee.firstSeen, height: ee.height || 0, size: ee.size || null, heading: ee.heading === null || ee.heading === undefined ? 0 : ee.heading, stationary: ee.stationary, masked: ee.masked, zones: zl, zone_data: zd });
  }
  // 8. event filtering: the state machines above always run in full, only the *reporting* is
  // filtered — the global per-type switches first, then the zone's own opt-outs.
  var ef = settings.events;
  if (events.length && ef) {
    var kept = [];
    for (var fi = 0; fi < events.length; fi++) {
      var fe = events[fi];
      if (ef[fe.type] === false) continue;
      if (fe.zone_id) { var frt = this.zoneRt[fe.zone_id]; var zev = frt && frt.cfg.events; if (zev && zev[fe.type] === false) continue; }
      kept.push(fe);
    }
    events = kept;
  }
  this.recentEvents = this.recentEvents.concat(events); if (this.recentEvents.length > 200) this.recentEvents.splice(0, this.recentEvents.length - 200);
  return { t: t, zones: zonesOut, events: events, entities: entOut, counts: counts, occupied: occupied, activity: activity, tree: tree, count: entOut.length, heatmap: this.heat ? this.heat.slice() : [], pairs: pairsOut };
};

Engine.prototype.touchSource = function (si, t, n) {
  var sk = String(si); var s = this.sourceStats[sk]; if (!s) s = this.sourceStats[sk] = { frames: 0, lastT: -1, fps: 0, n: 0, lastCount: 0 };
  if (s.lastT >= 0 && t > s.lastT) { var inst = 1 / (t - s.lastT); s.fps = s.fps ? s.fps * 0.9 + inst * 0.1 : inst; }
  s.lastT = t; s.frames++; s.lastCount = n;
};

// world-space axis-aligned bounds of a zone (xy from the 4/8 transformed corners; z from the band)
function worldAABB(rt) {
  var b = Geom.shapeBounds(rt.cfg.shape); var f = rt.frameNow;
  var zUnbounded = b[2] < -1e5 || b[5] > 1e5;
  var zs = zUnbounded ? [0] : [b[2], b[5]];
  var out = [Infinity, Infinity, Infinity, -Infinity, -Infinity, -Infinity];
  for (var i = 0; i < 4; i++) {
    var x = (i & 1) ? b[3] : b[0], y = (i & 2) ? b[4] : b[1];
    for (var j = 0; j < zs.length; j++) {
      var w = Geom.toWorld(f, [x, y, zs[j]]);
      if (w[0] < out[0]) out[0] = w[0]; if (w[1] < out[1]) out[1] = w[1]; if (w[2] < out[2]) out[2] = w[2];
      if (w[0] > out[3]) out[3] = w[0]; if (w[1] > out[4]) out[4] = w[1]; if (w[2] > out[5]) out[5] = w[2];
    }
  }
  if (zUnbounded) { out[2] = -1e9; out[5] = 1e9; }
  return out;
}
function zonePad(z) {
  var pad = ((z.hysteresis && z.hysteresis.margin) || 0) + 0.05;
  if (z.containment === "radius") pad += (z.radius || 0);
  if (z.containment === "bbox") pad += 2;
  if (z.soft && z.soft.enabled) pad += (z.soft.falloff || 0.5);
  if (z.anchor && z.anchor !== "center") pad += 1.5;
  if (z.shape.type === "line") pad += 3; // side tracking must start well before the crossing
  return pad;
}
function outsideAABB(aabb, pad, p) {
  return p[0] < aabb[0] - pad || p[0] > aabb[3] + pad || p[1] < aabb[1] - pad || p[1] > aabb[4] + pad || p[2] < aabb[2] - pad || p[2] > aabb[5] + pad;
}
function usesKeypoints(z, e) { return e.keypoints && z.anchor && z.anchor !== "center"; }

Engine.prototype.sdFor = function (rt, e) {
  var f = rt.frameNow; if (!f) return 1e9;
  var z = rt.cfg;
  if (rt.aabb && !usesKeypoints(z, e) && outsideAABB(rt.aabb, rt.pad, e.pos)) return 1e9;
  if ((z.anchor === "center" || !z.anchor || !e.keypoints) && (!z.anchor || z.anchor.indexOf("kp:") !== 0)) {
    // fast path: single point
    var pt = e.pos;
    if (z.anchor === "head") pt = [e.pos[0], e.pos[1], e.pos[2] + (e.height || 0)];
    var lp0 = Geom.toLocal(f, pt);
    var sd0 = Geom.shapeSDF(z.shape, lp0);
    if (z.containment === "radius") sd0 -= (z.radius || 0);
    else if (z.containment === "bbox" && e.size) sd0 -= Math.max(e.size[0], e.size[1]) * 0.5;
    return sd0;
  }
  var ap = this.anchorPoints(e, rt.cfg);
  var best = ap.mode === "min" ? Infinity : -Infinity;
  for (var i = 0; i < ap.pts.length; i++) {
    var lp = Geom.toLocal(f, ap.pts[i]);
    var sd = Geom.shapeSDF(rt.cfg.shape, lp);
    if (ap.mode === "min") { if (sd < best) best = sd; } else { if (sd > best) best = sd; }
  }
  if (rt.cfg.containment === "radius") best -= (rt.cfg.radius || 0);
  else if (rt.cfg.containment === "bbox" && e.size) best -= Math.max(e.size[0], e.size[1]) * 0.5;
  return best;
};

Engine.prototype.evalArea = function (rt, e, zs, eligible, t, dt, events) {
  var z = rt.cfg; var hy = z.hysteresis || {};
  var f = rt.frameNow;
  var sd = eligible ? this.sdFor(rt, e) : 1e9;
  zs.sd = sd;
  var margin = hy.margin || 0;
  if (!zs.inside) {
    if (sd <= 0) {
      if (zs.enterT < 0) { zs.enterT = t; zs.enterFrames = 0; }
      zs.enterFrames++;
      var okMs = (t - zs.enterT) * 1000 >= (hy.enterMs || 0);
      var okFr = zs.enterFrames >= (hy.enterFrames || 1);
      if (okMs && okFr) {
        zs.inside = true; zs.enteredAt = t; zs.exitT = -1; zs.exitFrames = 0; zs.dwellFired = false; zs.holdUntil = -1;
        this.onEnter(rt, e, zs, t, events);
      }
    } else { zs.enterT = -1; zs.enterFrames = 0; }
  } else {
    var outside = sd > margin;
    if (outside) {
      if (zs.exitT < 0) { zs.exitT = t; zs.exitFrames = 0; }
      zs.exitFrames++;
      var okMs2 = (t - zs.exitT) * 1000 >= (hy.exitMs || 0);
      var okFr2 = zs.exitFrames >= (hy.exitFrames || 1);
      if (okMs2 && okFr2) {
        if ((hy.holdMs || 0) > 0) { if (zs.holdUntil < 0) zs.holdUntil = t + hy.holdMs / 1000; if (t >= zs.holdUntil) { zs.inside = false; this.onExit(rt, e, zs, t, events, false); } }
        else { zs.inside = false; this.onExit(rt, e, zs, t, events, false); }
      }
    } else { zs.exitT = -1; zs.exitFrames = 0; zs.holdUntil = -1; }
  }
  // soft weight
  if (z.soft && z.soft.enabled) { var fo = z.soft.falloff || 0.5; zs.weight = sd <= 0 ? 1 : Math.max(0, 1 - sd / fo); } else zs.weight = zs.inside ? 1 : 0;
  if (zs.inside) {
    // per-id data
    var lp = Geom.toLocal(f, e.pos);
    zs.uvw = Geom.shapeUVW(z.shape, lp);
    rt._insideList.push(e);
    rt._sumSpeed += e.speed; rt._cx += e.pos[0]; rt._cy += e.pos[1]; rt._cz += e.pos[2];
    // dwell
    var dwell = t - zs.enteredAt;
    if (z.dwell && z.dwell.loiterS > 0 && !zs.dwellFired && dwell >= z.dwell.loiterS) { zs.dwellFired = true; events.push(mkEvent(t, "dwell", z, e, { dwell: dwell })); }
    // stationary in zone
    var st = z.stationary || {};
    if (st.timeS > 0 && e.stationarySince >= 0 && e.speed < (st.speed || 0.1) && (t - e.stationarySince) >= st.timeS) { if (!e.stationary) { e.stationary = true; } if (!zs.stationaryFired) { zs.stationaryFired = true; events.push(mkEvent(t, "stationary", z, e, {})); } }
    else if (e.stationarySince < 0) zs.stationaryFired = false;
  }
  if (zs.weight > rt._weightMax) rt._weightMax = zs.weight;
  var dc = Math.abs(sd); // distance to boundary as proxy for nearest
  if (sd < rt._nearD && eligible) { rt._nearD = sd; rt._nearId = e.id; }
};

Engine.prototype.evalLine = function (rt, e, zs, eligible, t, events) {
  var z = rt.cfg; var f = rt.frameNow; var sh = z.shape;
  if (!eligible) { zs.side = 0; zs.sideFrames = 0; zs.pendingSide = 0; zs.inside = false; return; }
  var ap = this.anchorPoints(e, z);
  var lp = Geom.toLocal(f, ap.pts[0]);
  if (sh.useZ && (lp[2] < (sh.zmin || 0) || lp[2] > (sh.zmax === undefined ? 2 : sh.zmax))) { return; }
  var a = sh.points[0], b = sh.points[1];
  var ls = Geom.lineSide(a, b, lp[0], lp[1], sh.extended);
  zs.sd = Geom.shapeSDF2D(sh, lp[0], lp[1]);
  zs.inside = false;
  var side = ls.side;
  if (side === 0) return;
  if (zs.side === 0) { zs.side = side; zs.sideFrames = 0; zs.within = ls.within; return; }
  if (side !== zs.side) {
    // candidate crossing
    if (zs.pendingSide !== side) { zs.pendingSide = side; zs.sideFrames = 0; }
    zs.sideFrames++;
    var need = (z.line && z.line.confirmFrames) || 1;
    if (zs.sideFrames >= need) {
      var within = ls.within || zs.within;
      var dir = side > 0 ? "in" : "out"; // crossing towards +side (left of a->b) = "in"
      var allowed = sh.direction === "both" || (sh.direction === "a_to_b" && dir === "in") || (sh.direction === "b_to_a" && dir === "out");
      if (within && allowed && !(z.line && z.line.countOnce && zs.crossed)) {
        if (dir === "in") rt.crossIn++; else rt.crossOut++;
        zs.crossed = true;
        events.push(mkEvent(t, "cross", z, e, { direction: dir, in: rt.crossIn, out: rt.crossOut }));
        rt.lastEventT = t; rt.flash = t;
      }
      zs.side = side; zs.pendingSide = 0; zs.sideFrames = 0;
    }
  } else { zs.pendingSide = 0; zs.sideFrames = 0; zs.within = ls.within; }
  // near-band presence for display
  if (zs.sd <= 0) { rt._insideList.push(e); }
};

Engine.prototype.onEnter = function (rt, e, zs, t, events) {
  var z = rt.cfg; var hy = z.hysteresis || {};
  rt.entered.push(e.id);
  rt.visits++;
  if (!rt.unique[e.key]) { rt.unique[e.key] = true; rt.uniqueCount++; }
  var cooled = (t - zs.lastExitAt) * 1000 >= (hy.cooldownMs || 0);
  if (cooled) events.push(mkEvent(t, "enter", z, e, {}));
  var prev = [];
  for (var zk in e.zs) { if (zk !== z.id && e.zs[zk].inside) { var prt = this.zoneRt[zk]; prev.push(prt ? prt.cfg.name : zk); } }
  if (prev.length && cooled) events.push(mkEvent(t, "transition", z, e, { from: prev }));
  rt.lastEventT = t;
};
Engine.prototype.onExit = function (rt, e, zs, t, events, lost) {
  var z = rt.cfg; var dwell = zs.enteredAt >= 0 ? t - zs.enteredAt : 0;
  zs.lastExitAt = t; zs.enterT = -1; zs.enterFrames = 0; zs.exitT = -1; zs.exitFrames = 0; zs.holdUntil = -1;
  if (dwell > rt.dwellMax) rt.dwellMax = dwell;
  rt.exited.push(e.id);
  rt.lastOutId = e.id;
  events.push(mkEvent(t, "exit", z, e, { dwell: dwell, lost: !!lost }));
  rt.lastEventT = t; rt.lastExitT = t;
};

Engine.prototype.finishZone = function (rt, t, dt, events) {
  var z = rt.cfg;
  // selection policy
  var list = rt._insideList;
  var sel = list;
  var pol = z.selection || "all";
  if (pol !== "all" && list.length) {
    var f = rt.frameNow;
    var arr = list.slice();
    if (pol === "nearest") { arr.sort(function (a, b) { return Geom.dist(a.pos, f.pos) - Geom.dist(b.pos, f.pos); }); sel = arr.slice(0, Math.max(1, z.maxN || 1)); }
    else if (pol === "first_in") { arr.sort(function (a, b) { return a.zs[z.id].enteredAt - b.zs[z.id].enteredAt; }); sel = arr.slice(0, Math.max(1, z.maxN || 1)); }
    else if (pol === "last_in") { arr.sort(function (a, b) { return b.zs[z.id].enteredAt - a.zs[z.id].enteredAt; }); sel = arr.slice(0, Math.max(1, z.maxN || 1)); }
    else if (pol === "max_n") { arr.sort(function (a, b) { return a.zs[z.id].enteredAt - b.zs[z.id].enteredAt; }); sel = arr.slice(0, Math.max(1, z.maxN || 1)); }
  }
  if (z.filters && z.filters.maxCount > 0 && sel.length > z.filters.maxCount) sel = sel.slice(0, z.filters.maxCount);
  rt.selected = sel;
  var n = list.length;
  rt.count = n;
  rt.ids = sel.map(function (e) { return e.id; });
  rt.allIds = list.map(function (e) { return e.id; });
  rt.activity = n ? rt._sumSpeed / n : 0;
  rt.centroid = n ? [rt._cx / n, rt._cy / n, rt._cz / n] : null;
  rt.nearestId = (isFinite(rt._nearD) && rt._nearD < 1e8) ? rt._nearId : ""; rt.nearestDist = (isFinite(rt._nearD) && rt._nearD < 1e8) ? rt._nearD : -1;
  rt.weight = rt._weightMax;
  var dm = 0, ds = 0;
  for (var i = 0; i < list.length; i++) { var ea = list[i].zs[z.id].enteredAt; if (ea < 0) continue; var d = t - ea; if (d > dm) dm = d; ds += d; }
  rt.dwellNow = dm; rt.dwellMean = n ? ds / n : 0;
  if (dm > rt.dwellMax) rt.dwellMax = dm;
  // first in
  if (n && !rt.firstInId) { var first = list.slice().sort(function (a, b) { return a.zs[z.id].enteredAt - b.zs[z.id].enteredAt; })[0]; rt.firstInId = first.id; events.push(mkEvent(t, "first_in", z, first, {})); }
  // occupancy with set/clear thresholds
  var occ = z.occupancy || {}; var setT = occ.setThreshold || 1, clrT = occ.clearThreshold || 0;
  if (!rt.occupied && n >= setT) { rt.occupied = true; rt.occupiedSince = t; events.push(mkEvent(t, "occupied", z, null, { count: n })); }
  else if (rt.occupied && n <= clrT) { rt.occupied = false; rt.idleSince = t; rt.firstInId = ""; events.push(mkEvent(t, "empty", z, null, { count: n })); if (rt.lastOutId) events.push(mkEvent(t, "last_out", z, null, { id: rt.lastOutId })); }
  if (occ.capacity > 0) {
    if (n > occ.capacity && !rt.overCap) { rt.overCap = true; events.push(mkEvent(t, "capacity", z, null, { count: n, capacity: occ.capacity, over: true })); }
    else if (n <= occ.capacity && rt.overCap) { rt.overCap = false; events.push(mkEvent(t, "capacity", z, null, { count: n, capacity: occ.capacity, over: false })); }
  }
  if (n !== rt.lastCount) { events.push(mkEvent(t, "count", z, null, { count: n, previous: rt.lastCount === undefined ? 0 : rt.lastCount })); rt.lastCount = n; }
  if (rt.idleSince === 0 && !rt.occupied) rt.idleSince = t;
};
Engine.prototype.deactivateZone = function (rt, t, events) {
  // zone disabled: release everybody silently (no events), reset live aggregates
  var had = false;
  for (var k in this.entities) { var zs = this.entities[k].zs[rt.cfg.id]; if (zs && zs.inside) { zs.inside = false; zs.enterT = -1; zs.enterFrames = 0; had = true; } }
  rt.count = 0; rt.ids = []; rt.allIds = []; rt.entered = []; rt.exited = []; rt.activity = 0; rt.centroid = null; rt.weight = 0; rt.selected = [];
  if (rt.occupied) { rt.occupied = false; rt.idleSince = t; }
  rt.lastCount = 0; rt.firstInId = "";
};

Engine.prototype.zoneOutput = function (rt) {
  var z = rt.cfg; var t = this.lastT;
  var out = { id: z.id, name: z.name, type: z.shape.type, active: !!rt.activeNow, occupied: !!rt.occupied, count: rt.count || 0, ids: (rt.ids || []).slice(), all_ids: (rt.allIds || []).slice(), entered: (rt.entered || []).slice(), exited: (rt.exited || []).slice(),
    first_in: rt.firstInId || "", last_out: rt.lastOutId || "", centroid: rt.centroid || [0, 0, 0], nearest: rt.nearestId || "", nearest_dist: rt.nearestDist === undefined ? -1 : rt.nearestDist,
    activity: rt.activity || 0, weight: rt.weight || 0, idle: rt.occupied ? 0 : (rt.idleSince > 0 ? t - rt.idleSince : 0), occupied_for: rt.occupied ? t - rt.occupiedSince : 0,
    dwell_now: rt.dwellNow || 0, dwell_max: rt.dwellMax || 0, dwell_mean: rt.dwellMean || 0, crossings_in: rt.crossIn || 0, crossings_out: rt.crossOut || 0, crossings: (rt.crossIn || 0) - (rt.crossOut || 0), visits: rt.visits || 0, unique: rt.uniqueCount || 0 };
  if (z.outputs && z.outputs.perId !== false && rt.selected && rt.selected.length) {
    var per = [];
    for (var i = 0; i < rt.selected.length; i++) {
      var e = rt.selected[i]; var zs = e.zs[z.id]; if (!zs) continue;
      var u = zs.uvw || {};
      per.push({ id: e.id, u: u.u === undefined ? 0 : u.u, v: u.v === undefined ? 0 : u.v, w: u.w === undefined ? 0 : u.w, r: u.r || 0, angle: u.angle || 0, dist: -zs.sd, dwell: zs.enteredAt >= 0 ? t - zs.enteredAt : 0, progress: u.progress || 0, offset: u.offset || 0, weight: zs.weight, speed: e.speed, pos: e.pos });
    }
    out.per_id = per;
  }
  return out;
};

Engine.prototype.updateHeat = function (list, dt) {
  var hm = this.doc.settings.heatmap; var decay = Math.exp(-(hm.decay || 0) * dt);
  for (var i = 0; i < this.heat.length; i++) this.heat[i] *= decay;
  for (var j = 0; j < list.length; j++) {
    var p = list[j].pos;
    var u = (p[0] - (hm.x - hm.w / 2)) / hm.w, v = (p[1] - (hm.y - hm.h / 2)) / hm.h;
    if (u < 0 || u >= 1 || v < 0 || v >= 1) continue;
    var c = Math.floor(u * hm.cols), r = Math.floor((1 - v) * hm.rows);
    this.heat[r * hm.cols + c] += dt;
  }
};

// Payload of the simple per-event outlets (Enter / Leave / Dwell / Cross / Occupancy).
// fmt: "zone" = zone name string, "id" = entity id string, "pair" = [zone, id],
//      "map" = compact map with the fields that matter for the type, "full" = the raw event.
function formatEvent(ev, fmt) {
  var occ = ev.type === "occupied" || ev.type === "empty";
  switch (fmt) {
  case "zone": return ev.zone;
  case "id": return occ ? ev.zone : ev.id;
  case "pair": return occ ? [ev.zone, ev.type === "occupied" ? 1 : 0] : [ev.zone, ev.id];
  case "full": return ev;
  default: {
    if (occ) return { zone: ev.zone, occupied: ev.type === "occupied", count: ev.count || 0 };
    var m = { zone: ev.zone, id: ev.id, type: ev.type };
    if (ev.src !== undefined && ev.src !== -1) m.src = ev.src;
    if (ev.dwell !== undefined) m.dwell = ev.dwell;
    if (ev.direction !== undefined) { m.direction = ev.direction; m["in"] = ev["in"]; m.out = ev.out; }
    if (ev.from !== undefined) m.from = ev.from;
    if (ev.lost) m.lost = true;
    return m;
  }
  }
}

// Payload of the Location outlet: where every tracked entity currently is.
// entities = res.entities. cfg = settings.outputs.location:
//   all: false = one zone per entity (the last one in draw order, i.e. topmost), true = the full list
//   includeOutside: also report entities that are in no zone ("" or [])
//   format: "map" = {id: zone}, "list" = [[id, zone], ...], "zone" = the first entity's zone alone
function locationOutput(entities, cfg) {
  var all = !!cfg.all;
  var rows = [];
  for (var i = 0; i < entities.length; i++) {
    var e = entities[i]; var zs = e.zones || [];
    if (!zs.length && !cfg.includeOutside) continue;
    rows.push([e.id, all ? zs.slice() : (zs.length ? zs[zs.length - 1] : "")]);
  }
  var fmt = cfg.format || "map";
  if (fmt === "zone") return rows.length ? rows[0][1] : (all ? [] : "");
  if (fmt === "list") return rows;
  var m = {};
  for (var j = 0; j < rows.length; j++) m[rows[j][0]] = rows[j][1];
  return m;
}

function mkEvent(t, type, z, e, data) {
  var ev = { t: t, type: type, zone: z.name, zone_id: z.id, id: e ? e.id : "", src: e ? e.src : -1 };
  if (data) for (var k in data) ev[k] = data[k];
  return ev;
}

// UI snapshot: compact state for the editor overlay
Engine.prototype.snapshot = function (res, prefs) {
  var wantKps = !!(prefs && prefs.keypoints);
  var ents = [];
  for (var i = 0; i < res.entities.length; i++) {
    var e = res.entities[i]; var re = this.entities[e.key];
    ents.push({ id: e.id, key: e.key, src: e.src, pos: e.pos, vel: e.vel, speed: e.speed, cls: e.cls, conf: e.conf, zones: e.zones, state: e.state, masked: e.masked, height: e.height, kps: (wantKps && re && re.keypoints) ? re.keypoints : null });
  }
  var zs = [];
  for (var j = 0; j < res.zones.length; j++) { var z = res.zones[j]; zs.push({ id: z.id, active: z.active, occupied: z.occupied, count: z.count, ids: z.ids, weight: z.weight, dwell_now: z.dwell_now, crossings_in: z.crossings_in, crossings_out: z.crossings_out, visits: z.visits, unique: z.unique, idle: z.idle, flash: this.zoneRt[z.id] && this.zoneRt[z.id].flash ? this.zoneRt[z.id].flash : -1 }); }
  return { t: res.t, entities: ents, zones: zs, events: res.events, sources: (function (st) { var o = {}; for (var k in st) o[k] = { fps: st[k].fps, lastT: st[k].lastT, n: st[k].lastCount }; return o; })(this.sourceStats), heatmap: res.heatmap, count: res.count };
};
