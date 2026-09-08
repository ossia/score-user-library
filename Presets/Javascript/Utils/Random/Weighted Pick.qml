import Score 1.0

// Picks an index at random, but with weights: some options come up more often.
// Feed the weights from anything — a histogram, a set of faders, an analysis —
// and the choice follows it live.
Script {
  Impulse     { id: bang; objectName: "Bang"; onImpulse: pending++ }
  ValueInlet  { id: weightsIn; objectName: "Weights" }
  LineEdit    { id: weightsText; objectName: "Weights (if unconnected)"; text: "1, 1, 2, 4" }
  ValueInlet  { id: itemsIn; objectName: "Items" }
  FloatSpinBox { id: bias; objectName: "Contrast"; min: 0.; max: 8.; init: 1. }
  IntSpinBox  { id: seed; objectName: "Seed"; min: 0; max: 1000000; init: 0 }
  ValueOutlet { id: indexOut; objectName: "Index" }
  ValueOutlet { id: valueOut; objectName: "Value" }
  ValueOutlet { id: probsOut; objectName: "Probabilities" }

  property var gen: null
  property int usedSeed: -1
  property int pending: 0
  property var latchedW: undefined
  property var items: undefined

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function asList(v) {
    if (v === undefined || v === null) return [];
    if (isList(v)) { var r = new Array(v.length); for (var i = 0; i < v.length; ++i) r[i] = v[i]; return r; }
    return [ v ];
  }
  function str(ctl) { return (typeof ctl.value === "string") ? ctl.value : ctl.text; }
  function parseList(text) {
    const parts = text.split(",");
    var r = [];
    for (var i = 0; i < parts.length; ++i) {
      const n = Number(parts[i].trim());
      if (isFinite(n)) r.push(n);
    }
    return r;
  }
  function rng(s) {
    return function() {
      s = (s + 0x6D2B79F5) | 0;
      var t = Math.imul(s ^ (s >>> 15), 1 | s);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }

  tick: function(token, state) {
    if (gen === null || usedSeed !== seed.value) {
      usedSeed = seed.value;
      gen = rng(usedSeed !== 0 ? usedSeed : Math.floor(Math.random() * 1e9));
    }

    if (typeof weightsIn.value !== "undefined") latchedW = asList(weightsIn.value);
    if (typeof itemsIn.value !== "undefined") items = asList(itemsIn.value);
    if (pending === 0)
      return;

    const raw = (latchedW !== undefined && latchedW.length > 0)
              ? latchedW : parseList(str(weightsText));
    const k = bias.value;

    // Contrast above 1 exaggerates the differences, below 1 evens them out.
    var w = new Array(raw.length), total = 0.;
    for (var i = 0; i < raw.length; ++i) {
      var x = Number(raw[i]);
      if (!isFinite(x) || x < 0.) x = 0.;
      w[i] = (k === 1.) ? x : Math.pow(x, k);
      total += w[i];
    }
    if (raw.length === 0 || total <= 0.) { pending = 0; return; }

    var probs = new Array(w.length);
    for (var p = 0; p < w.length; ++p) probs[p] = w[p] / total;
    probsOut.value = probs;

    while (pending > 0) {
      pending--;
      var r = gen() * total, pick = w.length - 1;
      for (var j = 0; j < w.length; ++j) {
        r -= w[j];
        if (r <= 0.) { pick = j; break; }
      }
      indexOut.value = pick;
      if (items !== undefined && pick < items.length)
        valueOut.value = items[pick];
    }
  }
}
