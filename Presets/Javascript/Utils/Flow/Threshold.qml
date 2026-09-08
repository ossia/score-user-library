import Score 1.0

// Schmitt trigger — turns a noisy continuous signal into a clean on/off.
// Two thresholds, so a value hovering around the edge does not chatter.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: onAbove; objectName: "On above"; min: -1000000.; max: 1000000.; init: 0.6 }
  FloatSpinBox { id: offBelow; objectName: "Off below"; min: -1000000.; max: 1000000.; init: 0.4 }
  ValueOutlet  { id: stateOut; objectName: "State" }
  ValueOutlet  { id: rising; objectName: "Rising" }
  ValueOutlet  { id: falling; objectName: "Falling" }

  property bool on: false
  property bool started: false

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  // A list is reduced to the component with the largest magnitude.
  function scalarOf(v) {
    if (typeof v === "number") return v;
    if (typeof v === "boolean") return v ? 1 : 0;
    if (isList(v)) {
      var best = 0;
      for (var i = 0; i < v.length; ++i) {
        var c = scalarOf(v[i]);
        if (Math.abs(c) > Math.abs(best)) best = c;
      }
      return best;
    }
    var n = Number(v);
    return isFinite(n) ? n : 0;
  }

  tick: function(token, st) {
    if (typeof input.value === "undefined")
      return;

    const x = scalarOf(input.value);
    const hi = onAbove.value;
    const lo = Math.min(offBelow.value, hi);

    var next = on;
    if (!on && x >= hi) next = true;
    else if (on && x <= lo) next = false;

    if (next !== on || !started) {
      started = true;
      on = next;
      stateOut.value = on;
      if (on) rising.value = true; else falling.value = true;
    }
  }
}
