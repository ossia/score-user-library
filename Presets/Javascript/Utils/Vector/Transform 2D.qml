import Score 1.0
import QtQuick   // for Qt.vector2d()

// Moves, rotates and scales 2D points around an anchor.
// Accepts a single [x, y], a flat [x, y, x, y, ...] or a list of [x, y] pairs,
// and gives back the same shape.  Order is: scale, rotate, translate.
Script {
  ValueInlet   { id: input; objectName: "In" }
  XYSlider     { id: translate; objectName: "Translate"; min: Qt.vector2d(-2, -2); max: Qt.vector2d(2, 2); init: Qt.vector2d(0, 0) }
  FloatSlider  { id: rotate; objectName: "Rotate (turns)"; min: -1.; max: 1.; init: 0. }
  XYSlider     { id: scale; objectName: "Scale"; min: Qt.vector2d(-4, -4); max: Qt.vector2d(4, 4); init: Qt.vector2d(1, 1) }
  XYSlider     { id: anchor; objectName: "Anchor"; min: Qt.vector2d(-2, -2); max: Qt.vector2d(2, 2); init: Qt.vector2d(0, 0) }
  ValueOutlet  { id: output; objectName: "Out" }

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function asList(v) {
    if (v === undefined || v === null) return [];
    if (isList(v)) { var r = new Array(v.length); for (var i = 0; i < v.length; ++i) r[i] = v[i]; return r; }
    if (typeof v === "object" && typeof v.x === "number") return [ v.x, v.y ];
    return [ v ];
  }
  function vec2(c) {
    const v = c.value;
    if (v !== undefined && v !== null && typeof v.x === "number") return [ v.x, v.y ];
    return [ 0., 0. ];
  }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const t = vec2(translate), s = vec2(scale), a = vec2(anchor);
    const th = rotate.value * 2. * Math.PI;
    const c = Math.cos(th), si = Math.sin(th);

    function apply(x, y) {
      var px = (x - a[0]) * s[0];
      var py = (y - a[1]) * s[1];
      const rx = px * c - py * si;
      const ry = px * si + py * c;
      return [ rx + a[0] + t[0], ry + a[1] + t[1] ];
    }

    const src = asList(input.value);
    if (src.length === 0)
      return;

    // A list of points: [[x, y], [x, y], ...]
    if (isList(src[0])) {
      var out = new Array(src.length);
      for (var i = 0; i < src.length; ++i) {
        const p = asList(src[i]);
        out[i] = apply(Number(p[0]) || 0., Number(p[1]) || 0.);
      }
      output.value = out;
      return;
    }

    // A single point.
    if (src.length === 2) {
      output.value = apply(Number(src[0]) || 0., Number(src[1]) || 0.);
      return;
    }

    // A flat run of coordinates.
    var flat = [];
    for (var j = 0; j + 1 < src.length; j += 2) {
      const q = apply(Number(src[j]) || 0., Number(src[j + 1]) || 0.);
      flat.push(q[0], q[1]);
    }
    output.value = flat;
  }
}
