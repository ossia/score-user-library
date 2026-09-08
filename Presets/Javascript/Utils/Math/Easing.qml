import Score 1.0

// Reshapes a 0..1 value with the usual easing curves.
// Feed it an automation, a phase, or a normalised sensor reading to give
// mechanical motion a bit of weight.  Element-wise on lists.
Script {
  ValueInlet   { id: input; objectName: "In" }
  ComboBox     { id: shape; objectName: "Shape"
                 choices: [ "Linear", "Smoothstep", "Smootherstep", "Gamma",
                            "Sine", "Quadratic", "Cubic", "Quartic",
                            "Exponential", "Circular", "Back", "Elastic", "Bounce" ]
                 index: 1 }
  ComboBox     { id: dir; objectName: "Direction"; choices: [ "In", "Out", "In-Out" ]; index: 1 }
  FloatSpinBox { id: amount; objectName: "Amount"; min: 0.01; max: 8.; init: 1. }
  Toggle       { id: clip; objectName: "Clip input"; checked: true }
  ValueOutlet  { id: output; objectName: "Out" }

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function mapv(v, f) {
    if (isList(v)) {
      var r = new Array(v.length);
      for (var i = 0; i < v.length; ++i) r[i] = mapv(v[i], f);
      return r;
    }
    const n = Number(v);
    return isFinite(n) ? f(n) : v;
  }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }

  // Every curve is written as "ease in", then mirrored for out / in-out.
  function easeIn(name, t, k) {
    switch (name) {
      case "Smoothstep":   return t * t * (3. - 2. * t);
      case "Smootherstep": return t * t * t * (t * (t * 6. - 15.) + 10.);
      case "Gamma":        return Math.pow(t, k);
      case "Sine":         return 1. - Math.cos(t * Math.PI / 2.);
      case "Quadratic":    return t * t;
      case "Cubic":        return t * t * t;
      case "Quartic":      return t * t * t * t;
      case "Exponential":  return t <= 0. ? 0. : Math.pow(2., 10. * (t - 1.));
      case "Circular":     return 1. - Math.sqrt(Math.max(0., 1. - t * t));
      case "Back": {
        const s = 1.70158 * k;
        return t * t * ((s + 1.) * t - s);
      }
      case "Elastic": {
        if (t <= 0.) return 0.;
        if (t >= 1.) return 1.;
        const p = 0.3 / k;
        return -Math.pow(2., 10. * (t - 1.)) * Math.sin((t - 1. - p / 4.) * 2. * Math.PI / p);
      }
      case "Bounce":       return 1. - bounceOut(1. - t);
      default:             return t;
    }
  }
  function bounceOut(t) {
    const n = 7.5625, d = 2.75;
    if (t < 1. / d)       return n * t * t;
    else if (t < 2. / d) { t -= 1.5 / d;   return n * t * t + 0.75; }
    else if (t < 2.5 / d) { t -= 2.25 / d; return n * t * t + 0.9375; }
    t -= 2.625 / d;
    return n * t * t + 0.984375;
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const name = choice(shape);
    const d = choice(dir);
    const k = amount.value;
    const doClip = boolOf(clip);
    // Symmetric curves are already their own mirror.
    const symmetric = (name === "Smoothstep" || name === "Smootherstep" || name === "Linear");

    output.value = mapv(input.value, function(x) {
      var t = doClip ? Math.max(0., Math.min(1., x)) : x;
      if (symmetric)
        return easeIn(name, t, k);
      if (d === "In")
        return easeIn(name, t, k);
      if (d === "Out")
        return 1. - easeIn(name, 1. - t, k);
      return (t < 0.5) ? 0.5 * easeIn(name, 2. * t, k)
                       : 1. - 0.5 * easeIn(name, 2. * (1. - t), k);
    });
  }
}
