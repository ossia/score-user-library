import Score 1.0

// One-pole smoothing — the workhorse filter for control data.
// "Time" is how long it takes to cover about 2/3 of the way to a new value.
// The coefficient is recomputed from the real tick duration, so the feel stays
// the same whether the graph runs at 30 or 1000 Hz.  Element-wise on lists.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: time; objectName: "Time (ms)"; min: 0.; max: 600000.; init: 120. }
  FloatSpinBox { id: jump; objectName: "Jump if over"; min: 0.; max: 1000000.; init: 0. }
  Toggle       { id: always; objectName: "Output every tick"; checked: true }
  Impulse      { id: reset; objectName: "Reset"; onImpulse: cur = undefined }
  ValueOutlet  { id: output; objectName: "Out" }

  property var cur: undefined
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

  property var targetList: []
  property bool wasList: false

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    const t = 1000. * (token.date * state.model_to_physical) / state.sample_rate;
    const dt = Math.max(0., t - prevT);
    prevT = t;

    if (typeof input.value !== "undefined") {
      wasList = isList(input.value);
      targetList = asList(input.value);
    }
    if (targetList.length === 0)
      return;

    // alpha = 1 - exp(-dt / tau): frame-rate independent.
    const tau = time.value;
    const alpha = (tau <= 0.) ? 1. : (1. - Math.exp(-dt / tau));
    const jumpAt = jump.value;

    if (cur === undefined || cur.length !== targetList.length) {
      cur = new Array(targetList.length);
      for (var i = 0; i < targetList.length; ++i) cur[i] = Number(targetList[i]) || 0.;
    } else {
      for (var j = 0; j < cur.length; ++j) {
        const target = Number(targetList[j]);
        if (!isFinite(target)) continue;
        // A big enough step is followed instantly rather than smeared.
        if (jumpAt > 0. && Math.abs(target - cur[j]) >= jumpAt)
          cur[j] = target;
        else
          cur[j] += (target - cur[j]) * alpha;
      }
    }

    if (boolOf(always) || typeof input.value !== "undefined")
      output.value = wasList ? cur.slice() : cur[0];
  }
}
