import Score 1.0

// Reads one element out of a list.
// The index can also arrive on a cable, which turns this into a sequencer
// step reader or a table lookup.
Script {
  ValueInlet  { id: input; objectName: "In" }
  ValueInlet  { id: indexIn; objectName: "Index" }
  IntSpinBox  { id: fallbackIndex; objectName: "Index (if unconnected)"; min: -1000000; max: 1000000; init: 0 }
  ComboBox    { id: mode; objectName: "Out of range"; choices: [ "Clamp", "Wrap", "Nothing" ]; index: 1 }
  ValueOutlet { id: output; objectName: "Out" }
  ValueOutlet { id: usedIndex; objectName: "Used index" }

  property var latchedIndex: undefined

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
    if (typeof indexIn.value !== "undefined") {
      const iv = Number(isList(indexIn.value) ? indexIn.value[0] : indexIn.value);
      if (isFinite(iv)) latchedIndex = Math.round(iv);
    }
    if (typeof input.value === "undefined")
      return;

    const l = asList(input.value);
    if (l.length === 0)
      return;

    var i = (latchedIndex !== undefined) ? latchedIndex : fallbackIndex.value;
    if (i < 0 || i >= l.length) {
      const m = choice(mode);
      if (m === "Clamp") i = Math.max(0, Math.min(l.length - 1, i));
      else if (m === "Wrap") i = ((i % l.length) + l.length) % l.length;
      else return;
    }

    usedIndex.value = i;
    output.value = l[i];
  }
}
