import Score 1.0

// Follows the energy of a stream: fast to rise, slow to fall.
// Written for control data rather than audio — point it at a magnitude, an
// accelerometer norm, a level meter, and get something a light can follow.
Script {
  ValueInlet   { id: input; objectName: "In" }
  ComboBox     { id: detector; objectName: "Detector"; choices: [ "Absolute", "RMS", "Peak" ]; index: 0 }
  FloatSpinBox { id: attack; objectName: "Attack (ms)"; min: 0.; max: 60000.; init: 10. }
  FloatSpinBox { id: release; objectName: "Release (ms)"; min: 0.; max: 60000.; init: 300. }
  FloatSpinBox { id: gain; objectName: "Gain"; min: 0.; max: 1000.; init: 1. }
  ValueOutlet  { id: output; objectName: "Out" }
  ValueOutlet  { id: peakOut; objectName: "Peak hold" }

  property real env: 0.
  property real peak: 0.
  property real prevT: 0.

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function magnitude(v, kind) {
    var xs = [];
    (function flat(u) {
      if (isList(u)) { for (var i = 0; i < u.length; ++i) flat(u[i]); }
      else if (u !== null && typeof u === "object" && typeof u.x === "number") {
        flat(u.x); flat(u.y);
        if (typeof u.z === "number") flat(u.z);
      }
      else { const n = Number(u); if (isFinite(n)) xs.push(n); }
    })(v);

    if (xs.length === 0) return 0.;
    if (kind === "RMS") {
      var sq = 0.;
      for (var i = 0; i < xs.length; ++i) sq += xs[i] * xs[i];
      return Math.sqrt(sq / xs.length);
    }
    if (kind === "Peak") {
      var p = 0.;
      for (var j = 0; j < xs.length; ++j) p = Math.max(p, Math.abs(xs[j]));
      return p;
    }
    var s = 0.;
    for (var k = 0; k < xs.length; ++k) s += Math.abs(xs[k]);
    return s / xs.length;
  }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }

  property real target: 0.

  tick: function(token, state) {
    const t = 1000. * (token.date * state.model_to_physical) / state.sample_rate;
    const dt = Math.max(0., t - prevT);
    prevT = t;

    if (typeof input.value !== "undefined")
      target = magnitude(input.value, choice(detector)) * gain.value;

    // Two time constants: one for going up, one for coming back down.
    const tau = (target > env) ? attack.value : release.value;
    const alpha = (tau <= 0.) ? 1. : (1. - Math.exp(-dt / tau));
    env += (target - env) * alpha;

    peak = Math.max(target, peak - (dt / Math.max(1., release.value)) * peak);

    output.value = env;
    peakOut.value = peak;
  }
}
