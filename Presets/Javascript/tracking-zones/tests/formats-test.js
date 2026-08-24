// formats-test.js — every input format through a REAL process and cable (values arrive as QJS
// array-likes, not Arrays, so unit tests are not enough). One phase per format on Source 1;
// the logger records the Entities output near the end of each phase.
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var OUT = DIR + "tests/formats-test.out";
  var LOG = DIR + "tests/formats-log.json";
  var report = [];
  function out(s) { report.push(s); console.log(s); }
  function finish(code) { Util.writeFile(OUT, report.join("\n") + "\n"); Qt.createQmlObject('import QtQuick; Timer { interval: 800; running: true; repeat: false; onTriggered: Qt.exit(' + code + ') }', Score, "exitTimer"); }
  function after(ms, fn) { var t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "t" + ms); t.fired.connect(fn); return t; }
  var PHASE = 2.0;      // seconds per phase
  var NPHASES = 13;
  try {
    Util.writeFile(LOG, "{}");
    var itv = Score.rootInterval();
    var driverSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueOutlet { id: o; objectName: 'o' }",
      "  property real t0: -1",
      "  function payload(k) {",
      "    switch (k) {",
      "    case 0: return [[1, 2], [3, 4]];",                                        // raw [x,y] pairs
      "    case 1: return [[1, 2, 3], [4, 5, 6]];",                                  // raw [x,y,z] triples
      "    case 2: return [1, 2, 3, 4, 5, 6];",                                      // flat floats (auto stride 2)
      "    case 3: return [Qt.vector3d(1, 1, 1), Qt.vector3d(2, 2, 2)];",            // vec3 list
      "    case 4: return Qt.vector3d(7, 8, 9);",                                    // single point
      "    case 5: return { t0: { position: Qt.vector3d(1, 0, 0) }, t1: { position: Qt.vector3d(2, 0, 0) } };",  // PSN/RTTrP subtree
      "    case 6: return { left: { palm: Qt.vector3d(0.1, 0.2, 0.3) }, right: { palm: Qt.vector3d(0.4, 0.5, 0.6) } };",  // Leap hands
      "    case 7: return { camA: [[1, 1]], camB: [{ id: 9, position: Qt.vector3d(3, 3, 0) }] };",  // map of sources
      "    case 8: return '[{\\'id\\': 5, \\'pos\\': [1, 2]}]'.replace(/\\'/g, String.fromCharCode(34));",  // JSON string
      "    case 9: return [{ box: { x: 1, y: 1, w: 2, h: 1 }, class_id: 0, confidence: 0.9 }];",  // object detector Detection
      "    case 10: return [{ id: 11, position: Qt.vector3d(1, 2, 3), velocity: Qt.vector3d(0.5, 0, 0), age: 2.5, state: 'active' }];",  // Point Tracker Tracks
      "    case 11: return [Qt.vector4d(1, 2, 0, 0.5)];",                            // vec4 = xyz + confidence
      "    case 12: return { 0: { position: Qt.vector3d(0.5, 0.5, 0) }, 1: { position: Qt.vector3d(1.5, 0.5, 0) } };",  // TUIO-style indexed map
      "    }",
      "    return [];",
      "  }",
      "  tick: function(token, state) {",
      "    var t = token.date / 705600000; if (t0 < 0) t0 = t;",
      "    var k = Math.min(" + (NPHASES - 1) + ", Math.floor((t - t0) / " + PHASE + "));",
      "    o.value = payload(k);",
      "  }",
      "}"
    ].join("\n");
    var loggerSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueInlet { id: ein; objectName: 'entities' }",
      "  property real t0: -1",
      "  property var results: ({})",
      "  tick: function(token, state) {",
      "    var t = token.date / 705600000; if (t0 < 0) t0 = t;",
      "    var rel = t - t0; var k = Math.min(" + (NPHASES - 1) + ", Math.floor(rel / " + PHASE + "));",
      "    var ph = rel - k * " + PHASE + ";",
      "    if (ph > " + (PHASE - 0.5) + " && ein.value !== undefined) {",
      "      var es = ein.value; var snap = [];",
      "      for (var i = 0; i < es.length; i++) snap.push({ id: es[i].id, x: es[i].pos.x, y: es[i].pos.y, z: es[i].pos.z, conf: es[i].conf, src: es[i].src, size: es[i].size ? [es[i].size.x !== undefined ? es[i].size.x : es[i].size[0], es[i].size.y !== undefined ? es[i].size.y : es[i].size[1]] : null, speed: es[i].speed });",
      "      results[k] = snap;",
      "      Util.writeFile('" + LOG + "', JSON.stringify(results));",
      "    }",
      "  }",
      "}"
    ].join("\n");
    var driver = Score.createProcess(itv, "Javascript", driverSrc);
    var zones = Score.createProcess(itv, "Javascript", DIR + "tracking-zones.qml");
    var logger = Score.createProcess(itv, "Javascript", loggerSrc);
    Score.setName(zones, "Tracking Zones");
    Score.createCable(Score.port(driver, "o"), Score.port(zones, "Source 1"));
    Score.createCable(Score.port(zones, "Entities"), Score.port(logger, "entities"));
    after(1500, function () { Score.play(); });
    after(1500 + NPHASES * PHASE * 1000 + 1500, function () {
      Score.stop();
      try {
        var R = JSON.parse(Score.readFile(LOG));
        var f = [];
        function ids(k) { return (R[k] || []).map(function (e) { return e.id; }).sort(); }
        function by(k, id) { var l = R[k] || []; for (var i = 0; i < l.length; i++) if (l[i].id === id) return l[i]; return null; }
        function expectIds(k, want, label) { var got = ids(k); if (JSON.stringify(got) !== JSON.stringify(want.slice().sort())) f.push(label + ": ids " + JSON.stringify(got) + " wanted " + JSON.stringify(want)); }
        function near(a, b) { return Math.abs(a - b) < 0.01; }
        for (var k = 0; k < NPHASES; k++) out("phase " + k + ": " + JSON.stringify(R[k] || "MISSING"));
        expectIds(0, ["0", "1"], "P0 [x,y] pairs"); var p0 = by(0, "1"); if (!p0 || !near(p0.x, 3) || !near(p0.y, 4)) f.push("P0 position");
        expectIds(1, ["0", "1"], "P1 [x,y,z]"); var p1 = by(1, "1"); if (!p1 || !near(p1.z, 6)) f.push("P1 z");
        expectIds(2, ["0", "1", "2"], "P2 flat floats"); var p2 = by(2, "2"); if (!p2 || !near(p2.x, 5) || !near(p2.y, 6)) f.push("P2 stride");
        expectIds(3, ["0", "1"], "P3 vec3 list");
        expectIds(4, ["0"], "P4 single vec3"); var p4 = by(4, "0"); if (!p4 || !near(p4.x, 7) || !near(p4.z, 9)) f.push("P4 pos");
        expectIds(5, ["t0", "t1"], "P5 PSN subtree"); var p5 = by(5, "t1"); if (!p5 || !near(p5.x, 2)) f.push("P5 pos");
        expectIds(6, ["left", "right"], "P6 Leap hands"); var p6 = by(6, "right"); if (!p6 || !near(p6.x, 0.4)) f.push("P6 palm pos");
        expectIds(7, ["camA.0", "camB.9"], "P7 source map"); var p7 = by(7, "camB.9"); if (!p7 || !near(p7.x, 3)) f.push("P7 pos");
        expectIds(8, ["5"], "P8 JSON string");
        expectIds(9, ["0"], "P9 Detection box"); var p9 = by(9, "0"); if (!p9 || !near(p9.x, 2) || !near(p9.y, 1.5)) f.push("P9 box centre " + JSON.stringify(p9)); if (!p9 || !p9.size || !near(p9.size[0], 2)) f.push("P9 box size");
        expectIds(10, ["11"], "P10 Tracks"); var p10 = by(10, "11"); if (!p10 || !near(p10.z, 3)) f.push("P10 pos"); if (!p10 || !(p10.speed > 0.3)) f.push("P10 velocity/speed " + (p10 && p10.speed));
        expectIds(11, ["0"], "P11 vec4"); var p11 = by(11, "0"); if (!p11 || !near(p11.conf, 0.5)) f.push("P11 conf " + (p11 && p11.conf));
        expectIds(12, ["0", "1"], "P12 TUIO map"); var p12 = by(12, "1"); if (!p12 || !near(p12.x, 1.5)) f.push("P12 pos");
        if (f.length) { out("FAIL: " + f.join("; ")); finish(1); } else { out("PASS all input formats"); finish(0); }
      } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
    });
  } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
})();
