import Score 1.0

// Random values on demand.
// A fixed seed always replays the same sequence, so a piece can be rehearsed:
// set Seed to 0 to get a different one on every run.
Script {
  Impulse      { id: bang; objectName: "Bang"; onImpulse: pending++ }
  Toggle       { id: everyTick; objectName: "Every tick"; checked: false }
  FloatSpinBox { id: lo; objectName: "Min"; min: -1000000.; max: 1000000.; init: 0. }
  FloatSpinBox { id: hi; objectName: "Max"; min: -1000000.; max: 1000000.; init: 1. }
  IntSpinBox   { id: count; objectName: "Count"; min: 1; max: 10000; init: 1 }
  ComboBox     { id: shape; objectName: "Distribution"; choices: [ "Uniform", "Bell", "Low", "High" ]; index: 0 }
  Toggle       { id: integers; objectName: "Integers"; checked: false }
  IntSpinBox   { id: seed; objectName: "Seed"; min: 0; max: 1000000; init: 0 }
  ValueOutlet  { id: output; objectName: "Out" }

  property var gen: null
  property int pending: 0
  property int usedSeed: -1

  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }
  // mulberry32: tiny, fast, and reproducible across machines.
  function rng(s) {
    return function() {
      s = (s + 0x6D2B79F5) | 0;
      var t = Math.imul(s ^ (s >>> 15), 1 | s);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }
  function draw(rand, kind) {
    switch (kind) {
      // Sum of two draws: values cluster around the middle.
      case "Bell": return 0.5 * (rand() + rand());
      case "Low":  return rand() * rand();
      case "High": return 1. - rand() * rand();
      default:     return rand();
    }
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (gen === null || usedSeed !== seed.value) {
      usedSeed = seed.value;
      // Seed 0 means "do not reproduce": start from wherever the run happens to be.
      gen = rng(usedSeed !== 0 ? usedSeed : Math.floor(Math.random() * 1e9));
    }

    var shots = pending;
    pending = 0;
    if (boolOf(everyTick)) shots = Math.max(shots, 1);
    if (shots === 0)
      return;

    const a = lo.value, b = hi.value;
    const kind = choice(shape);
    const n = Math.max(1, count.value);
    const asInt = boolOf(integers);

    for (var s = 0; s < shots; ++s) {
      var out = new Array(n);
      for (var i = 0; i < n; ++i) {
        var v = a + draw(gen, kind) * (b - a);
        if (asInt) v = Math.round(v);
        out[i] = v;
      }
      output.value = (n === 1) ? out[0] : out;
    }
  }
}
