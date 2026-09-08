import Score 1.0

// Smooth value noise over time — the organic wobble every media piece needs.
// Unlike Random it is continuous: neighbouring moments give neighbouring
// values, so it can drive a position or a camera directly.
// Several channels run on independent noise fields.
Script {
  FloatSpinBox { id: speed; objectName: "Speed (Hz)"; min: 0.; max: 100.; init: 0.5 }
  IntSpinBox   { id: octaves; objectName: "Octaves"; min: 1; max: 8; init: 3 }
  FloatSlider  { id: persistence; objectName: "Persistence"; min: 0.; max: 1.; init: 0.5 }
  FloatSpinBox { id: lo; objectName: "Min"; min: -1000000.; max: 1000000.; init: 0. }
  FloatSpinBox { id: hi; objectName: "Max"; min: -1000000.; max: 1000000.; init: 1. }
  IntSpinBox   { id: count; objectName: "Channels"; min: 1; max: 256; init: 1 }
  IntSpinBox   { id: seed; objectName: "Seed"; min: 0; max: 1000000; init: 1 }
  ValueOutlet  { id: output; objectName: "Out" }

  property real phase: 0.
  property real prevT: 0.

  // Hash from an integer lattice position to a value in 0..1.
  function hash(i, channel, s) {
    var h = (i | 0) * 374761393 + channel * 668265263 + s * 2246822519;
    h = (h ^ (h >>> 13)) | 0;
    h = Math.imul(h, 1274126177);
    h = (h ^ (h >>> 16)) >>> 0;
    return h / 4294967296;
  }
  function smoothNoise(x, channel, s) {
    const i = Math.floor(x);
    const f = x - i;
    // Smoothstep between the two lattice values: continuous slope, no creases.
    const u = f * f * (3. - 2. * f);
    const a = hash(i, channel, s), b = hash(i + 1, channel, s);
    return a + (b - a) * u;
  }
  function fbm(x, channel, s, oct, pers) {
    var sum = 0., amp = 1., norm = 0., freq = 1.;
    for (var o = 0; o < oct; ++o) {
      sum += amp * smoothNoise(x * freq, channel + o * 101, s);
      norm += amp;
      amp *= pers;
      freq *= 2.;
    }
    return (norm > 0.) ? sum / norm : 0.;
  }

  tick: function(token, state) {
    const t = 1000. * (token.date * state.model_to_physical) / state.sample_rate;
    const dt = Math.max(0., t - prevT) / 1000.;
    prevT = t;

    // Integrating the speed means it can be changed live without jumping.
    phase += dt * speed.value;

    const n = Math.max(1, count.value);
    const a = lo.value, b = hi.value;
    const oct = Math.max(1, octaves.value);
    const pers = persistence.value;
    const s = seed.value;

    var out = new Array(n);
    for (var i = 0; i < n; ++i)
      out[i] = a + fbm(phase, i * 7919, s, oct, pers) * (b - a);

    output.value = (n === 1) ? out[0] : out;
  }
}
