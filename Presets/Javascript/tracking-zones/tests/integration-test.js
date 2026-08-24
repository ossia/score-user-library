// integration-test.js — builds a score graph: driver JS -> Tracking Zones -> logger JS, plays it and checks the outputs.
// Run: score.exe --script "eval(Score.readFile('.../tests/integration-test.js'))"
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var LOG = DIR + "tests/integration.log.json";
  var OUT = DIR + "tests/integration-test.out";
  var report = [];
  function out(s) { report.push(s); console.log(s); }
  function finish(code) {
    Util.writeFile(OUT, report.join("\n") + "\n");
    Qt.createQmlObject('import QtQuick; Timer { interval: 800; running: true; repeat: false; onTriggered: Qt.exit(' + code + ') }', Score, "exitTimer");
  }
  function after(ms, fn) { var t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "t" + ms); t.fired.connect(fn); return t; }
  try {
    Util.writeFile(LOG, "{}");
    var itv = Score.rootInterval();
    out("root interval: " + itv);

    // --- zone document sent through the Command inlet ---
    var doc = {
      zones: [
        { name: "Center", shape: { type: "rect", w: 2, h: 2 }, pos: [0, 0, 0], hysteresis: { margin: 0 } },
        { name: "Gate", shape: { type: "line", points: [[-1, 0], [1, 0]], direction: "both", width: 0.1 }, pos: [2, 0, 0], rot: [0, 0, 90], line: { confirmFrames: 1 } },
        { name: "Far", shape: { type: "circle", r: 1 }, pos: [5, 5, 0] }
      ],
      sources: [{ enabled: true, lostTimeout: 0.3 }],
      settings: { uiRate: 30 }
    };
    var docJson = JSON.stringify(doc).replace(/\\/g, "\\\\").replace(/'/g, "\\'");

    var driverSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueOutlet { id: ents; objectName: 'ents' }",
      "  ValueOutlet { id: cmd; objectName: 'cmd' }",
      "  ValueOutlet { id: multi; objectName: 'multi' }",
      "  property int n: 0",
      "  tick: function(token, state) {",
      "    n++;",
      "    if (n === 2) cmd.value = { cmd: 'doc', doc: '" + docJson + "' };",
      "    var t = token.date / 705600000;",
      "    var x = -3 + 6 * ((t % 3) / 3);",              // entity 1 sweeps x in [-3,3) every 3 s, crossing Center and the Gate at x=2
      "    ents.value = [ { id: 1, position: Qt.vector3d(x, 0, 0), confidence: 1 }, { id: 2, position: Qt.vector3d(5, 5, 0) } ];",
      "    multi.value = { cam1: [ { id: 7, position: Qt.vector3d(0.2, 0.2, 0) } ], lidar: [ { id: 3, position: Qt.vector3d(5.2, 5.2, 0) } ] };",
      "  }",
      "}"
    ].join("\n");

    var loggerSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueInlet { id: zin; objectName: 'zones' }",
      "  ValueInlet { id: evin; objectName: 'events' }",
      "  ValueInlet { id: cin; objectName: 'counts' }",
      "  ValueInlet { id: tin; objectName: 'tree' }",
      "  ValueInlet { id: ein; objectName: 'entities' }",
      "  property var log: ({ ticks: 0, events: [], lastZones: null, lastCounts: null, lastTree: null, lastEntities: null, zoneTicks: 0, maxCenter: 0 })",
      "  tick: function(token, state) {",
      "    log.ticks++;",
      "    var evs = evin.values; if (evs) for (var i = 0; i < evs.length; i++) { var l = evs[i].value; if (l && l.length) for (var j = 0; j < l.length; j++) log.events.push(l[j]); }",
      "    if (zin.value !== undefined) { log.lastZones = zin.value; log.zoneTicks++; if (zin.value[0] && zin.value[0].count > log.maxCenter) log.maxCenter = zin.value[0].count; }",
      "    if (cin.value !== undefined) log.lastCounts = cin.value;",
      "    if (tin.value !== undefined) log.lastTree = tin.value;",
      "    if (ein.value !== undefined) log.lastEntities = ein.value;",
      "    if (log.ticks % 30 === 0) Util.writeFile('" + LOG + "', JSON.stringify(log));",
      "  }",
      "}"
    ].join("\n");

    var driver = Score.createProcess(itv, "Javascript", driverSrc);
    var zones = Score.createProcess(itv, "Javascript", DIR + "tracking-zones.qml");
    var logger = Score.createProcess(itv, "Javascript", loggerSrc);
    out("processes: " + driver + " " + zones + " " + logger);
    out("zones inlets=" + Score.inlets(zones) + " outlets=" + Score.outlets(zones) + " hasUI=" + Score.hasProcessUI(zones));
    Score.setName(zones, "Tracking Zones");

    var ok = true;
    function cable(fromProc, fromPort, toProc, toPort) {
      var o = Score.port(fromProc, fromPort), i = Score.port(toProc, toPort);
      if (!o || !i) { out("MISSING PORT " + fromPort + " -> " + toPort + " : " + o + " " + i); ok = false; return; }
      var c = Score.createCable(o, i); if (!c) { out("CABLE FAILED " + fromPort + " -> " + toPort); ok = false; }
    }
    cable(driver, "ents", zones, "Source 1");
    cable(driver, "cmd", zones, "Command");
    cable(driver, "multi", zones, "Source 2");
    cable(zones, "Zones", logger, "zones");
    cable(zones, "Events", logger, "events");
    cable(zones, "Counts", logger, "counts");
    cable(zones, "Tree", logger, "tree");
    cable(zones, "Entities", logger, "entities");
    if (!ok) { out("FAIL: graph construction"); finish(1); return; }

    after(1500, function () { Score.play(); });   // the audio engine needs a moment after document load
    out("playing…");
    // check after 7 seconds
    var checker = Qt.createQmlObject('import QtQuick; Timer { interval: 9000; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "checkTimer");
    checker.fired.connect(function () {
      try {
        Score.stop();
        var txt = Score.readFile(LOG);
        var log = JSON.parse(txt);
        var evTypes = {}; log.events.forEach(function (e) { evTypes[e.type] = (evTypes[e.type] || 0) + 1; });
        out("ticks=" + log.ticks + " zoneTicks=" + log.zoneTicks + " events=" + JSON.stringify(evTypes));
        out("lastCounts=" + JSON.stringify(log.lastCounts) + " maxCenter=" + log.maxCenter);
        out("lastTree=" + JSON.stringify(log.lastTree));
        out("lastEntities=" + JSON.stringify(log.lastEntities));
        var failures = [];
        if (log.zoneTicks < 50) failures.push("zones outlet did not tick enough: " + log.zoneTicks);
        if (!(evTypes.enter >= 1)) failures.push("no enter events");
        if (!(evTypes.exit >= 1)) failures.push("no exit events");
        if (!(evTypes.cross >= 1)) failures.push("no cross events");
        if (log.maxCenter < 1) failures.push("Center never counted an entity");
        if (!log.lastTree || !log.lastTree.Center) failures.push("tree output missing Center");
        if (!log.lastZones || log.lastZones.length !== 3) failures.push("expected 3 zones in output");
        if (!log.lastEntities || log.lastEntities.length < 1) failures.push("entities output empty");
        var named = log.lastEntities ? log.lastEntities.filter(function (e) { return e.src === 1 && (String(e.id).indexOf("cam1.") === 0 || String(e.id).indexOf("lidar.") === 0); }) : [];
        if (named.length !== 2) failures.push("source map on inlet 2: expected 2 entities from cam1/lidar, got " + named.length);
        var center = log.lastZones ? log.lastZones[0] : null;
        if (center && center.count < 1 && log.lastCounts && log.lastCounts[0] < 1) { /* cam1 entity at (0.2,0.2) should be inside Center */ failures.push("cam1 entity not counted in Center"); }
        var far = log.lastZones ? log.lastZones[2] : null;
        if (!far || far.count !== 2) failures.push("Far should hold entity 2 + lidar.3, got " + JSON.stringify(far && far.count));
        if (failures.length) { out("FAIL: " + failures.join("; ")); finish(1); }
        else { out("PASS integration"); finish(0); }
      } catch (e) { out("FAIL exception " + e + " " + e.stack); finish(1); }
    });
  } catch (e) { out("FAIL setup exception " + e + " " + e.stack); finish(1); }
})();
