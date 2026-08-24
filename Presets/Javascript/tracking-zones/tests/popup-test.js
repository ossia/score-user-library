// popup-test.js — open a sources-panel combobox and screenshot the popup (readability check).
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var SHOT = DIR + "tests/shots/";
  var OUT = DIR + "tests/popup-test.out";
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
      "    [2.0, { cmd: 'ui', action: 'tab', value: 0 }],",
      "    [3.0, { cmd: 'ui', action: 'synth', steps: [ { t: 'click', view: 'ui', px: 170, py: 692 } ] }],",
      "    [4.0, { cmd: 'ui', action: 'graboverlay', path: '" + SHOT + "popup-units.png' }],",
      "    [4.6, { cmd: 'ui', action: 'synth', steps: [ { t: 'key', key: Qt.Key_Escape } ] }],",
      "    [5.2, { cmd: 'ui', action: 'synth', steps: [ { t: 'click', view: 'ui', px: 1150, py: 145 } ] }],",   // inspector Role combo
      "    [6.0, { cmd: 'ui', action: 'grab', path: '" + SHOT + "popup-role.png' }]",
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
    after(8500, function () {
      Score.stop();
      var f = [];
      if (!Util.fileExists(SHOT + "popup-units.png")) f.push("no units popup shot");
      if (f.length) { out("FAIL: " + f.join("; ")); finish(1); } else { out("PASS popup shots"); finish(0); }
    });
  } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
})();
