import Score 1.0

// Follows whichever of several sources moved last.
// Lets a fader, a phone and a camera drive the same parameter without fighting.
Script {
  ValueInlet   { id: in1; objectName: "In 1" }
  ValueInlet   { id: in2; objectName: "In 2" }
  ValueInlet   { id: in3; objectName: "In 3" }
  ValueInlet   { id: in4; objectName: "In 4" }
  FloatSpinBox { id: tol; objectName: "Tolerance"; min: 0.; max: 1000000.; init: 0.0001 }
  FloatSpinBox { id: hold; objectName: "Hold (ms)"; min: 0.; max: 600000.; init: 0. }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: source; objectName: "Source" }

  property var lasts: [ undefined, undefined, undefined, undefined ]
  property int active: -1
  property real activeAt: -1e18

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function copyOf(v) {
    if (!isList(v)) return v;
    var r = new Array(v.length);
    for (var i = 0; i < v.length; ++i) r[i] = copyOf(v[i]);
    return r;
  }
  function same(a, b, eps) {
    if (a === undefined || b === undefined) return false;
    var la = isList(a), lb = isList(b);
    if (la !== lb) return false;
    if (la) {
      if (a.length !== b.length) return false;
      for (var i = 0; i < a.length; ++i) if (!same(a[i], b[i], eps)) return false;
      return true;
    }
    if (typeof a === "number" && typeof b === "number") return Math.abs(a - b) <= eps;
    return a === b;
  }
  function nowMs(token, state) {
    return 1000. * (token.date * state.model_to_physical) / state.sample_rate;
  }

  tick: function(token, state) {
    const ins = [ in1, in2, in3, in4 ];
    const now = nowMs(token, state);
    const eps = tol.value;

    for (var i = 0; i < ins.length; ++i) {
      const v = ins[i].value;
      if (typeof v === "undefined")
        continue;
      if (same(v, lasts[i], eps))
        continue;

      lasts[i] = copyOf(v);
      // A fresher source only takes over once the hold time has elapsed.
      if (i !== active && (now - activeAt) < hold.value)
        continue;

      if (i !== active) {
        active = i;
        source.value = i + 1;
      }
      activeAt = now;
      output.value = lasts[i];
    }
  }
}
