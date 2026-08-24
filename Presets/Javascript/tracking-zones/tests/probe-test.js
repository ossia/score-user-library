// probe-test.js — what does a pose entity look like after the ossia cable round-trip?
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var OUT = DIR + "tests/probe.log.json";
  function after(ms, fn) { var t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "t" + ms); t.fired.connect(fn); return t; }
  var itv = Score.rootInterval();
  var driverSrc = [
    "import Score", "import QtQuick",
    "Script {",
    "  ValueOutlet { id: o; objectName: 'o' }",
    "  tick: function(token, state) {",
    "    var kps = [];",
    "    for (var i = 0; i < 4; i++) kps.push({ x: 0.5, y: 0.5, z: 0, confidence: 0.95 });",
    "    o.value = [{ keypoints: kps, track_id: 3, box: { x: 0.35, y: 0.2, w: 0.3, h: 0.6 } }];",
    "  }",
    "}"
  ].join("\n");
  var loggerSrc = [
    "import Score", "import QtQuick",
    "Script {",
    "  ValueInlet { id: i; objectName: 'i' }",
    "  property bool done: false",
    "  tick: function(token, state) {",
    "    if (done || i.value === undefined) return; done = true;",
    "    var v = i.value; var m = v && v[0];",
    "    var r = { json: JSON.stringify(v), isArr: Array.isArray(v), m_type: typeof m };",
    "    if (m) { var k = m.keypoints; r.kp_type = typeof k; r.kp_isArr = Array.isArray(k); r.kp_len = k ? k.length : -1; r.kp0 = k && k[0] !== undefined ? JSON.stringify(k[0]) : 'undef'; r.keys = []; for (var p in m) r.keys.push(p); }",
    "    Util.writeFile('" + OUT + "', JSON.stringify(r));",
    "  }",
    "}"
  ].join("\n");
  var driver = Score.createProcess(itv, "Javascript", driverSrc);
  var logger = Score.createProcess(itv, "Javascript", loggerSrc);
  Score.createCable(Score.port(driver, "o"), Score.port(logger, "i"));
  after(1500, function () { Score.play(); });
  after(4500, function () { Score.stop(); Qt.createQmlObject('import QtQuick; Timer { interval: 500; running: true; repeat: false; onTriggered: Qt.exit(0) }', Score, "exitTimer"); });
})();
