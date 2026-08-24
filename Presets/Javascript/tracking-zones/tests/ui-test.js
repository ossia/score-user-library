// ui-test.js — opens the Tracking Zones editor with a populated document, plays, drives scripted UI actions
// through the Command inlet and grabs the editor window into PNGs for visual checks.
// Run: score.exe --script "eval(Score.readFile('.../tests/ui-test.js'))"
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var SHOT = DIR + "tests/shots/";
  var OUT = DIR + "tests/ui-test.out";
  var report = [];
  function out(s) { report.push(s); console.log(s); }
  function finish(code) { Util.writeFile(OUT, report.join("\n") + "\n"); Qt.createQmlObject('import QtQuick; Timer { interval: 800; running: true; repeat: false; onTriggered: Qt.exit(' + code + ') }', Score, "exitTimer"); }
  function after(ms, fn) { var t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "t" + ms); t.fired.connect(fn); return t; }
  try {
    var itv = Score.rootInterval();
    var doc = {
      zones: [
        { name: "Stage", shape: { type: "rect", w: 6, h: 3 }, pos: [0, 1.5, 0], color: "#2bb3a3", hysteresis: { margin: 0.2 } },
        { name: "Door", shape: { type: "line", points: [[-0.8, 0], [0.8, 0]], direction: "both", width: 0.1 }, pos: [-4, -1, 0], rot: [0, 0, 90], color: "#7ad3ff" },
        { name: "Lounge", shape: { type: "circle", r: 1.2 }, pos: [3.5, -2, 0], color: "#e0a54d", dwell: { loiterS: 3 } },
        { name: "Sensor mask", shape: { type: "polygon", points: [[-0.6, -0.4], [0.6, -0.4], [0.8, 0.5], [-0.8, 0.5]] }, pos: [-3, 2.5, 0], role: "exclude" },
        { name: "Booth", shape: { type: "box", w: 1.5, h: 1.5, d: 2.2 }, pos: [-3.5, -3, 1.1], color: "#9b7bd6" },
        { name: "Walkway", shape: { type: "path", points: [[-3, 0], [-1, -1.5], [1, -1.5], [3, 0]], width: 1.2 }, pos: [0, -3.5, 0], color: "#c7b24d" },
        { name: "Arena", shape: { type: "polygon", points: [[-1, -1.2], [1, -1.2], [1.6, 0], [1, 1.2], [-1, 1.2], [-1.6, 0]], useZ: true, zmin: 0, zmax: 1.5 }, pos: [5.5, 2, 0], color: "#e08cc7" }
      ],
      sources: [{ enabled: true, lostTimeout: 0.4 }],
      settings: { uiRate: 30, heatmap: { enabled: true, x: 0, y: 0, w: 12, h: 9, cols: 24, rows: 18, decay: 0.1 } }
    };
    var docJson = JSON.stringify(doc).replace(/\\/g, "\\\\").replace(/'/g, "\\'");
    // scripted action timeline (seconds after play) executed by the driver process through the Command inlet
    var actions = [
      [2.0, { cmd: "ui", action: "size", w: 1280, h: 860 }],
      [3.0, { cmd: "ui", action: "fit" }],
      [3.5, { cmd: "ui", action: "grab", path: SHOT + "ui-overview.png" }],
      [4.0, { cmd: "ui", action: "select", name: "Lounge" }],
      [4.6, { cmd: "ui", action: "grab", path: SHOT + "ui-selected.png" }],
      [5.0, { cmd: "ui", action: "tab", value: 1 }],
      [5.2, { cmd: "ui", action: "walkers", value: 8 }],
      [6.5, { cmd: "ui", action: "grab", path: SHOT + "ui-sim.png" }],
      [7.0, { cmd: "ui", action: "view", value: "3d" }],
      [8.5, { cmd: "ui", action: "grab", path: SHOT + "ui-3d.png" }],
      [9.0, { cmd: "ui", action: "view", value: "split" }],
      [9.2, { cmd: "ui", action: "tab", value: 2 }],
      [9.4, { cmd: "ui", action: "heat", value: true }],
      [10.5, { cmd: "ui", action: "grab", path: SHOT + "ui-split.png" }],
      [11.0, { cmd: "ui", action: "view", value: "2d" }],
      [11.2, { cmd: "ui", action: "tab", value: 0 }],
      [11.4, { cmd: "ui", action: "select", name: "" }],
      [12.3, { cmd: "ui", action: "grab", path: SHOT + "ui-sources.png" }],
      [12.8, { cmd: "ui", action: "tab", value: 1 }],
      [13.0, { cmd: "ui", action: "record", value: true }],
      [16.0, { cmd: "ui", action: "record", value: false }],
      [17.0, { cmd: "ui", action: "playLast" }],
      [19.0, { cmd: "ui", action: "grab", path: SHOT + "ui-playback.png" }],
      [19.5, { cmd: "ui", action: "dumpstatus", path: DIR + "tests/ui-status.json" }]
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
      "    n++;",
      "    var t = token.date / 705600000;",
      "    if (t0 < 0) t0 = t;",
      "    if (n === 2) { cmd.value = { cmd: 'doc', doc: '" + docJson + "' }; return; }",
      "    if (nextAction < actions.length && t - t0 >= actions[nextAction][0]) { cmd.value = actions[nextAction][1]; nextAction++; }",
      "    var list = [];",
      "    for (var i = 0; i < 6; i++) { var ph = t * (0.3 + i * 0.07) + i; list.push({ id: i + 1, position: Qt.vector3d(Math.cos(ph) * (2 + i * 0.6), Math.sin(ph * 0.8) * (2 + i * 0.4), 0), confidence: 0.9, class_id: 'person', height: 1.7 }); }",
      "    list.push({ id: 99, position: Qt.vector3d(-4 + Math.sin(t) * 1.5, -1, 0), class_id: 'person' });",
      "    ents.value = list;",
      "  }",
      "}"
    ].join("\n");
    var driver = Score.createProcess(itv, "Javascript", driverSrc);
    var zones = Score.createProcess(itv, "Javascript", DIR + "tracking-zones.qml");
    Score.setName(zones, "Tracking Zones");
    out("hasUI=" + Score.hasProcessUI(zones));
    var c1 = Score.createCable(Score.port(driver, "ents"), Score.port(zones, "Source 1"));
    var c2 = Score.createCable(Score.port(driver, "cmd"), Score.port(zones, "Command"));
    out("cables " + c1 + " " + c2);
    after(1500, function () { Score.play(); });   // the audio engine needs a moment after document load
    Score.showProcessUI(zones, true);
    out("ui shown");
    after(21500, function () {
      Score.stop();
      var shots = ["ui-overview", "ui-selected", "ui-sim", "ui-3d", "ui-split", "ui-sources", "ui-playback"]; var missing = [];
      for (var i = 0; i < shots.length; i++) if (!Util.fileExists(SHOT + shots[i] + ".png")) missing.push(shots[i]);
      var st = null; try { st = JSON.parse(Score.readFile(DIR + "tests/ui-status.json")); } catch (e) { missing.push("ui-status.json"); }
      if (st) { out("status: " + JSON.stringify(st)); if (!st.lastRecordingPath) missing.push("recording not saved"); if (!st.playback) missing.push("playback not active"); else if (!(st.playback.duration > 2)) missing.push("playback duration " + st.playback.duration); if (!(st.entities > 0)) missing.push("no entities during playback"); }
      if (missing.length) { out("FAIL: " + missing.join(",")); finish(1); } else { out("PASS ui shots + record/playback"); finish(0); }
    });
  } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
})();
