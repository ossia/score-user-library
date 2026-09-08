import Score 1.0

// [scale] — maps a range onto another one, with an optional curve.
// Works on a single number or element-wise on a list.
// Curve 1 is linear, below 1 favours the top of the range, above 1 the bottom.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: inMin; objectName: "In min"; min: -1000000.; max: 1000000.; init: 0. }
  FloatSpinBox { id: inMax; objectName: "In max"; min: -1000000.; max: 1000000.; init: 1. }
  FloatSpinBox { id: outMin; objectName: "Out min"; min: -1000000.; max: 1000000.; init: 0. }
  FloatSpinBox { id: outMax; objectName: "Out max"; min: -1000000.; max: 1000000.; init: 1. }
  FloatSpinBox { id: curve; objectName: "Curve"; min: 0.01; max: 16.; init: 1. }
  Toggle       { id: clip; objectName: "Clip"; checked: true }
  ValueOutlet  { id: output; objectName: "Out" }

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  // Applies f to a number, or to every element of a (possibly nested) list.
  function mapv(v, f) {
    if (isList(v)) {
      var r = new Array(v.length);
      for (var i = 0; i < v.length; ++i) r[i] = mapv(v[i], f);
      return r;
    }
    const n = Number(v);
    return isFinite(n) ? f(n) : v;
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const i0 = inMin.value, i1 = inMax.value;
    const o0 = outMin.value, o1 = outMax.value;
    const c = curve.value;
    const doClip = boolOf(clip);
    const span = (i1 - i0);

    output.value = mapv(input.value, function(x) {
      var u = (span === 0.) ? 0. : (x - i0) / span;
      if (doClip) u = Math.max(0., Math.min(1., u));
      if (c !== 1.) {
        const sgn = u < 0. ? -1. : 1.;
        u = sgn * Math.pow(Math.abs(u), c);
      }
      return o0 + u * (o1 - o0);
    });
  }
}
