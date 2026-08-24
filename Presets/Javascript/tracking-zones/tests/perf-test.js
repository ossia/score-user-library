// perf-test.js — heavier scenario: grid of 48 zones + 60 pose entities (17 keypoints each) + 20 walkers, split view.
// Reports exec tick time, engine time, snapshot rate and UI fps from the editor's instrumentation.
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var SHOT = DIR + "tests/shots/";
  var OUT = DIR + "tests/perf-test.out";
  var ST = DIR + "tests/perf-status.json";
  var report = [];
  function out(s) { report.push(s); console.log(s); }
  function finish(code) { Util.writeFile(OUT, report.join("\n") + "\n"); Qt.createQmlObject('import QtQuick; Timer { interval: 800; running: true; repeat: false; onTriggered: Qt.exit(' + code + ') }', Score, "exitTimer"); }
  function after(ms, fn) { var t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "t" + ms); t.fired.connect(fn); return t; }
  try {
    Util.writeFile(ST, "");
    var itv = Score.rootInterval();
    var zones = [];
    for (var r = 0; r < 6; r++) for (var c = 0; c < 8; c++) zones.push({ name: "Cell " + r + "x" + c, shape: { type: c % 2 ? "rect" : "circle", w: 1.4, h: 1.4, r: 0.7 }, pos: [-7 + c * 2, 5 - r * 2, 0], hysteresis: { margin: 0.1 }, dwell: { loiterS: 2 } });
    var doc = { zones: zones, sources: [{ enabled: true, lostTimeout: 0.4 }], settings: { uiRate: 30, heatmap: { enabled: true, x: 0, y: 0, w: 16, h: 12, cols: 32, rows: 24, decay: 0.1 } } };
    var docJson = JSON.stringify(doc).replace(/\\/g, "\\\\").replace(/'/g, "\\'");
    var actions = [
      [1.0, { cmd: "ui", action: "fit" }],
      [1.5, { cmd: "ui", action: "view", value: "split" }],
      [2.0, { cmd: "ui", action: "walkers", value: 20 }],
      [2.5, { cmd: "ui", action: "tab", value: 2 }],
      [10.0, { cmd: "ui", action: "dumpstatus", path: ST }],
      [10.5, { cmd: "ui", action: "grab", path: SHOT + "perf-split.png" }],
      [11.0, { cmd: "ui", action: "view", value: "2d" }],
      [15.0, { cmd: "ui", action: "dumpstatus", path: DIR + "tests/perf-status-2d.json" }],
      [15.5, { cmd: "ui", action: "view", value: "3d" }],
      [20.0, { cmd: "ui", action: "dumpstatus", path: DIR + "tests/perf-status-3d.json" }]
    ];
    var actJson = JSON.stringify(actions).replace(/\\/g, "\\\\").replace(/'/g, "\\'");
    var driverSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueOutlet { id: ents; objectName: 'ents' }",
      "  ValueOutlet { id: cmd; objectName: 'cmd' }",
      "  property int n: 0",
      "  property var actions: JSON.parse('" + actJson + "')",
      "  property int nextAction: 0",
      "  property real t0: -1",
      "  tick: function(token, state) {",
      "    n++; var t = token.date / 705600000; if (t0 < 0) t0 = t;",
      "    if (n === 2) { cmd.value = { cmd: 'doc', doc: '" + docJson + "' }; return; }",
      "    if (nextAction < actions.length && t - t0 >= actions[nextAction][0]) { cmd.value = actions[nextAction][1]; nextAction++; }",
      "    var list = [];",
      "    for (var i = 0; i < 60; i++) { var ph = t * (0.2 + (i % 7) * 0.05) + i; var cx = Math.cos(ph) * (2 + (i % 9) * 0.6), cy = Math.sin(ph * 0.8) * (2 + (i % 5) * 0.8); var kps = []; for (var k = 0; k < 17; k++) kps.push({ x: cx + Math.sin(k) * 0.2, y: cy + Math.cos(k) * 0.2, z: k * 0.1, confidence: 0.9 }); list.push({ track_id: i + 1, keypoints: kps, box: { x: cx - 0.3, y: cy - 0.3, w: 0.6, h: 0.6 }, mean_confidence: 0.9, class_id: 0 }); }",
      "    ents.value = list;",
      "  }",
      "}"
    ].join("\n");
    var driver = Score.createProcess(itv, "Javascript", driverSrc);
    var zones_p = Score.createProcess(itv, "Javascript", DIR + "tracking-zones.qml");
    Score.setName(zones_p, "Tracking Zones");
    Score.createCable(Score.port(driver, "ents"), Score.port(zones_p, "Source 1"));
    Score.createCable(Score.port(driver, "cmd"), Score.port(zones_p, "Command"));
    after(1500, function () { Score.play(); Score.showProcessUI(zones_p, true); });
    after(28500, function () {
      Score.stop();
      try {
        var s1 = JSON.parse(Score.readFile(ST)); var s2 = JSON.parse(Score.readFile(DIR + "tests/perf-status-2d.json")); var s3 = JSON.parse(Score.readFile(DIR + "tests/perf-status-3d.json"));
        out("3d view:    " + JSON.stringify(s3.perf) + " stats " + JSON.stringify(s3.stats3d) + " detail " + s3.perfDetail);
        out("split stats " + JSON.stringify(s1.stats3d));
        out("split view: " + JSON.stringify(s1.perf) + " entities=" + s1.entities + " zones=" + s1.zones);
        out("2d view:    " + JSON.stringify(s2.perf));
        out("detail split: " + s1.perfDetail); out("detail 2d: " + s2.perfDetail);
        out("PASS perf"); finish(0);
      } catch (e) { out("FAIL " + e); finish(1); }
    });
  } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
})();
