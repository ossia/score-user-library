import Score 1.0

// Relationship between two points: how far apart, in which direction.
// The building block of every proximity behaviour — a hand approaching a
// sensor, a tracked body entering a zone, two objects avoiding each other.
Script {
  ValueInlet   { id: inA; objectName: "A" }
  ValueInlet   { id: inB; objectName: "B" }
  LineEdit     { id: constB; objectName: "B (if unconnected)"; text: "0, 0" }
  ComboBox     { id: unit; objectName: "Angle unit"; choices: [ "Turns", "Degrees", "Radians" ]; index: 0 }
  FloatSpinBox { id: near; objectName: "Near"; min: 0.; max: 1000000.; init: 0. }
  FloatSpinBox { id: far; objectName: "Far"; min: 0.; max: 1000000.; init: 1. }
  ValueOutlet  { id: dist; objectName: "Distance" }
  ValueOutlet  { id: prox; objectName: "Proximity" }
  ValueOutlet  { id: angle; objectName: "Angle" }
  ValueOutlet  { id: delta; objectName: "Delta" }
  ValueOutlet  { id: dirOut; objectName: "Direction" }

  property var latchedB: undefined

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function asVec(v) {
    if (v === undefined || v === null) return [];
    if (isList(v)) { var r = new Array(v.length); for (var i = 0; i < v.length; ++i) r[i] = Number(v[i]) || 0.; return r; }
    if (typeof v === "object" && typeof v.x === "number") {
      var o = [ v.x, v.y ];
      if (typeof v.z === "number") o.push(v.z);
      if (typeof v.w === "number") o.push(v.w);
      return o;
    }
    const n = Number(v);
    return isFinite(n) ? [ n ] : [];
  }
  function parseVec(text) {
    const parts = text.split(",");
    var r = [];
    for (var i = 0; i < parts.length; ++i) {
      const n = Number(parts[i].trim());
      if (isFinite(n)) r.push(n);
    }
    return r;
  }
  function str(ctl) { return (typeof ctl.value === "string") ? ctl.value : ctl.text; }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }
  function fromRad(a, u) {
    if (u === "Degrees") return a * 180. / Math.PI;
    if (u === "Turns") { const t = a / (2. * Math.PI); return t < 0. ? t + 1. : t; }
    return a;
  }

  tick: function(token, state) {
    if (typeof inB.value !== "undefined")
      latchedB = asVec(inB.value);
    if (typeof inA.value === "undefined")
      return;

    var a = asVec(inA.value);
    var b = (latchedB !== undefined && latchedB.length > 0) ? latchedB.slice() : parseVec(str(constB));
    if (a.length === 0)
      return;

    const n = Math.max(a.length, b.length);
    while (a.length < n) a.push(0.);
    while (b.length < n) b.push(0.);

    var d = new Array(n), sq = 0.;
    for (var i = 0; i < n; ++i) { d[i] = a[i] - b[i]; sq += d[i] * d[i]; }
    const L = Math.sqrt(sq);

    dist.value = L;
    delta.value = d;

    var dir = new Array(n);
    for (var j = 0; j < n; ++j) dir[j] = (L > 0.) ? d[j] / L : 0.;
    dirOut.value = dir;

    if (n >= 2)
      angle.value = fromRad(Math.atan2(d[1], d[0]), choice(unit));

    // 1 when the points touch, 0 once they are further apart than "Far".
    const n0 = near.value, n1 = far.value;
    const u = (n1 > n0) ? (L - n0) / (n1 - n0) : (L > n0 ? 1. : 0.);
    prox.value = 1. - Math.max(0., Math.min(1., u));
  }
}
