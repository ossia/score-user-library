// mouse-test.js — drives the editor with in-process synthetic mouse/keyboard events (QtTest injection through the
// Command inlet → exec → UI "synth" action), then dumps the resulting document for assertions.
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var SHOT = DIR + "tests/shots/";
  var OUT = DIR + "tests/mouse-test.out";
  var DOC = DIR + "tests/mouse-doc.json";
  var report = [];
  function out(s) { report.push(s); console.log(s); }
  function finish(code) { Util.writeFile(OUT, report.join("\n") + "\n"); Qt.createQmlObject('import QtQuick; Timer { interval: 800; running: true; repeat: false; onTriggered: Qt.exit(' + code + ') }', Score, "exitTimer"); }
  function after(ms, fn) { var t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "t" + ms); t.fired.connect(fn); return t; }
  try {
    Util.writeFile(DOC, "");
    var itv = Score.rootInterval();
    var K1 = 0x31, K2 = 0x32, K3 = 0x33, K4 = 0x34, K5 = 0x35, K7 = 0x37, KDEL = 0x01000007, KZ = 0x5a;
    var steps = [
      { t: "click", x: -4, y: 3 },                                        // focus canvas
      { t: "tool", value: "rect" }, { t: "drag", x: -3, y: 1, x1: -1, y1: -1 },  // rectangle (-3,1)->(-1,-1)
      { t: "tool", value: "circle" }, { t: "drag", x: 2, y: 0, x1: 3, y1: 0 },     // circle centre (2,0) r 1
      { t: "tool", value: "polygon" }, { t: "click", x: -3, y: -2 }, { t: "click", x: -1, y: -2 }, { t: "click", x: -1, y: -3.5 }, { t: "move", x: -2.2, y: -3 }, { t: "click", x: -2.2, y: -3, button: "right" }, // polygon
      { t: "tool", value: "line" }, { t: "drag", x: 1, y: -2, x1: 3, y1: -2 },   // line (1,-2)->(3,-2)
      { t: "tool", value: "select" }, { t: "click", x: -2, y: 0 }, { t: "drag", x: -2, y: 0, x1: -1.5, y1: 0 },   // select rect, move +0.5 x
      { t: "click", x: 2, y: 0.3 }, { t: "drag", x: 3, y: 0, x1: 3.5, y1: 0 },                         // select circle, radius handle -> 1.5
      { t: "click", x: -2, y: -2.5 }, { t: "drag", x: -1, y: -3.5, x1: -1, y1: -4 },                    // select polygon, drag vertex (-1,-3.5)->(-1,-4)
      { t: "tool", value: "sim" }, { t: "click", x: 0, y: 2 },                  // add a sim dummy
      { t: "tool", value: "select" },
      { t: "wheel", x: 0, y: 0, delta: 240 }                               // zoom in a bit
    ];
    var actions = [
      [1.5, { cmd: "ui", action: "center", x: 0, y: 0 }],
      [1.5, { cmd: "ui", action: "zoom", value: 60 }],
      [3.0, { cmd: "ui", action: "synth", steps: steps }],
      [5.0, { cmd: "ui", action: "grab", path: SHOT + "mouse-result.png" }],
      [5.5, { cmd: "ui", action: "dumpdoc", path: DOC }],
      [6.0, { cmd: "ui", action: "undo" }],
      [6.5, { cmd: "ui", action: "dumpdoc", path: DIR + "tests/mouse-doc-after-undo.json" }],
      [7.0, { cmd: "ui", action: "redo" }],
      [7.5, { cmd: "ui", action: "dumpdoc", path: DIR + "tests/mouse-doc-after-redo.json" }]
    ];
    var actJson = JSON.stringify(actions).replace(/\\/g, "\\\\").replace(/'/g, "\\'");
    var driverSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueOutlet { id: cmd; objectName: 'cmd' }",
      "  property var actions: JSON.parse('" + actJson + "')",
      "  property int nextAction: 0",
      "  property real t0: -1",
      "  tick: function(token, state) {",
      "    var t = token.date / 705600000; if (t0 < 0) t0 = t;",
      "    if (nextAction < actions.length && t - t0 >= actions[nextAction][0]) { cmd.value = actions[nextAction][1]; nextAction++; }",
      "  }",
      "}"
    ].join("\n");
    var driver = Score.createProcess(itv, "Javascript", driverSrc);
    var zones = Score.createProcess(itv, "Javascript", DIR + "tracking-zones.qml");
    Score.setName(zones, "Tracking Zones");
    Score.createCable(Score.port(driver, "cmd"), Score.port(zones, "Command"));
    after(1500, function () { Score.play(); });   // the audio engine needs a moment after document load
    Score.showProcessUI(zones, true);
    out("ui shown");
    after(10000, function () {
      Score.stop();
      try {
        var d = JSON.parse(Score.readFile(DOC));
        var zs = d.doc.zones;
        out("zones: " + zs.map(function (z) { return z.shape.type + "@" + z.pos.map(function (v) { return v.toFixed(2); }).join(",") + (z.shape.w ? " w=" + z.shape.w.toFixed(2) + " h=" + z.shape.h.toFixed(2) : "") + (z.shape.r ? " r=" + z.shape.r.toFixed(2) : "") + (z.shape.points ? " pts=" + JSON.stringify(z.shape.points.map(function (p) { return [+p[0].toFixed(2), +p[1].toFixed(2)]; })) : ""); }).join(" | "));
        out("sim=" + d.sim.length + " tool=" + d.tool);
        var f = [];
        var rect = zs.filter(function (z) { return z.shape.type === "rect"; })[0];
        var circ = zs.filter(function (z) { return z.shape.type === "circle"; })[0];
        var poly = zs.filter(function (z) { return z.shape.type === "polygon"; })[0];
        var line = zs.filter(function (z) { return z.shape.type === "line"; })[0];
        if (!rect) f.push("no rect"); else { if (Math.abs(rect.shape.w - 2) > 0.05 || Math.abs(rect.shape.h - 2) > 0.05) f.push("rect size " + rect.shape.w + "x" + rect.shape.h); if (Math.abs(rect.pos[0] + 1.5) > 0.05 || Math.abs(rect.pos[1]) > 0.05) f.push("rect pos " + rect.pos); }
        if (!circ) f.push("no circle"); else { if (Math.abs(circ.shape.r - 1.5) > 0.05) f.push("circle r " + circ.shape.r); if (Math.abs(circ.pos[0] - 2) > 0.05) f.push("circle pos " + circ.pos); }
        if (!poly) f.push("no polygon"); else { if (poly.shape.points.length !== 3) f.push("poly points " + poly.shape.points.length); var ys = poly.shape.points.map(function (p) { return p[1] + poly.pos[1]; }); if (Math.min.apply(null, ys) > -3.9) f.push("poly vertex not dragged (min y " + Math.min.apply(null, ys) + ")"); }
        if (!line) f.push("no line"); else { var a = line.shape.points[0], b = line.shape.points[1]; if (Math.abs((b[0] - a[0]) - 2) > 0.05) f.push("line length"); }
        if (d.sim.length !== 1) f.push("sim dummies " + d.sim.length);
        var du = JSON.parse(Score.readFile(DIR + "tests/mouse-doc-after-undo.json"));
        var dr = JSON.parse(Score.readFile(DIR + "tests/mouse-doc-after-redo.json"));
        out("after undo: " + du.doc.zones.length + " zones, poly pts " + JSON.stringify(du.doc.zones.filter(function (z) { return z.shape.type === "polygon"; }).map(function (z) { return z.shape.points.map(function (p) { return [+p[0].toFixed(2), +p[1].toFixed(2)]; }); })));
        var polyU = du.doc.zones.filter(function (z) { return z.shape.type === "polygon"; })[0];
        if (polyU) { var ysU = polyU.shape.points.map(function (p) { return p[1] + polyU.pos[1]; }); if (Math.min.apply(null, ysU) < -3.9) f.push("undo did not revert vertex drag"); }
        var polyR = dr.doc.zones.filter(function (z) { return z.shape.type === "polygon"; })[0];
        if (polyR) { var ysR = polyR.shape.points.map(function (p) { return p[1] + polyR.pos[1]; }); if (Math.min.apply(null, ysR) > -3.9) f.push("redo did not reapply vertex drag"); }
        if (f.length) { out("FAIL: " + f.join("; ")); finish(1); } else { out("PASS mouse/synth"); finish(0); }
      } catch (e) { out("FAIL exception " + e + " " + e.stack); finish(1); }
    });
  } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
})();
