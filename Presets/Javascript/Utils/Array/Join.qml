import Score 1.0

// Concatenates several lists end to end.
// Each inlet keeps its last value; scalars are appended as a single element.
Script {
  ValueInlet  { id: in1; objectName: "In 1" }
  ValueInlet  { id: in2; objectName: "In 2" }
  ValueInlet  { id: in3; objectName: "In 3" }
  ValueInlet  { id: in4; objectName: "In 4" }
  Toggle      { id: nested; objectName: "Keep as sub-lists"; checked: false }
  Toggle      { id: onAny; objectName: "Output on any change"; checked: true }
  ValueOutlet { id: output; objectName: "Out" }
  ValueOutlet { id: lengthOut; objectName: "Length" }

  property var held: [ undefined, undefined, undefined, undefined ]

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
    const ins = [ in1, in2, in3, in4 ];
    var touched = false;
    for (var i = 0; i < ins.length; ++i) {
      if (typeof ins[i].value !== "undefined") {
        held[i] = asList(ins[i].value);
        touched = true;
      }
    }
    if (!touched && boolOf(onAny))
      return;

    var out = [];
    for (var j = 0; j < ins.length; ++j) {
      if (held[j] === undefined) continue;
      if (boolOf(nested)) out.push(held[j]);
      else out = out.concat(held[j]);
    }
    output.value = out;
    lengthOut.value = out.length;
  }
}
