import Score 1.0

// [unpack] — splits a list into separate outputs.
// "Rest" carries whatever did not fit, so several of these can be chained.
Script {
  ValueInlet  { id: input; objectName: "In" }
  IntSpinBox  { id: offset; objectName: "Offset"; min: 0; max: 1000000; init: 0 }
  Toggle      { id: onlyPresent; objectName: "Skip missing"; checked: true }
  ValueOutlet { id: out1; objectName: "Out 1" }
  ValueOutlet { id: out2; objectName: "Out 2" }
  ValueOutlet { id: out3; objectName: "Out 3" }
  ValueOutlet { id: out4; objectName: "Out 4" }
  ValueOutlet { id: rest; objectName: "Rest" }

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

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const outs = [ out1, out2, out3, out4 ];
    const l = asList(input.value);
    const off = offset.value;

    for (var i = 0; i < outs.length; ++i) {
      const k = off + i;
      if (k < l.length)
        outs[i].value = l[k];
      else if (!boolOf(onlyPresent))
        outs[i].value = 0;
    }

    const tail = off + outs.length;
    if (tail < l.length)
      rest.value = l.slice(tail);
  }
}
