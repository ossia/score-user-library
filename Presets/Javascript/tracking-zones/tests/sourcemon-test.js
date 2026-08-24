// sourcemon-test.js — Source monitor pane: a Leap-like subtree on Source 1 (with fingers, quaternions,
// active flags, changing every tick) and a raw list on Source 2; check the diagnostics + screenshot.
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var SHOT = DIR + "tests/shots/";
  var OUT = DIR + "tests/sourcemon-test.out";
  var ST = DIR + "tests/sourcemon-status.json";
  var report = [];
  function out(s) { report.push(s); console.log(s); }
  function finish(code) { Util.writeFile(OUT, report.join("\n") + "\n"); Qt.createQmlObject('import QtQuick; Timer { interval: 800; running: true; repeat: false; onTriggered: Qt.exit(' + code + ') }', Score, "exitTimer"); }
  function after(ms, fn) { var t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "t" + ms); t.fired.connect(fn); return t; }
  try {
    Util.writeFile(ST, "");
    var itv = Score.rootInterval();
    var driverSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueOutlet { id: leap; objectName: 'leap' }",
      "  ValueOutlet { id: pts; objectName: 'pts' }",
      "  ValueOutlet { id: cmd; objectName: 'cmd' }",
      "  property var actions: [[3.0, { cmd: 'ui', action: 'tab', value: 3 }], [5.0, { cmd: 'ui', action: 'dumpstatus', path: '" + ST + "' }], [5.4, { cmd: 'ui', action: 'grab', path: '" + SHOT + "source-monitor.png' }]]",
      "  property int nextAction: 0",
      "  property real t0: -1",
      "  function hand(active, x) {",
      "    var f = function (dx) { return { distal: { begin: Qt.vector3d(x + dx, 0.1, 0.2), end: Qt.vector3d(x + dx, 0.15, 0.25) }, orientation: Qt.vector4d(0, 0, 0, 1), width: 0.01, extended: 1 }; };",
      "    return { active: active, palm: { position: Qt.vector3d(x, 0.05 * Math.sin(x * 5), 0.3), velocity: Qt.vector3d(0.2, 0, 0), normal: Qt.vector3d(0, -1, 0), direction: Qt.vector3d(0, 0, -1), orientation: Qt.vector4d(0, 0, 0, 1) }, thumb: f(0.01), index: f(0.02), middle: f(0.03), ring: f(0.04), pinky: f(0.05), pinch: 0.1, grab: 0.2 };",
      "  }",
      "  tick: function(token, state) {",
      "    var t = token.date / 705600000; if (t0 < 0) t0 = t;",
      "    if (nextAction < actions.length && t - t0 >= actions[nextAction][0]) { cmd.value = actions[nextAction][1]; nextAction++; }",
      "    var x = 0.2 * Math.sin(t);",   // hands moving all the time
      "    leap.value = { left: hand(true, x), right: hand(false, -x), num_hands: 1 };",
      "    pts.value = [[1, 2], [3, 4], [5, 6]];",
      "  }",
      "}"
    ].join("\n");
    var driver = Score.createProcess(itv, "Javascript", driverSrc);
    var zones = Score.createProcess(itv, "Javascript", DIR + "tracking-zones.qml");
    Score.setName(zones, "Tracking Zones");
    Score.createCable(Score.port(driver, "leap"), Score.port(zones, "Source 1"));
    Score.createCable(Score.port(driver, "pts"), Score.port(zones, "Source 2"));
    Score.createCable(Score.port(driver, "cmd"), Score.port(zones, "Command"));
    after(1500, function () { Score.play(); Score.showProcessUI(zones, true); });
    after(9000, function () {
      Score.stop();
      try {
        var st = JSON.parse(Score.readFile(ST));
        var si = st.sourceInfo || [];
        out("source info: " + JSON.stringify(si.map(function (r) { return r ? { inlet: r.inlet, msgs: r.msgs, kind: r.kind, parsed: r.parsed, nan: r.nan, ids: r.ids } : null; })));
        var f = [];
        if (!si[0] || si[0].kind.indexOf("map of entities") !== 0) f.push("leap subtree not classified as a map of entities: " + (si[0] && si[0].kind));
        if (!si[0] || si[0].parsed !== 1) f.push("leap: expected 1 active hand, parsed " + (si[0] && si[0].parsed));
        if (!si[0] || si[0].ids.indexOf("left.palm") < 0 || si[0].ids.indexOf("right.palm") >= 0) f.push("inactive hand not hidden: " + (si[0] && si[0].ids));
        if (!si[0] || si[0].nan !== 0) f.push("leap NaN drops");
        if (!si[0] || !si[0].preview || si[0].preview.indexOf("palm") < 0) f.push("no raw preview");
        if (!si[1] || si[1].kind.indexOf("list of lists") !== 0 || si[1].parsed !== 3) f.push("points inlet: " + JSON.stringify(si[1] && { kind: si[1].kind, parsed: si[1].parsed }));
        if (st.entities !== 4) f.push("expected 4 entities live, got " + st.entities);
        if (!Util.fileExists(SHOT + "source-monitor.png")) f.push("no screenshot");
        if (f.length) { out("FAIL: " + f.join("; ")); finish(1); } else { out("PASS source monitor"); finish(0); }
      } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
    });
  } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
})();
