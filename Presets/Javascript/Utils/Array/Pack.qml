import Score 1.0

// [pack] — gathers several separate values into one list.
// Each inlet keeps its last value, so partial updates still produce a full list.
Script {
  ValueInlet  { id: in1; objectName: "In 1" }
  ValueInlet  { id: in2; objectName: "In 2" }
  ValueInlet  { id: in3; objectName: "In 3" }
  ValueInlet  { id: in4; objectName: "In 4" }
  IntSlider   { id: count; objectName: "Count"; min: 1; max: 4; init: 2 }
  LineEdit    { id: defaults; objectName: "Defaults"; text: "0, 0, 0, 0" }
  Toggle      { id: onAny; objectName: "Output on any change"; checked: true }
  ValueOutlet { id: output; objectName: "Out" }

  property var held: [ undefined, undefined, undefined, undefined ]

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function copyOf(v) {
    if (!isList(v)) return v;
    var r = new Array(v.length);
    for (var i = 0; i < v.length; ++i) r[i] = copyOf(v[i]);
    return r;
  }
  function str(ctl) { return (typeof ctl.value === "string") ? ctl.value : ctl.text; }
  function defaultAt(i) {
    const parts = str(defaults).split(",");
    if (i >= parts.length) return 0;
    const t = parts[i].trim();
    const n = Number(t);
    return isFinite(n) && t.length > 0 ? n : t;
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    const ins = [ in1, in2, in3, in4 ];
    var touched = false;
    for (var i = 0; i < ins.length; ++i) {
      if (typeof ins[i].value !== "undefined") {
        held[i] = copyOf(ins[i].value);
        touched = true;
      }
    }
    if (!touched && boolOf(onAny))
      return;

    const n = Math.max(1, Math.min(count.value, ins.length));
    var out = new Array(n);
    for (var j = 0; j < n; ++j)
      out[j] = (held[j] !== undefined) ? held[j] : defaultAt(j);
    output.value = out;
  }
}
