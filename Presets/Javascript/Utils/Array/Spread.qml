import Score 1.0

// Generates a list of N values around a centre — vvvv's LinearSpread.
// The fastest way to get "one value per object" out of a couple of knobs:
// N delays, N offsets, N pitches, N opacities.
Script {
  IntSpinBox   { id: count; objectName: "Count"; min: 1; max: 10000; init: 8 }
  FloatSpinBox { id: center; objectName: "Center"; min: -1000000.; max: 1000000.; init: 0.5 }
  FloatSpinBox { id: width; objectName: "Width"; min: -1000000.; max: 1000000.; init: 1. }
  ComboBox     { id: shape; objectName: "Shape"; choices: [ "Linear", "Exponential", "Sine", "Random" ]; index: 0 }
  FloatSlider  { id: phase; objectName: "Phase"; min: -1.; max: 1.; init: 0. }
  FloatSpinBox { id: curve; objectName: "Curve"; min: 0.01; max: 16.; init: 2. }
  IntSpinBox   { id: seed; objectName: "Seed"; min: 0; max: 1000000; init: 1 }
  Toggle       { id: alternate; objectName: "Alternate"; checked: false }
  ValueOutlet  { id: output; objectName: "Out" }

  property string lastSig: ""

  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }
  // Small deterministic generator: the same seed always gives the same spread.
  function rng(s) {
    return function() {
      s = (s + 0x6D2B79F5) | 0;
      var t = Math.imul(s ^ (s >>> 15), 1 | s);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    const sig = [ count.value, center.value, width.value, choice(shape),
                  phase.value, curve.value, seed.value, boolOf(alternate) ].join("/");
    if (sig === lastSig)
      return;
    lastSig = sig;

    const n = Math.max(1, count.value);
    const c = center.value, w = width.value, ph = phase.value;
    const k = curve.value;
    const s = choice(shape);
    const rand = rng(seed.value);

    var out = new Array(n);
    for (var i = 0; i < n; ++i) {
      // u goes from -0.5 to 0.5 across the spread.
      var u = (n === 1) ? 0. : (i / (n - 1)) - 0.5;
      u += ph;
      switch (s) {
        case "Exponential": {
          const sgn = (u < 0.) ? -1. : 1.;
          u = sgn * Math.pow(Math.abs(u * 2.), k) * 0.5;
          break;
        }
        case "Sine":   u = 0.5 * Math.sin(u * Math.PI); break;
        case "Random": u = rand() - 0.5; break;
      }
      out[i] = c + u * w;
    }

    if (boolOf(alternate)) {
      // Reorder as centre, then outwards: 4 2 1 3 5 rather than 1 2 3 4 5.
      var alt = [];
      var lo = Math.floor((n - 1) / 2), hi = lo + 1;
      while (alt.length < n) {
        if (lo >= 0) alt.push(out[lo--]);
        if (alt.length < n && hi < n) alt.push(out[hi++]);
      }
      out = alt;
    }

    output.value = out;
  }
}
