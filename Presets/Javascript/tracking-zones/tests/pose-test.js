// pose-test.js — end-to-end pose keypoint ingestion: a driver emits the exact ONNX Pose Detector `Poses` shape
// (BlazePose-33 landmark maps + box + track_id, normalised top-left coordinates) into Source 1 configured as a
// normalised camera covering a 4×3 m scene. Zones with feet / head / hands / centre anchors must each catch the
// right body part after calibration.
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var LOG = DIR + "tests/pose.log.json";
  var OUT = DIR + "tests/pose-test.out";
  var report = [];
  function out(s) { report.push(s); console.log(s); }
  function finish(code) { Util.writeFile(OUT, report.join("\n") + "\n"); Qt.createQmlObject('import QtQuick; Timer { interval: 800; running: true; repeat: false; onTriggered: Qt.exit(' + code + ') }', Score, "exitTimer"); }
  function after(ms, fn) { var t = Qt.createQmlObject('import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false; signal fired(); onTriggered: fired() }', Score, "t" + ms); t.fired.connect(fn); return t; }
  try {
    Util.writeFile(LOG, "{}");
    var itv = Score.rootInterval();
    // camera scene 4×3 m: u,v (top-left) -> world x=(u-0.5)*4, y=(0.5-v)*3
    // nose (0.5,0.2)->(0,0.9) · ankles (~0.5,0.8)->(0,-0.9) · wrists (0.75,0.35)->(1,0.45) · box centre (0.5,0.5)->(0,0)
    var doc = {
      zones: [
        { name: "FeetZone", shape: { type: "circle", r: 0.35 }, pos: [0, -0.9, 0], anchor: "feet" },
        { name: "HeadZone", shape: { type: "circle", r: 0.35 }, pos: [0, 0.9, 0], anchor: "head" },
        { name: "HandZone", shape: { type: "circle", r: 0.35 }, pos: [1, 0.45, 0], anchor: "hands" },
        { name: "CentreZone", shape: { type: "circle", r: 0.35 }, pos: [0, 0, 0], anchor: "center" },
        { name: "FeetButCentre", shape: { type: "circle", r: 0.35 }, pos: [0, -0.9, 0], anchor: "center" }
      ],
      sources: [{ enabled: true, originMode: "normalized", scene: { w: 4, h: 3 }, lostTimeout: 0.4 }],
      settings: { uiRate: 30 }
    };
    var docJson = JSON.stringify(doc).replace(/\\/g, "\\\\").replace(/'/g, "\\'");
    var driverSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueOutlet { id: ents; objectName: 'ents' }",
      "  ValueOutlet { id: cmd; objectName: 'cmd' }",
      "  property int n: 0",
      "  tick: function(token, state) {",
      "    n++;",
      "    if (n === 2) { cmd.value = { cmd: 'doc', doc: '" + docJson + "' }; return; }",
      "    var kps = [];",
      "    for (var i = 0; i < 33; i++) kps.push({ x: 0.5, y: 0.5, z: 0, confidence: 0.95 });",
      "    kps[0] = { x: 0.5, y: 0.2, z: 0, confidence: 0.99 };",   // nose
      "    kps[27] = { x: 0.49, y: 0.8, z: 0, confidence: 0.9 };",  // ankles
      "    kps[28] = { x: 0.51, y: 0.8, z: 0, confidence: 0.9 };",
      "    kps[15] = { x: 0.75, y: 0.35, z: 0, confidence: 0.9 };", // wrists
      "    kps[16] = { x: 0.74, y: 0.36, z: 0, confidence: 0.9 };",
      "    ents.value = [{ keypoints: kps, world: [], mean_confidence: 0.92, track_id: 3, box: { x: 0.35, y: 0.2, w: 0.3, h: 0.6 }, class_id: 0 }];",
      "  }",
      "}"
    ].join("\n");
    var loggerSrc = [
      "import Score", "import QtQuick",
      "Script {",
      "  ValueInlet { id: zin; objectName: 'zones' }",
      "  ValueInlet { id: ein; objectName: 'entities' }",
      "  property var log: ({ ticks: 0, lastZones: null, lastEntities: null })",
      "  tick: function(token, state) {",
      "    log.ticks++;",
      "    if (zin.value !== undefined) log.lastZones = zin.value;",
      "    if (ein.value !== undefined) log.lastEntities = ein.value;",
      "    if (log.ticks % 30 === 0) Util.writeFile('" + LOG + "', JSON.stringify(log));",
      "  }",
      "}"
    ].join("\n");
    var driver = Score.createProcess(itv, "Javascript", driverSrc);
    var zones = Score.createProcess(itv, "Javascript", DIR + "tracking-zones.qml");
    var logger = Score.createProcess(itv, "Javascript", loggerSrc);
    Score.setName(zones, "Tracking Zones");
    Score.createCable(Score.port(driver, "ents"), Score.port(zones, "Source 1"));
    Score.createCable(Score.port(driver, "cmd"), Score.port(zones, "Command"));
    Score.createCable(Score.port(zones, "Zones"), Score.port(logger, "zones"));
    Score.createCable(Score.port(zones, "Entities"), Score.port(logger, "entities"));
    after(1500, function () { Score.play(); });
    after(8000, function () {
      Score.stop();
      try {
        var log = JSON.parse(Score.readFile(LOG));
        var f = [];
        var byName = {}; (log.lastZones || []).forEach(function (z) { byName[z.name] = z; });
        out("zones: " + (log.lastZones || []).map(function (z) { return z.name + "=" + z.count; }).join(" "));
        var e = (log.lastEntities || [])[0];
        out("entity: " + JSON.stringify(e ? { id: e.id, pos: e.pos, zones: e.zones } : null));
        if (!e) f.push("no entity");
        else {
          if (e.id !== "3") f.push("track_id not used as id: " + e.id);
          if (Math.abs(e.pos.x - 0) > 0.05 || Math.abs(e.pos.y - 0) > 0.05) f.push("box centre not at world origin: " + JSON.stringify(e.pos));
        }
        if (!byName.FeetZone || byName.FeetZone.count !== 1) f.push("feet anchor failed");
        if (!byName.HeadZone || byName.HeadZone.count !== 1) f.push("head anchor failed");
        if (!byName.HandZone || byName.HandZone.count !== 1) f.push("hands anchor failed");
        if (!byName.CentreZone || byName.CentreZone.count !== 1) f.push("centre anchor failed");
        if (!byName.FeetButCentre || byName.FeetButCentre.count !== 0) f.push("centre anchor wrongly inside the feet zone");
        if (f.length) { out("FAIL: " + f.join("; ")); finish(1); } else { out("PASS pose keypoints"); finish(0); }
      } catch (e2) { out("FAIL " + e2 + " " + e2.stack); finish(1); }
    });
  } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
})();
