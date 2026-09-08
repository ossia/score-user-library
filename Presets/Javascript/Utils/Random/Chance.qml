import Score 1.0

// Lets each value through with a given probability.
// Sprinkle it in front of a trigger to thin out a pattern without changing it.
Script {
  ValueInlet  { id: input; objectName: "In" }
  FloatSlider { id: probability; objectName: "Probability"; min: 0.; max: 1.; init: 0.5 }
  ValueInlet  { id: probIn; objectName: "Probability in" }
  IntSpinBox  { id: seed; objectName: "Seed"; min: 0; max: 1000000; init: 0 }
  ValueOutlet { id: output; objectName: "Pass" }
  ValueOutlet { id: reject; objectName: "Reject" }
  ValueOutlet { id: ratioOut; objectName: "Pass ratio" }

  property var gen: null
  property int usedSeed: -1
  property var latchedP: undefined
  property int nbSeen: 0
  property int nbPassed: 0

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function rng(s) {
    return function() {
      s = (s + 0x6D2B79F5) | 0;
      var t = Math.imul(s ^ (s >>> 15), 1 | s);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }
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
    if (gen === null || usedSeed !== seed.value) {
      usedSeed = seed.value;
      gen = rng(usedSeed !== 0 ? usedSeed : Math.floor(Math.random() * 1e9));
    }

    if (typeof probIn.value !== "undefined") {
      const p = Number(isList(probIn.value) ? probIn.value[0] : probIn.value);
      if (isFinite(p)) latchedP = p;
    }
    const p = Math.max(0., Math.min(1., (latchedP !== undefined) ? latchedP : probability.value));

    const msgs = incoming(input);
    for (var i = 0; i < msgs.length; ++i) {
      nbSeen++;
      if (gen() < p) {
        nbPassed++;
        output.addValue(msgs[i].t, msgs[i].v);
      } else {
        reject.addValue(msgs[i].t, msgs[i].v);
      }
    }
    if (msgs.length > 0)
      ratioOut.value = nbPassed / nbSeen;
  }
}
