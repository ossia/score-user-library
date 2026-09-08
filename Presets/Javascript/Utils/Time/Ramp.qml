import Score 1.0

// [line] — walks to the incoming target over a fixed duration.
// Every new target restarts the ramp from wherever the output currently is,
// so it never jumps, however fast the targets arrive.
Script {
  ValueInlet   { id: input; objectName: "Target" }
  FloatSpinBox { id: duration; objectName: "Time (ms)"; min: 0.; max: 600000.; init: 500. }
  ComboBox     { id: shape; objectName: "Shape"; choices: [ "Linear", "Smooth", "Ease out" ]; index: 0 }
  Impulse      { id: jump; objectName: "Jump"; onImpulse: doJump = true }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: running; objectName: "Running" }
  ValueOutlet  { id: doneOut; objectName: "Done" }

  property var fromV: undefined
  property var toV: undefined
  property real startT: 0.
  property bool active: false
  property bool doJump: false
  property bool wasList: false

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function asNumbers(v) {
    var l;
    if (isList(v)) { l = []; for (var i = 0; i < v.length; ++i) l.push(v[i]); }
    else if (v !== null && typeof v === "object" && typeof v.x === "number") {
      l = [ v.x, v.y ];
      if (typeof v.z === "number") l.push(v.z);
      if (typeof v.w === "number") l.push(v.w);
    }
    else l = [ v ];
    var r = new Array(l.length);
    for (var j = 0; j < l.length; ++j) { const n = Number(l[j]); r[j] = isFinite(n) ? n : 0.; }
    return r;
  }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }
  function ease(u, name) {
    if (name === "Smooth") return u * u * (3. - 2. * u);
    if (name === "Ease out") return 1. - (1. - u) * (1. - u);
    return u;
  }

  tick: function(token, state) {
    const t = 1000. * (token.date * state.model_to_physical) / state.sample_rate;

    if (typeof input.value !== "undefined") {
      const goal = asNumbers(input.value);
      wasList = isList(input.value);
      if (fromV === undefined || fromV.length !== goal.length)
        fromV = goal.slice();
      else
        fromV = currentValue(t);   // restart from where we are now
      toV = goal;
      startT = t;
      if (!active) { active = true; running.value = true; }
    }

    if (doJump) {
      doJump = false;
      if (toV !== undefined) { fromV = toV.slice(); startT = t - duration.value; }
    }

    if (toV === undefined)
      return;

    const cur = currentValue(t);
    output.value = wasList ? cur : cur[0];

    if (active && (duration.value <= 0. || (t - startT) >= duration.value)) {
      active = false;
      running.value = false;
      doneOut.value = true;
    }
  }

  // Where the ramp is at time t.
  function currentValue(t) {
    if (toV === undefined) return [];
    if (fromV === undefined) return toV.slice();
    const d = duration.value;
    var u = (d <= 0.) ? 1. : (t - startT) / d;
    u = Math.max(0., Math.min(1., u));
    const e = ease(u, choice(shape));
    var r = new Array(toV.length);
    for (var i = 0; i < toV.length; ++i) {
      const a = (i < fromV.length) ? fromV[i] : toV[i];
      r[i] = a + (toV[i] - a) * e;
    }
    return r;
  }
}
