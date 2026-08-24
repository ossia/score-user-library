// outputpane-test.js — the Output pane opens (tab 4), renders, and the new settings defaults
// are present in the document; screenshot for visual inspection.
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var SHOT = DIR + "tests/shots/";
  var OUT = DIR + "tests/outputpane-test.out";
  var ST = DIR + "tests/outputpane-status.json";
  var DOC = DIR + "tests/outputpane-doc.json";
  var report = [];
  function out(s) { report.push(s); console.log(s); }
  function finish(code) { Util.writeFile(OUT, report.join("\n") + "\n"); Qt.createQmlObject('import QtQuick; Timer { interval: 800; running: true; repeat: false; onTriggered: Qt.exit(' + code + ') }', Score, "exitTimer"); }
  function after(ms, fn) { var t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "t" + ms); t.fired.connect(fn); return t; }
  try {
    Util.writeFile(ST, ""); Util.writeFile(DOC, "");
    var itv = Score.rootInterval();
    var driverSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueOutlet { id: cmd; objectName: 'cmd' }",
      "  property var actions: [",
      "    [2.0, { cmd: 'ui', action: 'addZone', zoneType: 'rect', x: 0, y: 0 }],",
      "    [3.0, { cmd: 'ui', action: 'tab', value: 4 }],",
      "    [4.5, { cmd: 'ui', action: 'dumpstatus', path: '" + ST + "' }],",
      "    [4.7, { cmd: 'ui', action: 'dumpdoc', path: '" + DOC + "' }],",
      "    [5.0, { cmd: 'ui', action: 'grab', path: '" + SHOT + "output-pane.png' }]",
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
    after(9000, function () {
      Score.stop();
      try {
        var st = JSON.parse(Score.readFile(ST));
        var dd = JSON.parse(Score.readFile(DOC));
        var f = [];
        if (st.bottomTab !== 4) f.push("Output tab not active: " + st.bottomTab);
        var s = dd.doc && dd.doc.settings;
        if (!s || !s.events || s.events.enter !== true || s.events.proximity !== true) f.push("settings.events defaults missing");
        if (!s || !s.outputs || !s.outputs.enter || s.outputs.enter.format !== "map") f.push("settings.outputs.enter default missing");
        if (!s || !s.outputs || !s.outputs.location || s.outputs.location.onChange !== true) f.push("settings.outputs.location default missing");
        var z = dd.doc && dd.doc.zones && dd.doc.zones[0];
        if (!z || typeof z.events !== "object") f.push("zone.events missing on a new zone");
        if (!Util.fileExists(SHOT + "output-pane.png")) f.push("no screenshot");
        out("bottomTab " + st.bottomTab + ", outputs " + JSON.stringify(s && s.outputs && Object.keys(s.outputs)));
        if (f.length) { out("FAIL: " + f.join("; ")); finish(1); } else { out("PASS output pane"); finish(0); }
      } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
    });
  } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
})();
