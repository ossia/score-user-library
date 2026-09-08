import Score 1.0

// [urn] — random without repetition: every option comes up once before any
// of them comes up again. What you want for shuffling clips, phrases, cues.
Script {
  Impulse     { id: bang; objectName: "Bang"; onImpulse: pending++ }
  IntSpinBox  { id: count; objectName: "Count"; min: 1; max: 100000; init: 8 }
  ValueInlet  { id: itemsIn; objectName: "Items" }
  Toggle      { id: autoRefill; objectName: "Refill when empty"; checked: true }
  Toggle      { id: avoidRepeat; objectName: "Avoid repeat on refill"; checked: true }
  IntSpinBox  { id: seed; objectName: "Seed"; min: 0; max: 1000000; init: 0 }
  Impulse     { id: reset; objectName: "Refill"; onImpulse: doRefill = true }
  ValueOutlet { id: indexOut; objectName: "Index" }
  ValueOutlet { id: valueOut; objectName: "Value" }
  ValueOutlet { id: emptyOut; objectName: "Empty" }
  ValueOutlet { id: leftOut; objectName: "Remaining" }

  property var bag: []
  property var items: undefined
  property var gen: null
  property int usedSeed: -1
  property int pending: 0
  property int lastDrawn: -1
  property bool doRefill: true

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
  function rng(s) {
    return function() {
      s = (s + 0x6D2B79F5) | 0;
      var t = Math.imul(s ^ (s >>> 15), 1 | s);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }
  function refill(n) {
    var b = new Array(n);
    for (var i = 0; i < n; ++i) b[i] = i;
    // Keep the last drawn item away from the front, so a refill never repeats.
    if (boolOf(avoidRepeat) && n > 1 && lastDrawn >= 0 && lastDrawn < n) {
      const swapWith = 1 + Math.floor(gen() * (n - 1));
      const at = b.indexOf(lastDrawn);
      const tmp = b[at]; b[at] = b[swapWith]; b[swapWith] = tmp;
    }
    return b;
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (gen === null || usedSeed !== seed.value) {
      usedSeed = seed.value;
      gen = rng(usedSeed !== 0 ? usedSeed : Math.floor(Math.random() * 1e9));
    }

    if (typeof itemsIn.value !== "undefined")
      items = asList(itemsIn.value);

    const n = (items !== undefined && items.length > 0) ? items.length : Math.max(1, count.value);

    if (doRefill) { doRefill = false; bag = refill(n); }
    if (bag.length === 0 && boolOf(autoRefill)) bag = refill(n);

    while (pending > 0) {
      pending--;
      if (bag.length === 0) {
        emptyOut.value = true;
        if (!boolOf(autoRefill)) break;
        bag = refill(n);
      }
      const k = Math.floor(gen() * bag.length);
      const pick = bag[k];
      bag.splice(k, 1);
      lastDrawn = pick;

      indexOut.value = pick;
      if (items !== undefined && pick < items.length)
        valueOut.value = items[pick];
      if (bag.length === 0)
        emptyOut.value = true;
    }

    leftOut.value = bag.length;
  }
}
