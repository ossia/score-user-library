import Score 1.0

// Keeps only the elements for which an expression is true.
//
// Inside the expression:
//   x  the element        i  its index         n  the length of the list
//   a  the whole list     t  time in ms        p  the extra inlet (latched)
//
// Try:  x > 0.5   |   i % 2 === 0   |   x[2] > p   (for a list of points)
Script {
  ValueInlet  { id: input; objectName: "In" }
  LineEdit    { id: expr; objectName: "Keep if"; text: "x > 0.5" }
  ValueInlet  { id: param; objectName: "P" }
  Toggle      { id: invert; objectName: "Invert"; checked: false }
  ValueOutlet { id: output; objectName: "Kept" }
  ValueOutlet { id: indicesOut; objectName: "Indices" }
  ValueOutlet { id: countOut; objectName: "Count" }
  ValueOutlet { id: rejectOut; objectName: "Rejected" }

  property var p: 0

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

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof param.value !== "undefined") p = param.value;
    if (typeof input.value === "undefined")
      return;

    const src = str(expr);
    if (src.length === 0)
      return;

    const a = asList(input.value);
    const n = a.length;
    const t = 1000. * (token.date * state.model_to_physical) / state.sample_rate;
    const inv = boolOf(invert);

    var kept = [], idx = [], rejected = [];
    try {
      for (var i = 0; i < n; ++i) {
        const x = a[i];
        var ok = !!eval(src);
        if (inv) ok = !ok;
        if (ok) { kept.push(x); idx.push(i); }
        else rejected.push(x);
      }
    } catch (e) {
      console.log("Filter: " + e);
      return;
    }

    output.value = kept;
    indicesOut.value = idx;
    countOut.value = kept.length;
    rejectOut.value = rejected;
  }
}
