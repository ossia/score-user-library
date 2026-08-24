// reset-test.js — double-click on a numeric field resets it to the model default; plus a screenshot
// of the source cards to check the combos' right edge.
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var SHOT = DIR + "tests/shots/";
  var OUT = DIR + "tests/reset-test.out";
  var ST = DIR + "tests/reset-status";
  var report = [];
  function out(s) { report.push(s); console.log(s); }
  function finish(code) { Util.writeFile(OUT, report.join("\n") + "\n"); Qt.createQmlObject('import QtQuick; Timer { interval: 800; running: true; repeat: false; onTriggered: Qt.exit(' + code + ') }', Score, "exitTimer"); }
  function after(ms, fn) { var t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "t" + ms); t.fired.connect(fn); return t; }
  try {
    var itv = Score.rootInterval();
    var driverSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueOutlet { id: cmd; objectName: 'cmd' }",
      "  property var actions: [",
      "    [2.0, { cmd: 'ui', action: 'addZone', zoneType: 'rect', x: 0, y: 0 }],",
      "    [2.6, { cmd: 'ui', action: 'setProp', path: 'pos.0', value: 3 }],",
      "    [3.0, { cmd: 'ui', action: 'setProp', path: 'shape.w', value: 5 }],",
      "    [3.6, { cmd: 'ui', action: 'dumpstatus', path: '" + ST + "-before.json' }],",
      // inspector: X field row (y 292) and Width field row (y 439) at x 1150 (window 1280x860)
      "    [4.0, { cmd: 'ui', action: 'synth', steps: [ { t: 'dblclick', view: 'ui', px: 1150, py: 292 } ] }],",
      "    [4.8, { cmd: 'ui', action: 'synth', steps: [ { t: 'dblclick', view: 'ui', px: 1150, py: 439 } ] }],",
      "    [5.6, { cmd: 'ui', action: 'dumpstatus', path: '" + ST + "-after.json' }],",
      "    [6.0, { cmd: 'ui', action: 'tab', value: 0 }],",
      "    [6.6, { cmd: 'ui', action: 'grab', path: '" + SHOT + "sources-combos.png' }]",
      "  ]",
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
    after(1500, function () { Score.play(); Score.showProcessUI(zones, true); });
    after(9500, function () {
      Score.stop();
      try {
        var b = JSON.parse(Score.readFile(ST + "-before.json")), a = JSON.parse(Score.readFile(ST + "-after.json"));
        out("before: pos " + JSON.stringify(b.selected.pos) + " w " + b.selected.shape.w + "   after: pos " + JSON.stringify(a.selected.pos) + " w " + a.selected.shape.w);
        var f = [];
        if (b.selected.pos[0] !== 3 || b.selected.shape.w !== 5) f.push("setup failed");
        if (Math.abs(a.selected.pos[0]) > 1e-9) f.push("double click did not reset X to 0: " + a.selected.pos[0]);
        if (Math.abs(a.selected.shape.w - 2) > 1e-9) f.push("double click did not reset width to default 2: " + a.selected.shape.w);
        if (!Util.fileExists(SHOT + "sources-combos.png")) f.push("no screenshot");
        if (f.length) { out("FAIL: " + f.join("; ")); finish(1); } else { out("PASS double-click reset"); finish(0); }
      } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
    });
  } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
})();
