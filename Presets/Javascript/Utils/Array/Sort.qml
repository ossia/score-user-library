import Score 1.0

// Sorts a list, and also gives back the permutation that was applied.
// "Order" lets you reorder a second, parallel list the same way — the usual
// trick for sorting points by depth, blobs by size, notes by pitch...
Script {
  ValueInlet  { id: input; objectName: "In" }
  ComboBox    { id: order; objectName: "Order"; choices: [ "Ascending", "Descending" ]; index: 0 }
  ComboBox    { id: kind; objectName: "Compare"; choices: [ "Numeric", "Text" ]; index: 0 }
  IntSpinBox  { id: key; objectName: "Key index"; min: -1; max: 1000000; init: -1 }
  ValueOutlet { id: output; objectName: "Sorted" }
  ValueOutlet { id: orderOut; objectName: "Order" }
  ValueOutlet { id: rankOut; objectName: "Rank" }

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
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const l = asList(input.value);
    const k = key.value;
    const numeric = (choice(kind) === "Numeric");
    const sign = (choice(order) === "Descending") ? -1 : 1;

    // Key of an element: the element itself, or one of its fields.
    function keyOf(e) {
      if (k >= 0 && isList(e)) return (k < e.length) ? e[k] : 0;
      return e;
    }

    var idx = new Array(l.length);
    for (var i = 0; i < l.length; ++i) idx[i] = i;

    idx.sort(function(ia, ib) {
      const a = keyOf(l[ia]), b = keyOf(l[ib]);
      var c;
      if (numeric) {
        const na = Number(a), nb = Number(b);
        c = (isFinite(na) ? na : 0) - (isFinite(nb) ? nb : 0);
      } else {
        const sa = String(a), sb = String(b);
        c = (sa < sb) ? -1 : (sa > sb) ? 1 : 0;
      }
      // Stable for equal keys: fall back on the original position.
      return (c !== 0) ? sign * c : (ia - ib);
    });

    var sorted = new Array(l.length), rank = new Array(l.length);
    for (var j = 0; j < idx.length; ++j) {
      sorted[j] = l[idx[j]];
      rank[idx[j]] = j;
    }

    output.value = sorted;
    orderOut.value = idx;
    rankOut.value = rank;
  }
}
