import Score 1.0

// [change] — forwards a value only when it differs from the previous one.
// Use it to stop a redundant stream from waking up whatever is downstream.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: tol; objectName: "Tolerance"; min: 0.; max: 1000000.; init: 0. }
  Impulse      { id: reset; objectName: "Reset"; onImpulse: pendingReset = true }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: changed; objectName: "Changed" }

  property var last: undefined
  property bool pendingReset: false

  // Cable values are not always real JS arrays: look for a length instead.
  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  // Snapshot: the inlet storage is recycled on the next tick.
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
  // Every message of this tick, with its sample offset inside the buffer.
  function incoming(inl) {
    var vs = inl.values, out = [];
    if (vs && typeof vs.length === "number" && vs.length > 0) {
      var ok = true;
      for (var i = 0; i < vs.length; ++i) {
        var m = vs[i];
        if (m === null || typeof m !== "object" || typeof m.timestamp !== "number") { ok = false; break; }
        out.push({ t: m.timestamp, v: m.value });
      }
      if (ok) return out;
    }
    return (typeof inl.value !== "undefined") ? [ { t: 0, v: inl.value } ] : [];
  }

  tick: function(token, state) {
    if (pendingReset) { last = undefined; pendingReset = false; }

    const eps = tol.value;
    const msgs = incoming(input);
    for (var i = 0; i < msgs.length; ++i) {
      if (same(msgs[i].v, last, eps))
        continue;
      last = copyOf(msgs[i].v);
      output.addValue(msgs[i].t, last);
      changed.addValue(msgs[i].t, true);
    }
  }
}
