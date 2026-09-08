import Score 1.0

// Applies a JavaScript expression to every element of a list.
//
// Inside the expression:
//   x  the element        i  its index         n  the length of the list
//   a  the whole list     t  time in ms        m  a persistent scratch object
//   p  the extra inlet, latched to its last value
//
// Try:  x * 2   |   x + Math.sin(i / n * 6.28 + t / 500)   |   [x, i / n]
Script {
  ValueInlet  { id: input; objectName: "In" }
  LineEdit    { id: expr; objectName: "Expression"; text: "x * 2" }
  ValueInlet  { id: param; objectName: "P" }
  ValueOutlet { id: output; objectName: "Out" }

  property var m: ({})
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

  // An expression can easily produce NaN (arithmetic on a list, a division by
  // zero...). Emitting it would poison everything downstream, so drop it.
  function finite(v) {
    if (typeof v === "number") return isFinite(v);
    if (v !== null && typeof v === "object" && typeof v.length === "number") {
      for (var i = 0; i < v.length; ++i) if (!finite(v[i])) return false;
    }
    return true;
  }

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

    var out = new Array(n);
    try {
      for (var i = 0; i < n; ++i) {
        const x = a[i];
        out[i] = eval(src);
      }
    } catch (e) {
      console.log("Map: " + e);
      return;
    }
    if (finite(out))
      output.value = out;
  }
}
