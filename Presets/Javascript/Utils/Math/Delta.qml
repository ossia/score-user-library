import Score 1.0

// How much a value moved, and how fast.
// "Speed" is the magnitude of the change per second — the usual input for
// "react when someone moves quickly" behaviours.
Script {
  ValueInlet  { id: input; objectName: "In" }
  Toggle      { id: onlyOnChange; objectName: "Only on change"; checked: false }
  Impulse     { id: reset; objectName: "Reset"; onImpulse: prev = undefined }
  ValueOutlet { id: delta; objectName: "Delta" }
  ValueOutlet { id: rate; objectName: "Rate (per s)" }
  ValueOutlet { id: speed; objectName: "Speed" }

  property var prev: undefined
  property real prevT: 0.

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function asList(v) {
    if (v === undefined || v === null) return [];
    if (isList(v)) { var r = new Array(v.length); for (var i = 0; i < v.length; ++i) r[i] = v[i]; return r; }
    if (typeof v === "object" && typeof v.x === "number") {
      var o = [ v.x, v.y ];
      if (typeof v.z === "number") o.push(v.z);
      if (typeof v.w === "number") o.push(v.w);
      return o;
    }
    return [ v ];
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    const t = 1000. * (token.date * state.model_to_physical) / state.sample_rate;
    const dt = Math.max(1e-6, (t - prevT) / 1000.);
    prevT = t;

    if (typeof input.value === "undefined")
      return;

    const cur = asList(input.value);
    const wasList = isList(input.value);

    if (prev === undefined || prev.length !== cur.length) {
      prev = cur;
      return;
    }

    var d = new Array(cur.length), r = new Array(cur.length), sq = 0.;
    var moved = false;
    for (var i = 0; i < cur.length; ++i) {
      const a = Number(cur[i]), b = Number(prev[i]);
      d[i] = (isFinite(a) && isFinite(b)) ? (a - b) : 0.;
      r[i] = d[i] / dt;
      sq += d[i] * d[i];
      if (d[i] !== 0.) moved = true;
    }
    prev = cur;

    if (boolOf(onlyOnChange) && !moved)
      return;

    delta.value = wasList ? d : d[0];
    rate.value = wasList ? r : r[0];
    speed.value = Math.sqrt(sq) / dt;
  }
}
