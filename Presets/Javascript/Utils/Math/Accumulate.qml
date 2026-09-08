import Score 1.0

// Running sum of everything that comes in.
// With "Scale by time" on it becomes an integrator: the input is read as a
// rate per second, which is how you turn a joystick into a position.
Script {
  ValueInlet   { id: input; objectName: "In" }
  FloatSpinBox { id: initial; objectName: "Initial"; min: -1000000.; max: 1000000.; init: 0. }
  FloatSpinBox { id: lo; objectName: "Min"; min: -1000000.; max: 1000000.; init: -1000000. }
  FloatSpinBox { id: hi; objectName: "Max"; min: -1000000.; max: 1000000.; init: 1000000. }
  ComboBox     { id: mode; objectName: "At bounds"; choices: [ "Clip", "Wrap", "Free" ]; index: 0 }
  Toggle       { id: perSecond; objectName: "Scale by time"; checked: false }
  Impulse      { id: reset; objectName: "Reset"; onImpulse: doReset = true }
  ValueOutlet  { id: output; objectName: "Out" }

  property var acc: undefined
  property bool doReset: true
  property real prevT: 0.

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }
  function bound(x, a, b, m) {
    if (m === "Free") return x;
    if (a >= b) return a;
    if (m === "Wrap") return a + ((((x - a) % (b - a)) + (b - a)) % (b - a));
    return Math.max(a, Math.min(b, x));
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    const t = 1000. * (token.date * state.model_to_physical) / state.sample_rate;
    const dt = Math.max(0., t - prevT) / 1000.;
    prevT = t;

    if (doReset) { doReset = false; acc = undefined; }
    if (typeof input.value === "undefined")
      return;

    const gain = boolOf(perSecond) ? dt : 1.;
    const a = lo.value, b = hi.value, m = choice(mode);
    const v = input.value;

    if (isList(v)) {
      if (!isList(acc) || acc.length !== v.length) {
        acc = new Array(v.length);
        for (var i = 0; i < v.length; ++i) acc[i] = initial.value;
      }
      for (var j = 0; j < v.length; ++j) {
        const d = Number(v[j]);
        if (isFinite(d)) acc[j] = bound(acc[j] + d * gain, a, b, m);
      }
      output.value = acc.slice();
    } else {
      if (typeof acc !== "number") acc = initial.value;
      const d2 = Number(v);
      if (isFinite(d2)) acc = bound(acc + d2 * gain, a, b, m);
      output.value = acc;
    }
  }
}
