// output-test.js — the simple event outlets (Enter/Leave/Dwell/Occupancy) and the Location
// outlet through real processes and cables, including the per-zone event opt-out.
// Phases (2 s each) for a single bare-pair entity "0" on Source 1:
//   0: inside "Hot" (dwell loiterS 1 fires)   1: inside "Cold" (whose enter is opted out)   2: outside everything
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var OUT = DIR + "tests/output-test.out";
  var LOG = DIR + "tests/output-log.json";
  var report = [];
  function out(s) { report.push(s); console.log(s); }
  function finish(code) { Util.writeFile(OUT, report.join("\n") + "\n"); Qt.createQmlObject('import QtQuick; Timer { interval: 800; running: true; repeat: false; onTriggered: Qt.exit(' + code + ') }', Score, "exitTimer"); }
  function after(ms, fn) { var t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "t" + ms); t.fired.connect(fn); return t; }
  var PHASE = 2.0;
  try {
    Util.writeFile(LOG, "{}");
    var itv = Score.rootInterval();
    var driverSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueOutlet { id: o; objectName: 'o' }",
      "  ValueOutlet { id: c; objectName: 'c' }",
      "  property real t0: -1",
      "  property bool sent: false",
      "  function doc() {",
      "    return { version: 1, zones: [",
      "      { id: 'hot', name: 'Hot', shape: { type: 'rect', w: 2, h: 2 }, pos: [0, 0, 0], dwell: { loiterS: 1 } },",
      "      { id: 'cold', name: 'Cold', shape: { type: 'rect', w: 2, h: 2 }, pos: [4, 0, 0], events: { enter: false } }",
      "    ], settings: { outputs: {",
      "      enter: { enabled: true, format: 'zone' },",
      "      exit: { enabled: true, format: 'pair' },",
      "      dwell: { enabled: true, format: 'map' },",
      "      cross: { enabled: true, format: 'map' },",
      "      occupancy: { enabled: true, format: 'map' },",
      "      location: { enabled: true, format: 'map', all: false, onChange: true, includeOutside: false }",
      "    } } };",
      "  }",
      "  tick: function(token, state) {",
      "    var t = token.date / 705600000; if (t0 < 0) t0 = t;",
      "    if (!sent) { sent = true; c.value = { cmd: 'doc', doc: JSON.stringify(doc()) }; }",
      "    var k = Math.min(2, Math.floor((t - t0) / " + PHASE + "));",
      "    var pos = k === 0 ? [0, 0] : (k === 1 ? [4, 0] : [10, 10]);",
      "    o.value = [pos];",
      "  }",
      "}"
    ].join("\n");
    var loggerSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueInlet { id: ein; objectName: 'enter' }",
      "  ValueInlet { id: lin; objectName: 'leave' }",
      "  ValueInlet { id: din; objectName: 'dwell' }",
      "  ValueInlet { id: oin; objectName: 'occ' }",
      "  ValueInlet { id: pin; objectName: 'loc' }",
      "  property var acc: ({ enter: [], leave: [], dwell: [], occ: [], loc: [] })",
      "  function jv(v) {",
      "    if (v === null || v === undefined) return v;",
      "    if (typeof v === 'object' && typeof v.length === 'number') { var a = []; for (var i = 0; i < v.length; i++) a.push(jv(v[i])); return a; }",
      "    if (typeof v === 'object') { var m = {}; for (var k in v) m[k] = jv(v[k]); return m; }",
      "    return v;",
      "  }",
      "  tick: function(token, state) {",
      "    var got = false;",
      "    var ins = [[ein, 'enter'], [lin, 'leave'], [din, 'dwell'], [oin, 'occ'], [pin, 'loc']];",
      "    for (var i = 0; i < ins.length; i++) {",
      "      var vs = ins[i][0].values;",
      "      if (vs && vs.length) { for (var j = 0; j < vs.length; j++) { acc[ins[i][1]].push(jv(vs[j].value)); got = true; } }",
      "    }",
      "    if (got) Util.writeFile('" + LOG + "', JSON.stringify(acc));",
      "  }",
      "}"
    ].join("\n");
    var driver = Score.createProcess(itv, "Javascript", driverSrc);
    var zones = Score.createProcess(itv, "Javascript", DIR + "tracking-zones.qml");
    var logger = Score.createProcess(itv, "Javascript", loggerSrc);
    Score.setName(zones, "Tracking Zones");
    Score.createCable(Score.port(driver, "o"), Score.port(zones, "Source 1"));
    Score.createCable(Score.port(driver, "c"), Score.port(zones, "Command"));
    Score.createCable(Score.port(zones, "Enter"), Score.port(logger, "enter"));
    Score.createCable(Score.port(zones, "Leave"), Score.port(logger, "leave"));
    Score.createCable(Score.port(zones, "Dwell"), Score.port(logger, "dwell"));
    Score.createCable(Score.port(zones, "Occupancy"), Score.port(logger, "occ"));
    Score.createCable(Score.port(zones, "Location"), Score.port(logger, "loc"));
    after(1500, function () { Score.play(); });
    after(1500 + 3 * PHASE * 1000 + 1500, function () {
      Score.stop();
      try {
        var R = JSON.parse(Score.readFile(LOG));
        var f = [];
        out("enter: " + JSON.stringify(R.enter));
        out("leave: " + JSON.stringify(R.leave));
        out("dwell: " + JSON.stringify(R.dwell));
        out("occ:   " + JSON.stringify(R.occ));
        out("loc:   " + JSON.stringify(R.loc));
        // Enter: format "zone" → bare strings; Cold's enter is opted out per-zone
        if (R.enter.indexOf("Hot") < 0) f.push("no Enter 'Hot'");
        if (R.enter.indexOf("Cold") >= 0) f.push("Cold enter not filtered");
        // Leave: format "pair" → [zone, id]
        function hasPair(list, zone) { return list.some(function (p) { return p && p.length === 2 && p[0] === zone && String(p[1]) === "0"; }); }
        if (!hasPair(R.leave, "Hot")) f.push("no Leave [Hot, 0]");
        if (!hasPair(R.leave, "Cold")) f.push("no Leave [Cold, 0] (opt-out must only hit enter)");
        // Dwell: loiterS 1 in Hot → map with dwell >= 1
        if (!R.dwell.some(function (d) { return d && d.zone === "Hot" && d.type === "dwell" && d.dwell >= 0.9; })) f.push("no Dwell map for Hot");
        // Occupancy: maps; Hot occupied then empty, Cold occupied (occupancy is not opted out)
        function occ(zone, state) { return R.occ.some(function (o) { return o && o.zone === zone && o.occupied === state; }); }
        if (!occ("Hot", true) || !occ("Hot", false)) f.push("Hot occupancy cycle missing");
        if (!occ("Cold", true)) f.push("Cold occupancy missing");
        // Location: on-change maps {id: zone}; ends empty; few messages (not one per tick)
        function locHas(zone) { return R.loc.some(function (m) { return m && m["0"] === zone; }); }
        if (!locHas("Hot")) f.push("no Location {0: Hot}");
        if (!locHas("Cold")) f.push("no Location {0: Cold}");
        var last = R.loc[R.loc.length - 1];
        if (!last || Object.keys(last).length !== 0) f.push("last Location not empty: " + JSON.stringify(last));
        if (R.loc.length > 20) f.push("Location not on-change: " + R.loc.length + " messages");
        if (f.length) { out("FAIL: " + f.join("; ")); finish(1); } else { out("PASS simple outputs + location + per-zone opt-out"); finish(0); }
      } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
    });
  } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
})();
