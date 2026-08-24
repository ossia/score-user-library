// round3-test.js — UI round 3: gizmo modes, 3D creation tools, live 3D drag, panel screenshots.
(function () {
  var DIR = "C:/Users/jcelerier/Documents/ossia/score/packages/default/Presets/Javascript/tracking-zones/";
  var SHOT = DIR + "tests/shots/";
  var OUT = DIR + "tests/round3-test.out";
  var ST = DIR + "tests/round3-status";
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
      "  property var actions: []",
      "  property int nextAction: 0",
      "  property real t0: -1",
      "  tick: function(token, state) {",
      "    var t = token.date / 705600000; if (t0 < 0) t0 = t;",
      "    if (nextAction < actions.length && t - t0 >= actions[nextAction][0]) { cmd.value = actions[nextAction][1]; nextAction++; }",
      "  }",
      "  Component.onCompleted: {",
      "    var S = '" + SHOT + "', T = '" + ST + "';",
      "    actions = [",
      // a polygon zone to exercise the new handles
      "      [2.0, { cmd: 'ui', action: 'addZone', zoneType: 'polygon', x: 1, y: 1 }],",
      "      [2.4, { cmd: 'ui', action: 'tab', value: 0 }],",
      "      [3.0, { cmd: 'ui', action: 'grab', path: S + 'r3-sources.png' }],",
      "      [3.4, { cmd: 'ui', action: 'tab', value: 1 }],",
      "      [4.0, { cmd: 'ui', action: 'grab', path: S + 'r3-sim.png' }],",
      "      [4.2, { cmd: 'ui', action: 'grab', path: S + 'r3-2d-handles.png' }],",
      // 3D: mode buttons + gizmo per mode
      "      [4.6, { cmd: 'ui', action: 'view', value: '3d' }],",
      "      [5.2, { cmd: 'ui', action: 'grab', path: S + 'r3-3d-move.png' }],",
      "      [5.4, { cmd: 'ui', action: 'gizmo', value: 'rotate' }],",
      "      [5.9, { cmd: 'ui', action: 'grab', path: S + 'r3-3d-rotate.png' }],",
      "      [6.1, { cmd: 'ui', action: 'gizmo', value: 'scale' }],",
      "      [6.6, { cmd: 'ui', action: 'grab', path: S + 'r3-3d-scale.png' }],",
      // scale drag on the uniform handle: press at the zone centre, drag 60 px right
      "      [7.0, { cmd: 'ui', action: 'dumpstatus', path: T + '-before-scale.json' }],",
      "      [7.4, { cmd: 'ui', action: 'synth', steps: [ { t: 'drag', view: '3d', x: 1, y: 1, z: 0, dxPx: 60, dyPx: 0 } ] }],",
      "      [7.6, { cmd: 'ui', action: 'dumpstatus', path: T + '-after-scale.json' }],",
      // creation in 3D: rect tool + click on the floor
      "      [8.0, { cmd: 'ui', action: 'gizmo', value: 'move' }],",
      "      [8.2, { cmd: 'ui', action: 'tool', value: 'rect' }],",
      "      [8.6, { cmd: 'ui', action: 'synth', steps: [ { t: 'click', view: '3d', x: -2, y: -2, z: 0 } ] }],",
      "      [9.0, { cmd: 'ui', action: 'dumpstatus', path: T + '-after-create.json' }],",
      "      [9.4, { cmd: 'ui', action: 'grab', path: S + 'r3-3d-created.png' }],",
      // local-frame scale: rotate the rect 90 deg, then drag the sx handle (which now points along world +Y)
      "      [9.8, { cmd: 'ui', action: 'setProp', path: 'rot.2', value: 90 }],",   // scalar: lists in maps do not survive the cable as real Arrays
      "      [10.2, { cmd: 'ui', action: 'gizmo', value: 'scale' }],",
      "      [10.8, { cmd: 'ui', action: 'synth', steps: [ { t: 'drag', view: '3d', x: -2, y: -0.2, z: 0, x1: -2, y1: 0.8, z1: 0, n: 10 } ] }],",
      "      [11.2, { cmd: 'ui', action: 'dumpstatus', path: T + '-after-rotscale.json' }]",
      "    ];",
      "  }",
      "}"
    ].join("\n");
    var driver = Score.createProcess(itv, "Javascript", driverSrc);
    var zones = Score.createProcess(itv, "Javascript", DIR + "tracking-zones.qml");
    Score.setName(zones, "Tracking Zones");
    Score.createCable(Score.port(driver, "cmd"), Score.port(zones, "Command"));
    after(1500, function () { Score.play(); Score.showProcessUI(zones, true); });
    after(13500, function () {
      Score.stop();
      try {
        var f = [];
        var shots = ["r3-sources.png", "r3-sim.png", "r3-2d-handles.png", "r3-3d-move.png", "r3-3d-rotate.png", "r3-3d-scale.png", "r3-3d-created.png"];
        for (var i = 0; i < shots.length; i++) if (!Util.fileExists(SHOT + shots[i])) f.push("missing shot " + shots[i]);
        var before = JSON.parse(Score.readFile(ST + "-before-scale.json"));
        var afterScale = JSON.parse(Score.readFile(ST + "-after-scale.json"));
        var afterCreate = JSON.parse(Score.readFile(ST + "-after-create.json"));
        out("gizmoMode before " + before.gizmoMode + " zones " + before.zones);
        function ext(sh) { var m = 0; if (!sh || !sh.points) return 0; for (var i = 0; i < sh.points.length; i++) m = Math.max(m, Math.abs(sh.points[i][0])); return m; }
        var e0 = ext(before.selected && before.selected.shape), e1 = ext(afterScale.selected && afterScale.selected.shape);
        out("polygon extent before " + e0 + " after " + e1);
        if (!(e1 > e0 * 1.05)) f.push("uniform scale drag did not grow the polygon (" + e0 + " -> " + e1 + ")");
        if (afterCreate.zones !== before.zones + 1) f.push("3D click did not create a zone (" + before.zones + " -> " + afterCreate.zones + ")");
        if (afterCreate.selected && afterCreate.selected.shape && afterCreate.selected.shape.type !== "rect") f.push("created zone is not a rect: " + afterCreate.selected.shape.type);
        var rs = JSON.parse(Score.readFile(ST + "-after-rotscale.json"));
        var rsh = rs.selected && rs.selected.shape;
        out("rotated rect after local sx drag: rot=" + JSON.stringify(rs.selected && rs.selected.rot) + " w=" + (rsh && rsh.w) + " h=" + (rsh && rsh.h));
        if (!rs.selected || Math.abs(rs.selected.rot[2] - 90) > 0.01) f.push("rot not applied");
        if (!rsh || !(rsh.w > 2.5 && rsh.w < 4.5)) f.push("local-frame sx scale wrong: w=" + (rsh && rsh.w));
        if (!rsh || Math.abs(rsh.h - 2) > 0.01) f.push("sx scale changed h: " + (rsh && rsh.h));
        if (f.length) { out("FAIL: " + f.join("; ")); finish(1); } else { out("PASS round3"); finish(0); }
      } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
    });
  } catch (e) { out("FAIL " + e + " " + e.stack); finish(1); }
})();
