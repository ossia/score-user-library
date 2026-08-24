// view3d-test.js — 3D picking + gizmo: loads two zones, switches to the 3D view, selects a zone by clicking it,
// drags the gizmo X arrow, the XY pad, the rotation ring and the zone body, and checks the resulting document.
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var SHOT = DIR + "tests/shots/";
  var OUT = DIR + "tests/view3d-test.out";
  var ST = DIR + "tests/view3d-status.json";
  var DOC = DIR + "tests/view3d-doc.json";
  var report = [];
  function out(s) { report.push(s); console.log(s); }
  function finish(code) { Util.writeFile(OUT, report.join("\n") + "\n"); Qt.createQmlObject('import QtQuick; Timer { interval: 800; running: true; repeat: false; onTriggered: Qt.exit(' + code + ') }', Score, "exitTimer"); }
  function after(ms, fn) { var t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "t" + ms); t.fired.connect(fn); return t; }
  try {
    Util.writeFile(ST, ""); Util.writeFile(DOC, "");
    var itv = Score.rootInterval();
    var doc = { zones: [
      { name: "A", shape: { type: "rect", w: 2, h: 2 }, pos: [-2, 0, 0] },
      { name: "B", shape: { type: "box", w: 1.5, h: 1.5, d: 1.5 }, pos: [6, -3, 0.75], color: "#9b7bd6" }
    ] };
    var docJson = JSON.stringify(doc).replace(/\\/g, "\\\\").replace(/'/g, "\\'");
    // phase 1: 3D view, click zone A in the 3D view (its centre on the floor)
    var actions = [
      [1.5, { cmd: "ui", action: "view", value: "3d" }],
      [3.0, { cmd: "ui", action: "synth", steps: [{ t: "click", view: "3d", x: -2, y: 0, z: 0.01 }] }],
      [3.8, { cmd: "ui", action: "dumpstatus", path: ST }]
    ];
    var actJson = JSON.stringify(actions).replace(/\\/g, "\\\\").replace(/'/g, "\\'");
    var driverSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueOutlet { id: cmd; objectName: 'cmd' }",
      "  ValueInlet { id: extra; objectName: 'extra' }",
      "  property var actions: JSON.parse('" + actJson + "')",
      "  property int nextAction: 0",
      "  property real t0: -1",
      "  property int n: 0",
      "  tick: function(token, state) {",
      "    n++; var t = token.date / 705600000; if (t0 < 0) t0 = t;",
      "    if (n === 2) { cmd.value = { cmd: 'doc', doc: '" + docJson + "' }; return; }",
      "    if (nextAction < actions.length && t - t0 >= actions[nextAction][0]) { cmd.value = actions[nextAction][1]; nextAction++; }",
      "    var ex = extra.value; if (ex !== undefined && ex !== null) cmd.value = ex;",
      "  }",
      "}"
    ].join("\n");
    var driver = Score.createProcess(itv, "Javascript", driverSrc);
    var zones = Score.createProcess(itv, "Javascript", DIR + "tracking-zones.qml");
    Score.setName(zones, "Tracking Zones");
    Score.createCable(Score.port(driver, "cmd"), Score.port(zones, "Command"));
    // a second driver we can feed later through its control: use a LineEdit? simpler: a second JS process with a LineEdit we set from the console
    var feederSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  LineEdit { id: le; objectName: 'json'; text: '' }",
      "  ValueOutlet { id: o; objectName: 'out' }",
      "  property string last: ''",
      "  tick: function(token, state) { var v = le.value; if (v && v !== last) { last = v; try { o.value = JSON.parse(v); } catch (e) { console.log('feeder bad json', e); } } }",
      "}"
    ].join("\n");
    var feeder = Score.createProcess(itv, "Javascript", feederSrc);
    Score.createCable(Score.port(feeder, "out"), Score.port(driver, "extra"));
    var feederPort = Score.port(feeder, "json");
    function send(cmdObj) { Score.setValue(feederPort, JSON.stringify(cmdObj)); }
    after(1500, function () { Score.play(); });   // the audio engine needs a moment after document load
    Score.showProcessUI(zones, true);
    out("ui shown");
    var f = [];
    after(6500, function () {
      try {
        var st = JSON.parse(Score.readFile(ST));
        out("after click: selected=" + JSON.stringify(st.selected) + " gizmo=" + JSON.stringify(st.gizmo));
        if (!st.selected || st.selected.name !== "A") { f.push("3D pick did not select A"); }
        if (!st.gizmo || !st.gizmo.visible || !(st.gizmo.len > 0)) f.push("gizmo not visible");
        var L = st.gizmo && st.gizmo.len ? st.gizmo.len : 1;
        // phase 2: gizmo interactions (world coords; gizmo arrows live along +X/+Y/+Z from the target)
        var steps = [
          { t: "drag", view: "3d", x: -2 + 0.7 * L, y: 0, z: 0, x1: -2 + 0.7 * L + 1.0, y1: 0, z1: 0, n: 10 },        // X arrow: +1 m
          { t: "drag", view: "3d", x: -1 + 0.3 * L, y: 0.3 * L, z: 0, x1: -1 + 0.3 * L, y1: 0.3 * L + 1.0, z1: 0, n: 10 }   // XY pad: +1 m in y
        ];
        send({ cmd: "ui", action: "synth", steps: steps });
        after(400, function () { send({ cmd: "ui", action: "gizmo", value: "rotate" }); });
        after(700, function () { send({ cmd: "ui", action: "synth", steps: [
          { t: "drag", view: "3d", x: -1 + 1.1 * L, y: 1, z: 0, x1: -1, y1: 1 + 1.1 * L, z1: 0, n: 12 }              // ring: from +X side to +Y side ≈ +90°
        ] }); });
        after(1000, function () { send({ cmd: "ui", action: "gizmo", value: "move" }); });
        after(1200, function () { send({ cmd: "ui", action: "dumpstatus", path: ST }); });
        after(2400, function () {
          try {
            var s2 = JSON.parse(Score.readFile(ST));
            out("after gizmo: selected=" + JSON.stringify(s2.selected));
            var p = s2.selected ? s2.selected.pos : null;
            if (!p || Math.abs(p[0] - (-1)) > 0.15) f.push("X arrow drag: pos " + JSON.stringify(p));
            if (!p || Math.abs(p[1] - 1) > 0.15) f.push("XY pad drag: pos " + JSON.stringify(p));
            var r = s2.selected ? s2.selected.rot[2] : 0;
            if (Math.abs(Math.abs(r) - 90) > 15) f.push("ring rotate: rot " + r);
          } catch (e) { f.push("phase2 " + e); }
        });
        after(2600, function () {
          // phase 3: pick zone B (box) by clicking its top face
          send({ cmd: "ui", action: "synth", steps: [{ t: "click", view: "3d", x: 6, y: -3, z: 1.5 }] });
        });
        after(3400, function () { send({ cmd: "ui", action: "dumpstatus", path: ST }); });
        after(4200, function () {
          try {
            var s3 = JSON.parse(Score.readFile(ST));
            out("after click B: selected=" + JSON.stringify(s3.selected));
            if (!s3.selected || s3.selected.name !== "B") f.push("3D pick on box did not select B");
            send({ cmd: "ui", action: "grab", path: SHOT + "view3d-gizmo.png" });
          } catch (e) { f.push("phase3 " + e); }
        });
        after(5400, function () {
          Score.stop();
          if (!Util.fileExists(SHOT + "view3d-gizmo.png")) f.push("no screenshot");
          if (f.length) { out("FAIL: " + f.join("; ")); finish(1); } else { out("PASS view3d pick + gizmo"); finish(0); }
        });
      } catch (e) { out("FAIL exception " + e + " " + e.stack); finish(1); }
    });
  } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
})();
