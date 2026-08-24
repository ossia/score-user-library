// sources-test.js — per-inlet multi-source: a {name: payload} map on one inlet becomes several
// sources sharing that inlet's calibration, with ids prefixed by the sub-source name.
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var SHOT = DIR + "tests/shots/";
  var OUT = DIR + "tests/sources-test.out";
  var LOG = DIR + "tests/sources-log.json";
  var report = [];
  function out(s) { report.push(s); console.log(s); }
  function finish(code) { Util.writeFile(OUT, report.join("\n") + "\n"); Qt.createQmlObject('import QtQuick; Timer { interval: 800; running: true; repeat: false; onTriggered: Qt.exit(' + code + ') }', Score, "exitTimer"); }
  function after(ms, fn) { var t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "t" + ms); t.fired.connect(fn); return t; }
  try {
    Util.writeFile(LOG, "{}");
    var itv = Score.rootInterval();
    // Source 2's calibration shifts everything +10 in x: both sub-sources must inherit it.
    var doc = { sources: [null, { transform: { pos: [10, 0, 0], rot: [0, 0, 0], scale: [1, 1, 1] } }] };
    var docJson = JSON.stringify(doc).replace(/\\/g, "\\\\").replace(/'/g, "\\'");
    var driverSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueOutlet { id: multi; objectName: 'multi' }",
      "  ValueOutlet { id: cmd; objectName: 'cmd' }",
      "  property int n: 0",
      "  property var actions: [[3.0, { cmd: 'ui', action: 'tab', value: 0 }], [5.5, { cmd: 'ui', action: 'grab', path: '" + SHOT + "sources-map.png' }]]",
      "  property int nextAction: 0",
      "  property real t0: -1",
      "  tick: function(token, state) {",
      "    n++; var t = token.date / 705600000; if (t0 < 0) t0 = t;",
      "    if (n === 2) { cmd.value = { cmd: 'doc', doc: '" + docJson + "' }; return; }",
      "    if (nextAction < actions.length && t - t0 >= actions[nextAction][0]) { cmd.value = actions[nextAction][1]; nextAction++; }",
      "    multi.value = { cam1: [ { id: 1, position: Qt.vector3d(Math.cos(t) * 0.1, Math.sin(t) * 0.1, 0) } ], lidar_front: [ { id: 2, position: Qt.vector3d(2, 0, 0) }, { id: 3, position: Qt.vector3d(-2, 1, 0) } ] };",
      "  }",
      "}"
    ].join("\n");
    var loggerSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueInlet { id: ein; objectName: 'entities' }",
      "  property var log: ({ ticks: 0, lastEntities: null })",
      "  tick: function(token, state) {",
      "    log.ticks++;",
      "    if (ein.value !== undefined) log.lastEntities = ein.value;",
      "    if (log.ticks % 30 === 0) Util.writeFile('" + LOG + "', JSON.stringify(log));",
      "  }",
      "}"
    ].join("\n");
    var driver = Score.createProcess(itv, "Javascript", driverSrc);
    var zones = Score.createProcess(itv, "Javascript", DIR + "tracking-zones.qml");
    var logger = Score.createProcess(itv, "Javascript", loggerSrc);
    Score.setName(zones, "Tracking Zones");
    Score.createCable(Score.port(driver, "multi"), Score.port(zones, "Source 2"));
    Score.createCable(Score.port(driver, "cmd"), Score.port(zones, "Command"));
    Score.createCable(Score.port(zones, "Entities"), Score.port(logger, "entities"));
    after(1500, function () { Score.play(); Score.showProcessUI(zones, true); });
    after(9500, function () {
      Score.stop();
      try {
        var log = JSON.parse(Score.readFile(LOG));
        var es = log.lastEntities || [];
        var byId = {}; es.forEach(function (e) { byId[e.id] = e; });
        out("entities: " + es.map(function (e) { return e.id + "@" + e.pos.x.toFixed(1) + "," + e.pos.y.toFixed(1) + " src" + e.src; }).join("  "));
        var f = [];
        if (es.length !== 3) f.push("expected 3 entities, got " + es.length);
        if (!byId["cam1.1"]) f.push("missing cam1.1");
        if (!byId["lidar_front.2"] || !byId["lidar_front.3"]) f.push("missing lidar_front ids");
        var l2 = byId["lidar_front.2"];
        if (l2 && Math.abs(l2.pos.x - 12) > 0.01) f.push("inlet calibration not applied to sub-source: " + JSON.stringify(l2.pos));
        var c1 = byId["cam1.1"];
        if (c1 && Math.abs(c1.pos.x - 10) > 0.2) f.push("inlet calibration not applied to cam1: " + JSON.stringify(c1.pos));
        if (c1 && c1.src !== 1) f.push("src should be the inlet index 1, got " + JSON.stringify(c1 && c1.src));
        if (!Util.fileExists(SHOT + "sources-map.png")) f.push("no screenshot");
        if (f.length) { out("FAIL: " + f.join("; ")); finish(1); } else { out("PASS source maps per inlet"); finish(0); }
      } catch (e) { out("FAIL " + e); finish(1); }
    });
  } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
})();
