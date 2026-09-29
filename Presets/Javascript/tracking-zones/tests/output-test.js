// output-test.js — the simple event outlets (Enter/Leave/Dwell/Occupancy) and the Location
// outlet through real processes and cables, including the per-zone event opt-out.
// A one-shot document command is followed by live editor-style mask updates while tracking.
// Phases (2 s each): enabled Hot, zone-muted Cold, outside, global-muted Hot, outside,
// both-muted Hot, re-enabled while inside, outside, enabled Hot, muted after firing,
// re-enabled while inside, outside. Muted threshold crossings must not replay on re-enable.
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
      "      { id: 'cold', name: 'Cold', shape: { type: 'rect', w: 2, h: 2 }, pos: [4, 0, 0], dwell: { loiterS: 1 }, events: { enter: false } }",
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
      "    var k = Math.min(11, Math.floor((t - t0) / " + PHASE + "));",
      "    var pos = k === 1 ? [4, 0] : ([2, 4, 7, 11].indexOf(k) >= 0 ? [10, 10] : [0, 0]);",
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
      "  ValueInlet { id: allin; objectName: 'events' }",
      "  ValueInlet { id: zin; objectName: 'zones' }",
      "  property real t0: -1",
      "  property var acc: ({ enter: [], leave: [], dwell: [], occ: [], loc: [], events: [], telemetry: {} })",
      "  function jv(v) {",
      "    if (v === null || v === undefined) return v;",
      "    if (typeof v === 'object' && typeof v.length === 'number') { var a = []; for (var i = 0; i < v.length; i++) a.push(jv(v[i])); return a; }",
      "    if (typeof v === 'object') { var m = {}; for (var k in v) m[k] = jv(v[k]); return m; }",
      "    return v;",
      "  }",
      "  tick: function(token, state) {",
      "    var t = token.date / 705600000; if (t0 < 0) t0 = t;",
      "    var phase = Math.floor((t - t0) / " + PHASE + ");",
      "    var got = false;",
      "    var ins = [[ein, 'enter'], [lin, 'leave'], [din, 'dwell'], [oin, 'occ'], [pin, 'loc'], [allin, 'events']];",
      "    for (var i = 0; i < ins.length; i++) {",
      "      var vs = ins[i][0].values;",
      "      if (vs && vs.length) { for (var j = 0; j < vs.length; j++) { acc[ins[i][1]].push(jv(vs[j].value)); got = true; } }",
      "    }",
      "    var zs = zin.value;",
      "    if ((phase === 1 || phase === 3 || phase === 5) && zs) for (var z = 0; z < zs.length; z++) {",
      "      if (zs[z].count === 1 && zs[z].dwell_now > 1 && zs[z].per_id[0].dwell > 1) { acc.telemetry[phase] = jv(zs[z]); got = true; }",
      "    }",
      "    if (got) Util.writeFile('" + LOG + "', JSON.stringify(acc));",
      "  }",
      "}"
    ].join("\n");
    var driver = Score.createProcess(itv, "Javascript", driverSrc);
    // Run the real process, adding only a deterministic live-update driver. The retained
    // Command value remains the original enabled document, reproducing stale-command replay.
    var zonesSrc = Score.readFile(DIR + "tracking-zones.qml");
    var importDir = (DIR.charAt(0) === "/" ? "file://" : "file:///") + DIR;
    zonesSrc = zonesSrc.replace(/import "([^"]+\.js)"/g, function (_, file) { return 'import "' + importDir + file + '"'; });
    var liveDriver = [
      "  property real maskTestT0: -1",
      "  property int maskTestPhase: -1",
      "  onLastTChanged: {",
      "    if (maskTestT0 < 0) maskTestT0 = lastT;",
      "    var phase = Math.floor((lastT - maskTestT0) / " + PHASE + ");",
      "    if (phase !== maskTestPhase && doc.zones.length === 2) {",
      "      maskTestPhase = phase;",
      "      var live = JSON.parse(JSON.stringify(doc));",
      "      switch (phase) {",
      "      case 1: live.zones[1].events.dwell = false; break;",
      "      case 3: live.settings.events.dwell = false; break;",
      "      case 5: live.settings.events.dwell = false; live.zones[0].events.dwell = false; break;",
      "      case 6: live.settings.events.dwell = true; live.zones[0].events.dwell = true; break;",
      "      case 9: live.settings.events.dwell = false; break;",
      "      case 10: live.settings.events.dwell = true; break;",
      "      default: return;",
      "      }",
      "      root.uiEvent({ type: 'doc', doc: JSON.stringify(live) });",
      "    }",
      "  }"
    ].join("\n");
    zonesSrc = zonesSrc.slice(0, zonesSrc.lastIndexOf("}")) + liveDriver + "\n}";
    var zones = Score.createProcess(itv, "Javascript", zonesSrc);
    var logger = Score.createProcess(itv, "Javascript", loggerSrc);
    Score.setName(zones, "Tracking Zones");
    Score.createCable(Score.port(driver, "o"), Score.port(zones, "Source 1"));
    Score.createCable(Score.port(driver, "c"), Score.port(zones, "Command"));
    Score.createCable(Score.port(zones, "Enter"), Score.port(logger, "enter"));
    Score.createCable(Score.port(zones, "Leave"), Score.port(logger, "leave"));
    Score.createCable(Score.port(zones, "Dwell"), Score.port(logger, "dwell"));
    Score.createCable(Score.port(zones, "Occupancy"), Score.port(logger, "occ"));
    Score.createCable(Score.port(zones, "Location"), Score.port(logger, "loc"));
    Score.createCable(Score.port(zones, "Events"), Score.port(logger, "events"));
    Score.createCable(Score.port(zones, "Zones"), Score.port(logger, "zones"));
    after(1500, function () { Score.play(); });
    after(1500 + 12 * PHASE * 1000 + 1500, function () {
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
        // The first and the new enabled Hot visit fire once each; all muted visits are silent.
        // Re-enabling never replays a threshold already crossed, whether muted or emitted.
        if (R.dwell.length !== 2 || !R.dwell.every(function (d) { return d && d.zone === "Hot" && d.type === "dwell" && d.dwell >= 1; })) f.push("Dwell outlet ignored live masks or one-shot semantics: " + JSON.stringify(R.dwell));
        var dwellEvents = [];
        R.events.forEach(function (batch) { batch.forEach(function (ev) { if (ev.type === "dwell") dwellEvents.push(ev); }); });
        if (dwellEvents.length !== 2 || !dwellEvents.every(function (ev) { return ev.zone === "Hot" && ev.dwell >= 1; })) f.push("Events outlet ignored live dwell masks: " + JSON.stringify(dwellEvents));
        [1, 3, 5].forEach(function (phase) { if (!R.telemetry[phase]) f.push("dwell telemetry suppressed in muted phase " + phase); });
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
