import Score 1.0

// [drunk] — a random walk: every step is a small move from the last value,
// not a jump anywhere in the range. Wandering rather than jittering.
Script {
  Impulse      { id: bang; objectName: "Bang"; onImpulse: pending++ }
  Toggle       { id: everyTick; objectName: "Every tick"; checked: false }
  FloatSpinBox { id: step; objectName: "Step"; min: 0.; max: 1000000.; init: 0.05 }
  FloatSpinBox { id: lo; objectName: "Min"; min: -1000000.; max: 1000000.; init: 0. }
  FloatSpinBox { id: hi; objectName: "Max"; min: -1000000.; max: 1000000.; init: 1. }
  ComboBox     { id: edges; objectName: "At bounds"; choices: [ "Fold", "Clip", "Wrap" ]; index: 0 }
  FloatSlider  { id: inertia; objectName: "Inertia"; min: 0.; max: 0.99; init: 0. }
  IntSpinBox   { id: count; objectName: "Channels"; min: 1; max: 1000; init: 1 }
  IntSpinBox   { id: seed; objectName: "Seed"; min: 0; max: 1000000; init: 1 }
  Impulse      { id: reset; objectName: "Reset"; onImpulse: doReset = true }
  ValueOutlet  { id: output; objectName: "Out" }

  property var gen: null
  property var pos: []
  property var vel: []
  property int pending: 0
  property int usedSeed: -1
  property bool doReset: true

  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }
  function rng(s) {
    return function() {
      s = (s + 0x6D2B79F5) | 0;
      var t = Math.imul(s ^ (s >>> 15), 1 | s);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }
  function bound(x, a, b, m) {
    if (a >= b) return a;
    if (m === "Clip") return Math.max(a, Math.min(b, x));
    const span = b - a;
    if (m === "Wrap") return a + ((((x - a) % span) + span) % span);
    const two = 2. * span;
    var u = (((x - a) % two) + two) % two;
    return a + (u > span ? two - u : u);
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (gen === null || usedSeed !== seed.value) {
      usedSeed = seed.value;
      gen = rng(usedSeed !== 0 ? usedSeed : Math.floor(Math.random() * 1e9));
    }

    const n = Math.max(1, count.value);
    if (doReset || pos.length !== n) {
      doReset = false;
      pos = new Array(n); vel = new Array(n);
      const mid = 0.5 * (lo.value + hi.value);
      for (var i = 0; i < n; ++i) { pos[i] = mid; vel[i] = 0.; }
    }

    var shots = pending;
    pending = 0;
    if (boolOf(everyTick)) shots = Math.max(shots, 1);
    if (shots === 0)
      return;

    const a = lo.value, b = hi.value, m = choice(edges);
    const s = step.value, k = inertia.value;

    for (var t = 0; t < shots; ++t) {
      for (var j = 0; j < n; ++j) {
        const kick = (gen() * 2. - 1.) * s;
        // Inertia carries part of the previous move over: smoother wandering.
        vel[j] = vel[j] * k + kick * (1. - k);
        pos[j] = bound(pos[j] + vel[j], a, b, m);
      }
      output.value = (n === 1) ? pos[0] : pos.slice();
    }
  }
}
