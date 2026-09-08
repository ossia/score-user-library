import Score 1.0

// Reorders a list at random, and can pick a subset while at it.
// With a fixed seed the same list always shuffles the same way.
Script {
  ValueInlet  { id: input; objectName: "In" }
  Impulse     { id: bang; objectName: "Shuffle"; onImpulse: pending = true }
  Toggle      { id: onEvery; objectName: "On every value"; checked: true }
  IntSpinBox  { id: take; objectName: "Take"; min: -1; max: 100000; init: -1 }
  IntSpinBox  { id: seed; objectName: "Seed"; min: 0; max: 1000000; init: 0 }
  ValueOutlet { id: output; objectName: "Out" }
  ValueOutlet { id: orderOut; objectName: "Order" }

  property var gen: null
  property int usedSeed: -1
  property bool pending: false
  property var held: undefined

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function asList(v) {
    if (v === undefined || v === null) return [];
    if (isList(v)) { var r = new Array(v.length); for (var i = 0; i < v.length; ++i) r[i] = v[i]; return r; }
    if (typeof v === "object" && typeof v.x === "number") {
      var o = [ v.x, v.y ];
      if (typeof v.z === "number") o.push(v.z);
      if (typeof v.w === "number") o.push(v.w);
      return o;
    }
    return [ v ];
  }
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
    if (gen === null || usedSeed !== seed.value) {
      usedSeed = seed.value;
      gen = rng(usedSeed !== 0 ? usedSeed : Math.floor(Math.random() * 1e9));
    }

    var fresh = false;
    if (typeof input.value !== "undefined") { held = asList(input.value); fresh = true; }
    if (held === undefined)
      return;

    const go = pending || (fresh && boolOf(onEvery));
    pending = false;
    if (!go)
      return;

    // Fisher-Yates over the indices, so the permutation can be reused elsewhere.
    var idx = new Array(held.length);
    for (var i = 0; i < held.length; ++i) idx[i] = i;
    for (var j = idx.length - 1; j > 0; --j) {
      const k = Math.floor(gen() * (j + 1));
      const tmp = idx[j]; idx[j] = idx[k]; idx[k] = tmp;
    }

    const n = (take.value < 0) ? idx.length : Math.min(take.value, idx.length);
    var out = new Array(n), ord = new Array(n);
    for (var m = 0; m < n; ++m) { out[m] = held[idx[m]]; ord[m] = idx[m]; }

    output.value = out;
    orderOut.value = ord;
  }
}
