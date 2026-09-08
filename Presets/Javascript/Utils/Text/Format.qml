import Score 1.0

// Builds a string out of incoming values.
// In the template, {0} {1} {2} are the elements of the list (or the extra
// inlets A and B), and {} is the whole value.
//
// Try:  x = {0}, y = {1}   |   {0}%   |   /cue/{0}
Script {
  ValueInlet  { id: input; objectName: "In" }
  LineEdit    { id: template; objectName: "Template"; text: "{0}, {1}" }
  IntSpinBox  { id: decimals; objectName: "Decimals"; min: -1; max: 12; init: 2 }
  ValueInlet  { id: inA; objectName: "A" }
  ValueInlet  { id: inB; objectName: "B" }
  ValueOutlet { id: output; objectName: "Out" }

  property var latchedA: undefined
  property var latchedB: undefined

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
  function str(ctl) { return (typeof ctl.value === "string") ? ctl.value : ctl.text; }

  function render(v, d) {
    if (v === undefined || v === null) return "";
    if (isList(v)) {
      var parts = [];
      for (var i = 0; i < v.length; ++i) parts.push(render(v[i], d));
      return parts.join(" ");
    }
    if (typeof v === "number")
      return (d >= 0) ? v.toFixed(d) : String(v);
    return String(v);
  }

  tick: function(token, state) {
    if (typeof inA.value !== "undefined") latchedA = inA.value;
    if (typeof inB.value !== "undefined") latchedB = inB.value;
    if (typeof input.value === "undefined")
      return;

    const d = decimals.value;
    const v = input.value;
    var fields = asList(v);
    // The extra inlets extend the field list, so {2} and {3} can reach them.
    if (latchedA !== undefined) fields = fields.concat([ latchedA ]);
    if (latchedB !== undefined) fields = fields.concat([ latchedB ]);

    const out = str(template).replace(/\{(\d*)\}/g, function(m, digits) {
      if (digits.length === 0)
        return render(v, d);
      const k = parseInt(digits, 10);
      return (k >= 0 && k < fields.length) ? render(fields[k], d) : "";
    });

    output.value = out;
  }
}
