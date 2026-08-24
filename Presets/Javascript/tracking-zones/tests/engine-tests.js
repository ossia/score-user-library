// engine-tests.js — unit tests for the Tracking Zones engine.
// Run inside score's console engine:
//   score.exe --script "eval(Score.readFile('.../tests/engine-tests.js'))"
// Writes a report next to this file (engine-tests.out) and exits with 0/1 through a QML Timer.

(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var OUT = DIR + "tests/engine-tests.out";
  var log = [];
  function out(s) { log.push(s); console.log(s); }

  // ---- tiny module loader: turn a `.pragma library` / `.import` file into a namespace object ----
  var cache = {};
  function load(name) {
    if (cache[name]) return cache[name];
    var src = Score.readFile(DIR + name);
    if (!src) throw new Error("cannot read " + name);
    var lines = src.split("\n");
    var deps = [], body = [];
    for (var i = 0; i < lines.length; i++) {
      var l = lines[i];
      var m = l.match(/^\.import\s+"([^"]+)"\s+as\s+(\w+)/);
      if (m) { deps.push({ file: m[1], as: m[2] }); continue; }
      if (/^\.pragma/.test(l)) continue;
      body.push(l);
    }
    var code = body.join("\n");
    var names = {};
    var re = /^(?:function\s+(\w+)\s*\(|var\s+(\w+)\s*=)/gm, mm;
    while ((mm = re.exec(code)) !== null) names[mm[1] || mm[2]] = true;
    var exportsList = Object.keys(names).map(function (n) { return n + ":" + n; }).join(",");
    var params = deps.map(function (d) { return d.as; });
    var fn = new Function(params.join(","), code + "\nreturn {" + exportsList + "};");
    var args = deps.map(function (d) { return load(d.file); });
    var ns = fn.apply(null, args);
    cache[name] = ns;
    return ns;
  }

  var Geom, Ingest, Model, ZE;
  var passed = 0, failed = 0, current = "";
  function test(name, fn) { current = name; try { fn(); passed++; out("PASS " + name); } catch (e) { failed++; out("FAIL " + name + ": " + (e && e.message ? e.message : e) + (e && e.stack ? "\n" + e.stack : "")); } }
  function ok(c, msg) { if (!c) throw new Error(msg || "assertion failed"); }
  function eq(a, b, msg) { if (a !== b) throw new Error((msg || "") + " expected " + JSON.stringify(b) + " got " + JSON.stringify(a)); }
  function near(a, b, eps, msg) { if (Math.abs(a - b) > (eps || 1e-6)) throw new Error((msg || "") + " expected ~" + b + " got " + a); }
  function count(events, type) { var n = 0; for (var i = 0; i < events.length; i++) if (events[i].type === type) n++; return n; }

  try {
    Geom = load("Geometry.js"); Ingest = load("Ingest.js"); Model = load("Model.js"); ZE = load("ZoneEngine.js");
    out("modules loaded");
  } catch (e) { out("LOAD FAIL " + e + " " + (e.stack || "")); failed++; }

  // ---------------- Geometry ----------------
  test("rect sdf inside/outside", function () {
    var s = { type: "rect", w: 2, h: 2 };
    near(Geom.shapeSDF(s, [0, 0, 0]), -1);
    near(Geom.shapeSDF(s, [2, 0, 0]), 1);
    near(Geom.shapeSDF(s, [1, 1, 0]), 0);
  });
  test("circle/sphere/cylinder/box sdf", function () {
    near(Geom.shapeSDF({ type: "circle", r: 1 }, [0.5, 0, 0]), -0.5);
    near(Geom.shapeSDF({ type: "sphere", r: 1 }, [0, 0, 2]), 1);
    near(Geom.shapeSDF({ type: "cylinder", r: 1, d: 2 }, [0, 0, 0]), -1);
    near(Geom.shapeSDF({ type: "cylinder", r: 1, d: 2 }, [0, 0, 1.5]), 0.5);
    near(Geom.shapeSDF({ type: "box", w: 2, h: 2, d: 2 }, [0, 0, 0]), -1);
    near(Geom.shapeSDF({ type: "box", w: 2, h: 2, d: 2 }, [0, 0, 3]), 2);
  });
  test("polygon sdf + z band", function () {
    var poly = { type: "polygon", points: [[-1, -1], [1, -1], [1, 1], [-1, 1]] };
    near(Geom.shapeSDF(poly, [0, 0, 0]), -1);
    near(Geom.shapeSDF(poly, [3, 0, 0]), 2);
    var prism = { type: "polygon", points: [[-1, -1], [1, -1], [1, 1], [-1, 1]], useZ: true, zmin: 0, zmax: 2 };
    ok(Geom.shapeSDF(prism, [0, 0, 1]) < 0, "inside prism");
    ok(Geom.shapeSDF(prism, [0, 0, 3]) > 0, "above prism");
    ok(Geom.shapeSDF(prism, [0, 0, -1]) > 0, "below prism");
  });
  test("concave polygon + self intersection", function () {
    var pts = [[0, 0], [4, 0], [4, 4], [2, 1], [0, 4]];
    ok(Geom.pointInPolygon(1, 0.5, pts));
    ok(!Geom.pointInPolygon(2, 3, pts));
    ok(!Geom.polygonSelfIntersects(pts));
    ok(Geom.polygonSelfIntersects([[0, 0], [2, 2], [2, 0], [0, 2]]));
  });
  test("frames: local/world roundtrip with rotation", function () {
    var f = Geom.makeFrame([1, 2, 3], [0, 0, 90], [1, 1, 1]);
    var w = Geom.toWorld(f, [1, 0, 0]);
    near(w[0], 1, 1e-9); near(w[1], 3, 1e-9); near(w[2], 3, 1e-9);
    var l = Geom.toLocal(f, w);
    near(l[0], 1); near(l[1], 0); near(l[2], 0);
  });
  test("uvw normalized", function () {
    var u = Geom.shapeUVW({ type: "rect", w: 4, h: 2 }, [1, 0.5, 0]);
    near(u.u, 0.75); near(u.v, 0.75);
  });
  test("path progress", function () {
    var p = Geom.pathProgress([[0, 0], [10, 0]], 5, 1);
    near(p.progress, 0.5); near(p.offset, 1);
  });
  test("line side", function () {
    var a = [0, 0], b = [2, 0];
    eq(Geom.lineSide(a, b, 1, 1, false).side, 1);
    eq(Geom.lineSide(a, b, 1, -1, false).side, -1);
    ok(!Geom.lineSide(a, b, 5, 1, false).within);
    ok(Geom.lineSide(a, b, 5, 1, true).within);
  });
  test("homography identity-ish", function () {
    var H = Geom.computeHomography([[0, 0], [1, 0], [1, 1], [0, 1]], [[0, 0], [4, 0], [4, 3], [0, 3]]);
    ok(H, "H computed");
    var p = Geom.applyHomography(H, 0.5, 0.5); near(p[0], 2, 1e-6); near(p[1], 1.5, 1e-6);
    var H2 = Geom.computeHomography([[0, 0], [1, 0], [1, 1], [0, 1]], [[1, 1], [3, 0.5], [3.5, 3], [0.5, 2.5]]);
    var q = Geom.applyHomography(H2, 1, 1); near(q[0], 3.5, 1e-6); near(q[1], 3, 1e-6);
  });
  test("one euro converges", function () {
    var f = new Geom.OneEuro(1.0, 0.0);
    var v = 0; for (var i = 0; i < 200; i++) v = f.filter(10, i * 0.016);
    near(v, 10, 0.05);
  });

  // ---------------- Ingest ----------------
  test("ingest: list of maps (point tracker style)", function () {
    var es = Ingest.parseEntities([{ id: 3, position: { x: 1, y: 2 }, velocity: { x: 0.5, y: 0 }, confidence: 0.9, state: "confirmed" }, { id: 4, position: [2, 2, 1] }], Ingest.defaultSource(0));
    eq(es.length, 2); eq(es[0].id, "3"); near(es[0].pos[0], 1); near(es[0].vel[0], 0.5); near(es[0].conf, 0.9); near(es[1].pos[2], 1);
  });
  test("ingest: bare vectors, flat floats, nested lists", function () {
    eq(Ingest.parseEntities([{ x: 1, y: 2 }, { x: 3, y: 4, z: 5 }], Ingest.defaultSource(0)).length, 2);
    var fl = Ingest.parseEntities([0, 0, 1, 1, 2, 2], Ingest.defaultSource(0)); eq(fl.length, 3); near(fl[2].pos[0], 2);
    var sub = Ingest.parseEntities([[1, 2], [3, 4, 5, 0.5]], Ingest.defaultSource(0)); eq(sub.length, 2); near(sub[1].conf, 0.5);
  });
  test("ingest: device subtree map (PSN-like)", function () {
    var raw = { "0": { active: true, id: 7, name: "perf", position: { x: 1, y: 0, z: 2 }, orientation: { x: 0, y: 0, z: 0 } }, "1": { active: false, id: 8, position: { x: 9, y: 9, z: 9 } }, "2": { active: true, position: { x: 2, y: 2, z: 0 } } };
    var es = Ingest.parseEntities(raw, Ingest.defaultSource(0));
    eq(es.length, 2, "inactive skipped"); eq(es[0].id, "7"); eq(es[1].id, "2");
  });
  test("ingest: onnx pose detection maps", function () {
    var poses = [{ keypoints: [{ x: 0.5, y: 0.5, z: 0, confidence: 0.9 }, { x: 0.6, y: 0.4, z: 0, confidence: 0.8 }], mean_confidence: 0.85, track_id: 2, box: { x: 0.4, y: 0.3, w: 0.2, h: 0.4 }, class_id: 0 }];
    var es = Ingest.parseEntities(poses, Ingest.defaultSource(0));
    eq(es.length, 1); eq(es[0].id, "2"); near(es[0].pos[0], 0.5); near(es[0].pos[1], 0.5); ok(es[0].keypoints && es[0].keypoints.length === 2); near(es[0].size[0], 0.2);
    var single = Ingest.parseEntities({ keypoints: [{ x: 0.1, y: 0.1, z: 0, confidence: 1 }], box: { x: 0, y: 0, w: 0.2, h: 0.2 }, track_id: -1 }, Ingest.defaultSource(0));
    eq(single.length, 1); eq(single[0].id, "0");
  });
  test("ingest: cv blob maps", function () {
    var es = Ingest.parseEntities([{ centroid: { x: 0.25, y: 0.75 }, area: 0.01, id: 5, age: 3 }], Ingest.defaultSource(0));
    eq(es.length, 1); eq(es[0].id, "5"); near(es[0].pos[1], 0.75);
  });
  test("ingest: data formats — points and boxes", function () {
    function srcFmt(f) { var s = Ingest.defaultSource(0); s.dataFormat = f; return s; }
    // 1) simple point lists
    var p1 = Ingest.parseEntities([1.5, 2.5], srcFmt("auto")); eq(p1.length, 1); near(p1[0].pos[0], 1.5);
    var p2 = Ingest.parseEntities([[0, 0], [1, 1], [2, 2]], srcFmt("auto")); eq(p2.length, 3);
    var p3 = Ingest.parseEntities([0, 0, 0, 1, 1, 1, 2, 2, 2], srcFmt("points3")); eq(p3.length, 3); near(p3[2].pos[2], 2);
    var p4 = Ingest.parseEntities([0, 0, 1, 1, 2, 2], srcFmt("points2")); eq(p4.length, 3, "6 floats as 3 xy points when forced");
    var p5 = Ingest.parseEntities([0, 0, 1, 1, 2, 2], srcFmt("points3")); eq(p5.length, 2, "6 floats as 2 xyz points when forced");
    // 2) bounding boxes
    var b1 = Ingest.parseEntities([[0, 0, 1, 2], [4, 4, 2, 2]], srcFmt("boxes_xywh"));
    eq(b1.length, 2); near(b1[0].pos[0], 0.5); near(b1[0].pos[1], 1); near(b1[0].size[0], 1); near(b1[0].size[1], 2); near(b1[1].pos[0], 5);
    var b2 = Ingest.parseEntities([0, 0, 1, 2, 4, 4, 6, 6], srcFmt("boxes_corners2"));
    eq(b2.length, 2); near(b2[0].pos[0], 0.5); near(b2[0].size[1], 2); near(b2[1].pos[0], 5); near(b2[1].size[0], 2);
    var b3 = Ingest.parseEntities([[0, 0, 0, 2, 2, 2]], srcFmt("boxes_corners3"));
    eq(b3.length, 1); near(b3[0].pos[0], 1); near(b3[0].pos[2], 1); near(b3[0].size[2], 2);
    var b4 = Ingest.parseEntities([0, 0, 0, 2, 2, 2, 10, 10, 10, 12, 14, 13], srcFmt("boxes_corners3"));
    eq(b4.length, 2); near(b4[1].pos[0], 11); near(b4[1].size[1], 4);
    // 3) box-style maps (self-describing, no format needed)
    var m1 = Ingest.parseEntities([{ id: 1, box: { x1: 0, y1: 0, x2: 2, y2: 4 } }], srcFmt("auto"));
    eq(m1.length, 1); near(m1[0].pos[0], 1); near(m1[0].size[1], 4);
    var m2 = Ingest.parseEntities([{ bbox: { xmin: -1, ymin: -1, xmax: 1, ymax: 1, zmin: 0, zmax: 2 } }], srcFmt("auto"));
    eq(m2.length, 1); near(m2[0].pos[2], 1); near(m2[0].size[2], 2);
    var m3 = Ingest.parseEntities([{ bbox: [0, 0, 0, 2, 2, 2] }], srcFmt("auto"));
    eq(m3.length, 1); near(m3[0].pos[1], 1); near(m3[0].size[0], 2);
    // engine end-to-end: xywh boxes with bbox containment overlap a zone
    var z = Model.makeZone("rect", 0); z.shape.w = 2; z.shape.h = 2; z.containment = "bbox";
    var d = mkDoc([z]); var eng = new ZE.Engine(); eng.setDoc(d);
    var ents = Ingest.parseEntities([[0.7, -0.5, 1, 1]], srcFmt("boxes_xywh"));   // centre (1.2,0) outside, but the box overlaps the zone
    var res = run(eng, [ents, ents]);
    eq(res[1].zones[0].count, 1, "bbox containment counts the overlapping box");
  });
  test("ingest: pose keypoints — blazepose 33, sparse yolo, calibration", function () {
    // full BlazePose-33 landmark list ({x,y,z,visibility})
    var kps33 = []; for (var i = 0; i < 33; i++) kps33.push({ x: 0.5, y: 0.5, z: 0, visibility: 0.95 });
    kps33[0] = { x: 0.5, y: 0.2, z: 0, visibility: 0.99 };    // nose
    kps33[27] = { x: 0.48, y: 0.8, z: 0, visibility: 0.9 };   // ankles
    kps33[28] = { x: 0.52, y: 0.8, z: 0, visibility: 0.9 };
    var es = Ingest.parseEntities([{ keypoints: kps33, track_id: 5, box: { x: 0.3, y: 0.2, w: 0.4, h: 0.6 }, mean_confidence: 0.9 }], Ingest.defaultSource(0));
    eq(es.length, 1); eq(es[0].kpFormat, "blazepose"); eq(es[0].keypoints.length, 33); near(es[0].keypoints[27][1], 0.8); near(es[0].pos[0], 0.5);
    var idx = Ingest.kpIndices("blazepose"); eq(idx.feet[0], 27);
    // sparse indexed keypoints (legacy YOLO pose {kp,x,y}) scatter to their indices
    var sp = Ingest.parseEntities([{ keypoints: [{ kp: 15, x: 1, y: 2 }, { kp: 16, x: 1.2, y: 2 }], id: 1 }], Ingest.defaultSource(0));
    eq(sp[0].keypoints.length, 17); near(sp[0].keypoints[15][0], 1); near(sp[0].keypoints[16][0], 1.2); near(sp[0].keypoints[3][3], 0, 1e-9, "missing kp has conf 0");
    // keypoints go through the normalized-origin calibration like positions
    var s = Ingest.defaultSource(0); s.originMode = "normalized"; s.scene = { w: 4, h: 3 };
    var cal = Ingest.makeCalibrator(s);
    var e2 = Ingest.parseEntities([{ keypoints: kps33, track_id: 5 }], s)[0]; cal.apply(e2);
    near(e2.keypoints[0][0], 0, 1e-6); near(e2.keypoints[0][1], 0.9, 1e-6);      // nose (0.5,0.2) -> (0, 0.9)
    near(e2.keypoints[27][1], -0.9, 1e-4);                                        // ankle (~0.8) -> -0.9
    // feet anchor picks the calibrated ankles through the engine
    var z = Model.makeZone("circle", 0); z.shape.r = 0.4; z.pos = [0, -0.9, 0]; z.anchor = "feet";
    var zc = Model.makeZone("circle", 1); zc.shape.r = 0.4; zc.pos = [0, -0.9, 0]; zc.anchor = "center";
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z, zc]));
    var res = run(eng, [[e2], [e2]]);
    eq(res[1].zones[0].count, 1, "feet anchor inside the feet zone");
    eq(res[1].zones[1].count, 0, "centre anchor stays outside");
  });
  test("calibration: normalized to scene metres", function () {
    var s = Ingest.defaultSource(0); s.originMode = "normalized"; s.scene = { w: 4, h: 2 }; s.transform.pos = [10, 0, 0];
    var c = Ingest.makeCalibrator(s);
    var e = c.apply({ pos: [0, 0, 0], vel: null, keypoints: null, size: null, height: null });
    near(e.pos[0], 8); near(e.pos[1], 1);   // top-left -> (-2,+1) + (10,0)
    var e2 = c.apply({ pos: [1, 1, 0], vel: null, keypoints: null, size: null, height: null });
    near(e2.pos[0], 12); near(e2.pos[1], -1);
  });
  test("calibration: units + axes + transform", function () {
    var s = Ingest.defaultSource(0); s.units = "mm"; s.axes = "yup"; s.transform.pos = [0, 0, 0]; s.transform.rot = [0, 0, 90];
    var c = Ingest.makeCalibrator(s);
    // input mm Y-up: x=1000 (1m right), y=2000 (2m up), z=-3000 (3m forward) -> zup: (1, 3, 2) -> rot 90° about z: (-3, 1, 2)
    var e = c.apply({ pos: [1000, 2000, -3000], vel: null, keypoints: null, size: null, height: null });
    near(e.pos[0], -3, 1e-6); near(e.pos[1], 1, 1e-6); near(e.pos[2], 2, 1e-6);
  });
  test("calibration: homography", function () {
    var s = Ingest.defaultSource(0); s.originMode = "world"; s.homography = { src: [[0, 0], [1, 0], [1, 1], [0, 1]], dst: [[0, 0], [4, 0], [4, 3], [0, 3]] };
    var c = Ingest.makeCalibrator(s);
    var e = c.apply({ pos: [0.5, 0.5, 0], vel: null, keypoints: null, size: null, height: null });
    near(e.pos[0], 2, 1e-6); near(e.pos[1], 1.5, 1e-6);
  });

  // ---------------- Engine ----------------
  function mkDoc(zones) { var d = Model.defaultDoc(); d.zones = zones; d.sources[0].lostTimeout = 0.2; return d; }
  function ent(id, x, y, z, extra) { var e = { id: String(id), pos: [x, y, z || 0], vel: null, conf: 1, cls: "", name: "", keypoints: null, kpFormat: "", size: null, height: null, heading: null, extra: {} }; if (extra) for (var k in extra) e[k] = extra[k]; return e; }
  function run(eng, frames, dt) { var all = []; var t = 0; dt = dt || 1 / 60; for (var i = 0; i < frames.length; i++) { t += dt; var r = eng.update([{ src: 0, entities: frames[i] }], t); all.push(r); } return all; }

  test("engine: enter / exit / occupied / empty", function () {
    var z = Model.makeZone("rect", 0); z.name = "A"; z.shape.w = 2; z.shape.h = 2; z.hysteresis.margin = 0;
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    var res = run(eng, [[ent(1, 5, 5)], [ent(1, 0, 0)], [ent(1, 0, 0)], [ent(1, 5, 5)], [ent(1, 5, 5)]]);
    eq(res[1].events.filter(function (e) { return e.type === "enter"; }).length, 1, "enter on frame 2");
    ok(res[1].zones[0].occupied, "occupied");
    eq(res[1].zones[0].count, 1);
    eq(res[1].counts[0], 1); eq(res[1].occupied[0], 1);
    eq(count(res[3].events, "exit"), 1, "exit on frame 4");
    eq(count(res[3].events, "empty"), 1, "empty on frame 4");
    ok(!res[3].zones[0].occupied);
    eq(res[1].tree["A"].count, 1);
  });
  test("engine: hysteresis margin prevents flicker", function () {
    var z = Model.makeZone("rect", 0); z.shape.w = 2; z.shape.h = 2; z.hysteresis.margin = 0.3;
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    // oscillate around the boundary x=1 : 0.95 (in) 1.1 (outside but within margin) 0.95 1.1 ...
    var frames = [[ent(1, 0, 0)]]; for (var i = 0; i < 20; i++) frames.push([ent(1, i % 2 ? 1.1 : 0.95, 0)]);
    frames.push([ent(1, 1.5, 0)]);
    var res = run(eng, frames);
    var enters = 0, exits = 0; res.forEach(function (r) { enters += count(r.events, "enter"); exits += count(r.events, "exit"); });
    eq(enters, 1, "single enter"); eq(exits, 1, "single exit once beyond margin");
  });
  test("engine: enter frames / exit ms debounce", function () {
    var z = Model.makeZone("circle", 0); z.shape.r = 1; z.hysteresis.enterFrames = 3; z.hysteresis.exitMs = 100; z.hysteresis.margin = 0;
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    var frames = [[ent(1, 0, 0)], [ent(1, 0, 0)], [ent(1, 0, 0)], [ent(1, 0, 0)], [ent(1, 5, 0)], [ent(1, 5, 0)], [ent(1, 5, 0)], [ent(1, 5, 0)], [ent(1, 5, 0)], [ent(1, 5, 0)], [ent(1, 5, 0)], [ent(1, 5, 0)]];
    var res = run(eng, frames); // dt=1/60 -> 100 ms = 6 frames
    ok(count(res[0].events, "enter") === 0 && count(res[1].events, "enter") === 0, "not yet");
    eq(count(res[2].events, "enter"), 1, "enter after 3 frames");
    var exitFrame = -1; for (var i = 0; i < res.length; i++) if (count(res[i].events, "exit")) { exitFrame = i; break; }
    ok(exitFrame >= 9, "exit delayed by 100ms, got frame " + exitFrame);
  });
  test("engine: lost entity triggers implicit exit", function () {
    var z = Model.makeZone("rect", 0); z.shape.w = 4; z.shape.h = 4;
    var eng = new ZE.Engine(); var d = mkDoc([z]); d.sources[0].lostTimeout = 0.1; eng.setDoc(d);
    var t = 0; var r1 = eng.update([{ src: 0, entities: [ent(1, 0, 0)] }], t += 0.016);
    eq(count(r1.events, "enter"), 1);
    var exits = 0;
    for (var i = 0; i < 20; i++) { var r = eng.update([{ src: 0, entities: [] }], t += 0.016); exits += count(r.events, "exit"); if (exits) { ok(r.events.some(function (e) { return e.type === "exit" && e.lost; }), "lost flag"); break; } }
    eq(exits, 1, "implicit exit");
    eq(Object.keys(eng.entities).length, 0, "entity dropped");
  });
  test("engine: dwell + cooldown + count once", function () {
    var z = Model.makeZone("rect", 0); z.shape.w = 2; z.shape.h = 2; z.dwell.loiterS = 0.05; z.hysteresis.cooldownMs = 500; z.hysteresis.margin = 0;
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    var frames = []; for (var i = 0; i < 6; i++) frames.push([ent(1, 0, 0)]); frames.push([ent(1, 5, 0)]); frames.push([ent(1, 0, 0)]);
    var res = run(eng, frames);
    var dwell = 0, enters = 0; res.forEach(function (r) { dwell += count(r.events, "dwell"); enters += count(r.events, "enter"); });
    eq(dwell, 1, "dwell fired once"); eq(enters, 1, "re-enter within cooldown suppressed");
    ok(res[7].zones[0].occupied, "but state is inside again");
  });
  test("engine: per-id uv / dist / selection nearest", function () {
    var z = Model.makeZone("rect", 0); z.shape.w = 4; z.shape.h = 2; z.selection = "nearest"; z.maxN = 1;
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    var res = run(eng, [[ent(1, 1, 0.5), ent(2, -0.5, 0)], [ent(1, 1, 0.5), ent(2, -0.5, 0)]]);
    var zo = res[1].zones[0];
    eq(zo.count, 2); eq(zo.ids.length, 1); eq(zo.ids[0], "2", "nearest to centre selected");
    var p = zo.per_id[0]; eq(p.id, "2"); near(p.u, (-0.5 + 2) / 4); near(p.v, 0.5);
    near(zo.all_ids.length, 2);
  });
  test("engine: filters class / height / min age", function () {
    var z = Model.makeZone("rect", 0); z.shape.w = 4; z.shape.h = 4; z.filters.cls = "person"; z.filters.heightMin = 1.2;
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    var res = run(eng, [[ent(1, 0, 0, 0, { cls: "person", height: 1.7 }), ent(2, 0, 0, 0, { cls: "car", height: 1.7 }), ent(3, 0, 0, 0, { cls: "person", height: 1.0 })]]);
    eq(res[0].zones[0].count, 1);
  });
  test("engine: line crossing direction + confirm frames + finite extent", function () {
    var z = Model.makeZone("line", 0); z.shape.points = [[-1, 0], [1, 0]]; z.shape.direction = "both"; z.line.confirmFrames = 2;
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    var frames = [[ent(1, 0, -1)], [ent(1, 0, -0.2)], [ent(1, 0, 0.2)], [ent(1, 0, 0.5)], [ent(1, 0, 1)], [ent(1, 0, -0.5)], [ent(1, 0, -1)],
                  [ent(2, 5, -1)], [ent(2, 5, 1)], [ent(2, 5, 1)]]; // entity 2 crosses outside the segment extent
    var res = run(eng, frames);
    var ins = 0, outs = 0; res.forEach(function (r) { r.events.forEach(function (e) { if (e.type === "cross") { if (e.direction === "in") ins++; else outs++; } }); });
    eq(ins, 1, "one in crossing"); eq(outs, 1, "one out crossing");
    eq(res[res.length - 1].zones[0].crossings_in, 1); eq(res[res.length - 1].zones[0].crossings_out, 1);
  });
  test("engine: line crossing one-way", function () {
    var z = Model.makeZone("line", 0); z.shape.points = [[-1, 0], [1, 0]]; z.shape.direction = "a_to_b"; z.line.confirmFrames = 1;
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    var res = run(eng, [[ent(1, 0, -1)], [ent(1, 0, 1)], [ent(1, 0, -1)]]);
    var ins = 0, outs = 0; res.forEach(function (r) { r.events.forEach(function (e) { if (e.type === "cross") { if (e.direction === "in") ins++; else outs++; } }); });
    eq(ins, 1); eq(outs, 0);
  });
  test("engine: path progress", function () {
    var z = Model.makeZone("path", 0); z.shape.points = [[0, 0], [10, 0]]; z.shape.width = 2;
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    var res = run(eng, [[ent(1, 2.5, 0.5)], [ent(1, 2.5, 0.5)]]);
    eq(res[1].zones[0].count, 1); near(res[1].zones[0].per_id[0].progress, 0.25); near(res[1].zones[0].per_id[0].offset, 0.5);
  });
  test("engine: 3D box and feet anchor with keypoints", function () {
    var z = Model.makeZone("box", 0); z.pos = [0, 0, 1]; z.shape.w = 2; z.shape.h = 2; z.shape.d = 2;
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    var res = run(eng, [[ent(1, 0, 0, 1), ent(2, 0, 0, 5)]]);
    eq(res[0].zones[0].count, 1);
    var z2 = Model.makeZone("rect", 0); z2.shape.w = 1; z2.shape.h = 1; z2.anchor = "feet";
    var eng2 = new ZE.Engine(); eng2.setDoc(mkDoc([z2]));
    var kps = []; for (var i = 0; i < 17; i++) kps.push([5, 5, 1, 1]); kps[15] = [0.1, 0.1, 0, 1]; kps[16] = [-0.1, -0.1, 0, 1];
    var res2 = run(eng2, [[ent(1, 5, 5, 0, { keypoints: kps, kpFormat: "coco17" })]]);
    eq(res2[0].zones[0].count, 1, "feet inside although centroid outside");
  });
  test("engine: exclude mask + include", function () {
    var a = Model.makeZone("rect", 0); a.name = "A"; a.shape.w = 10; a.shape.h = 10;
    var x = Model.makeZone("circle", 1); x.name = "X"; x.role = "exclude"; x.shape.r = 1; x.pos = [3, 3, 0];
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([a, x]));
    var res = run(eng, [[ent(1, 3, 3), ent(2, -3, -3)]]);
    eq(res[0].zones[0].count, 1, "masked entity not counted");
    var inc = Model.makeZone("rect", 2); inc.role = "include"; inc.shape.w = 2; inc.shape.h = 2; inc.pos = [-3, -3, 0];
    var eng2 = new ZE.Engine(); eng2.setDoc(mkDoc([a, inc]));
    var res2 = run(eng2, [[ent(1, 3, 3), ent(2, -3, -3)]]);
    eq(res2[0].zones[0].count, 1, "only included entity counted");
  });
  test("engine: zone attached to entity (relative frame)", function () {
    var z = Model.makeZone("circle", 0); z.shape.r = 1; z.frame = "entity"; z.frameRef = "1"; z.filters.cls = "";
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    var res = run(eng, [[ent(1, 10, 10), ent(2, 10.5, 10)], [ent(1, 10, 10), ent(2, 10.5, 10)]]);
    eq(res[1].zones[0].count, 2, "carrier + neighbour inside moving zone");
    var res2 = run(eng, [[ent(1, 20, 20), ent(2, 10.5, 10)]]);
    eq(res2[0].zones[0].count, 1, "only carrier after moving away");
  });
  test("engine: zone sets / disabled zone", function () {
    var a = Model.makeZone("rect", 0); a.set = "act1"; a.shape.w = 4; a.shape.h = 4;
    var b = Model.makeZone("rect", 1); b.set = "act2"; b.shape.w = 4; b.shape.h = 4;
    var d = mkDoc([a, b]); d.settings.activeSet = "act1";
    var eng = new ZE.Engine(); eng.setDoc(d);
    var res = run(eng, [[ent(1, 0, 0)]]);
    eq(res[0].zones[0].count, 1); eq(res[0].zones[1].count, 0); ok(!res[0].zones[1].active);
    d.settings.activeSet = "act2"; eng.setDoc(d);
    var res2 = run(eng, [[ent(1, 0, 0)]]);
    eq(res2[0].zones[0].count, 0); eq(res2[0].zones[1].count, 1);
  });
  test("engine: occupancy set/clear thresholds and capacity", function () {
    var z = Model.makeZone("rect", 0); z.shape.w = 10; z.shape.h = 10; z.occupancy.setThreshold = 2; z.occupancy.clearThreshold = 0; z.occupancy.capacity = 2;
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    var res = run(eng, [[ent(1, 0, 0)], [ent(1, 0, 0), ent(2, 1, 1)], [ent(1, 0, 0), ent(2, 1, 1), ent(3, 2, 2)], [ent(1, 0, 0)], []]);
    ok(!res[0].zones[0].occupied, "1 < set threshold"); ok(res[1].zones[0].occupied, "2 >= set");
    eq(count(res[2].events, "capacity"), 1, "over capacity event");
    ok(res[3].zones[0].occupied, "1 > clear threshold keeps occupied");
  });
  test("engine: smoothing + index ids + max jump", function () {
    var z = Model.makeZone("rect", 0); z.shape.w = 10; z.shape.h = 10;
    var d = mkDoc([z]); d.sources[0].smoothing = { enabled: true, minCutoff: 1, beta: 0 }; d.sources[0].idMode = "index"; d.sources[0].maxJump = 1;
    var eng = new ZE.Engine(); eng.setDoc(d);
    var res = run(eng, [[ent(9, 0, 0)], [ent(9, 0.1, 0)], [ent(9, 5, 0)], [ent(9, 0.2, 0)]]);
    eq(res[0].entities[0].id, "0", "index id");
    ok(res[2].entities[0].pos[0] < 1, "teleport rejected");
  });
  test("engine: heatmap accumulates", function () {
    var z = Model.makeZone("rect", 0); var d = mkDoc([z]); d.settings.heatmap = { enabled: true, x: 0, y: 0, w: 4, h: 4, cols: 4, rows: 4, decay: 0 };
    var eng = new ZE.Engine(); eng.setDoc(d);
    var res = run(eng, [[ent(1, 1, 1)], [ent(1, 1, 1)]]);
    eq(res[1].heatmap.length, 16); ok(res[1].heatmap.some(function (v) { return v > 0; }));
  });
  test("engine: snapshot + tree fan-out shape", function () {
    var z = Model.makeZone("rect", 0); z.name = "Stage"; z.shape.w = 4; z.shape.h = 4;
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    var res = run(eng, [[ent(1, 0, 0)]]);
    var s = eng.snapshot(res[0]); eq(s.entities.length, 1); eq(s.zones.length, 1);
    ok(res[0].tree.Stage && res[0].tree.Stage.occupied === true && res[0].tree.Stage.ids.length === 1);
  });
  test("engine: reset counters", function () {
    var z = Model.makeZone("line", 0); z.shape.points = [[-1, 0], [1, 0]]; z.line.confirmFrames = 1;
    var eng = new ZE.Engine(); eng.setDoc(mkDoc([z]));
    run(eng, [[ent(1, 0, -1)], [ent(1, 0, 1)]]);
    eng.resetCounters();
    var r = run(eng, [[ent(1, 0, 1)]]); eq(r[0].zones[0].crossings_in, 0);
  });
  test("engine: performance 100 entities x 100 zones", function () {
    var zones = []; for (var i = 0; i < 100; i++) { var z = Model.makeZone(i % 3 === 0 ? "polygon" : (i % 3 === 1 ? "circle" : "rect"), i); z.pos = [(i % 10) * 2, Math.floor(i / 10) * 2, 0]; zones.push(z); }
    var eng = new ZE.Engine(); eng.setDoc(mkDoc(zones));
    var ents = []; for (var j = 0; j < 100; j++) ents.push(ent(j, Math.random() * 20, Math.random() * 20));
    var t0 = Util.timestamp(); var t = 0;
    for (var f = 0; f < 60; f++) { for (var q = 0; q < ents.length; q++) { ents[q].pos[0] += 0.01; } eng.update([{ src: 0, entities: ents }], t += 1 / 60); }
    var ms = (Util.timestamp() - t0) * 1000 / 60;
    out("  perf: " + ms.toFixed(2) + " ms per tick (100x100)");
    ok(ms < 16, "budget: " + ms + " ms per tick");
  });
  test("engine: proximity events + pairs output", function () {
    var d = mkDoc([]); d.settings.proximity = { enabled: true, distance: 1.0, crossSourcesOnly: false };
    var eng = new ZE.Engine(); eng.setDoc(d);
    var res = run(eng, [[ent(1, 0, 0), ent(2, 5, 0)], [ent(1, 0, 0), ent(2, 0.5, 0)], [ent(1, 0, 0), ent(2, 0.6, 0)], [ent(1, 0, 0), ent(2, 3, 0)]]);
    eq(count(res[1].events, "proximity"), 1, "start"); eq(res[1].pairs.length, 1); eq(res[1].events[0].state, "start");
    eq(count(res[2].events, "proximity"), 0, "no repeat");
    eq(count(res[3].events, "proximity"), 1, "end"); eq(res[3].events.filter(function (e) { return e.type === "proximity"; })[0].state, "end"); eq(res[3].pairs.length, 0);
  });
  test("model: normalizeDoc fills defaults and templates", function () {
    var d = Model.normalizeDoc({ zones: [{ name: "x", shape: { type: "circle", r: 3 } }] });
    eq(d.zones.length, 1); eq(d.zones[0].shape.r, 3); ok(d.zones[0].hysteresis && d.zones[0].id);
    eq(Model.template("funnel").length, 3); eq(Model.gridZones(0, 0, 4, 2, 4, 2).length, 8); eq(Model.sectorZones(0, 0, 1, 3, 6).length, 6);
    eq(Model.template("piano").length, 12, "1 octave = 7 white + 5 black"); eq(Model.template("piano2").length, 24); eq(Model.template("camera-grid").length, 9); eq(Model.template("xy-pad").length, 5); eq(Model.template("swipe").length, 2); eq(Model.template("depth-layers").length, 3);
    var pk = Model.template("piano"); ok(pk[11].name === "A#4" && pk[11].pos[1] > 0, "black keys last, on the upper half"); ok(Model.normalizeDoc({ zones: pk }).zones.length === 12);
    var pie = Model.pieZones(0, 0, 2, 6); eq(pie.length, 6); eq(pie[0].name, "Slice 1"); ok(Geom.polygonArea(pie[0].shape.points) > 0 && !Geom.polygonSelfIntersects(pie[0].shape.points), "pie wedge is a valid polygon"); near(Geom.polygonArea(pie[0].shape.points) * 6, Math.PI * 4, 0.2, "6 slices cover the disc");
  });

  // ---------------- event filtering + simple output formats ----------------
  test("global event type filter", function () {
    var eng = new ZE.Engine();
    var z = Model.makeZone("rect", 0); z.name = "Z"; z.pos = [0, 0, 0];
    var doc = Model.defaultDoc(); doc.zones = [z]; doc.settings.events.enter = false; doc.settings.events.count = false;
    eng.setDoc(doc);
    var t = 0; var evs = [];
    for (var i = 0; i < 5; i++) { var r = eng.update([{ src: 0, entities: [ent(1, 0, 0)] }], t += 0.1); evs = evs.concat(r.events); }
    eq(count(evs, "enter"), 0, "enter filtered");
    eq(count(evs, "count"), 0, "count filtered");
    eq(count(evs, "occupied"), 1, "occupied still emitted");
    for (var j = 0; j < 5; j++) { var r2 = eng.update([{ src: 0, entities: [ent(1, 5, 5)] }], t += 0.1); evs = evs.concat(r2.events); }
    eq(count(evs, "exit"), 1, "exit still emitted");
  });
  test("per-zone event opt-out", function () {
    var eng = new ZE.Engine();
    var a = Model.makeZone("rect", 0); a.name = "A"; a.pos = [0, 0, 0];
    var b = Model.makeZone("rect", 1); b.name = "B"; b.pos = [0, 0, 0];
    a.events = { enter: false, count: false, occupied: false, first_in: false, transition: false };
    var doc = Model.defaultDoc(); doc.zones = [a, b];
    eng.setDoc(doc);
    var t = 0; var evs = [];
    for (var i = 0; i < 5; i++) { var r = eng.update([{ src: 0, entities: [ent(1, 0, 0)] }], t += 0.1); evs = evs.concat(r.events); }
    var enters = evs.filter(function (e) { return e.type === "enter"; });
    eq(enters.length, 1, "one enter"); eq(enters[0].zone, "B", "only B reports");
    ok(!evs.some(function (e) { return e.zone === "A" && (e.type === "enter" || e.type === "occupied" || e.type === "first_in" || e.type === "count"); }), "A silenced");
    ok(evs.some(function (e) { return e.zone === "B" && e.type === "occupied"; }), "B unaffected");
  });
  test("formatEvent formats", function () {
    var ev = { t: 1, type: "enter", zone: "Z", zone_id: "z1", id: "e1", src: 0 };
    eq(ZE.formatEvent(ev, "zone"), "Z");
    eq(ZE.formatEvent(ev, "id"), "e1");
    var p = ZE.formatEvent(ev, "pair"); eq(p[0], "Z"); eq(p[1], "e1");
    var m = ZE.formatEvent(ev, "map"); eq(m.zone, "Z"); eq(m.id, "e1"); eq(m.type, "enter"); eq(m.src, 0);
    eq(ZE.formatEvent(ev, "full"), ev);
    var dw = ZE.formatEvent({ type: "dwell", zone: "Z", id: "e1", src: 0, dwell: 3.5 }, "map"); near(dw.dwell, 3.5);
    var oc = { t: 1, type: "occupied", zone: "Z", zone_id: "z1", id: "", src: -1, count: 2 };
    var op = ZE.formatEvent(oc, "pair"); eq(op[0], "Z"); eq(op[1], 1);
    var om = ZE.formatEvent(oc, "map"); eq(om.occupied, true); eq(om.count, 2);
    eq(ZE.formatEvent({ type: "empty", zone: "Z", count: 0 }, "pair")[1], 0);
    var cr = ZE.formatEvent({ type: "cross", zone: "Z", id: "e1", src: 0, direction: "in", "in": 3, out: 1 }, "map"); eq(cr.direction, "in"); eq(cr["in"], 3); eq(cr.out, 1);
  });
  test("locationOutput formats", function () {
    var ents = [{ id: "a", zones: ["Z1", "Z2"] }, { id: "b", zones: [] }, { id: "c", zones: ["Z3"] }];
    var m = ZE.locationOutput(ents, { format: "map" });
    eq(m.a, "Z2", "topmost zone"); eq(m.c, "Z3"); ok(!("b" in m), "outside excluded by default");
    eq(ZE.locationOutput(ents, { format: "map", includeOutside: true }).b, "", "outside as empty string");
    var l = ZE.locationOutput(ents, { format: "list" }); eq(l.length, 2); eq(l[0][0], "a"); eq(l[0][1], "Z2");
    var ma = ZE.locationOutput(ents, { format: "map", all: true }); eq(ma.a.length, 2); eq(ma.a[0], "Z1");
    eq(ZE.locationOutput(ents, { format: "zone" }), "Z2", "single-string mode");
    eq(ZE.locationOutput([], { format: "zone" }), "", "nobody tracked");
  });

  out("\n" + passed + " passed, " + failed + " failed");
  Util.writeFile(OUT, log.join("\n") + "\n");
  var code = failed ? 1 : 0;
  Qt.createQmlObject('import QtQuick; Timer { interval: 1500; running: true; repeat: false; onTriggered: Qt.exit(' + code + ') }', Score, "exitTimer");
})();
