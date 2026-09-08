import Score 1.0

// Slew limiter — caps how fast a value is allowed to move, in units per second.
// Unlike smoothing, it reaches the target exactly, and it can rise faster than
// it falls: the standard trick for level meters and light dimming.
// A rate of 0 means "no limit in that direction".
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: rise; objectName: "Rise (per s)"; min: 0.; max: 1000000.; init: 2. }
  FloatSpinBox { id: fall; objectName: "Fall (per s)"; min: 0.; max: 1000000.; init: 0.5 }
  Toggle       { id: always; objectName: "Output every tick"; checked: true }
  Impulse      { id: reset; objectName: "Reset"; onImpulse: cur = undefined }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: arrived; objectName: "Arrived" }

  property var cur: undefined
  property var target: []
  property bool wasList: false
  property bool wasArrived: false
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
    const dt = Math.max(0., t - prevT) / 1000.;
    prevT = t;

    if (typeof input.value !== "undefined") {
      wasList = isList(input.value);
      target = asList(input.value);
    }
    if (target.length === 0)
      return;

    if (cur === undefined || cur.length !== target.length) {
      cur = new Array(target.length);
      for (var i = 0; i < target.length; ++i) cur[i] = Number(target[i]) || 0.;
    }

    const up = rise.value * dt;
    const down = fall.value * dt;
    var done = true;

    for (var j = 0; j < cur.length; ++j) {
      const g = Number(target[j]);
      if (!isFinite(g)) continue;
      const d = g - cur[j];
      if (d > 0.) cur[j] += (up <= 0. || d <= up) ? d : up;
      else if (d < 0.) cur[j] += (down <= 0. || -d <= down) ? d : -down;
      if (cur[j] !== g) done = false;
    }

    if (boolOf(always) || typeof input.value !== "undefined")
      output.value = wasList ? cur.slice() : cur[0];

    if (done !== wasArrived) {
      wasArrived = done;
      arrived.value = done;
    }
  }
}
