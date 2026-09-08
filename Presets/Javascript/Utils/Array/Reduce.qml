import Score 1.0

// Folds a whole list down to a single value.
//
// Inside the expression:
//   acc  the value so far   x  the element   i  its index   n  the length
//   a    the whole list     p  the extra inlet (latched)
//
// Try:  acc + x   |   Math.max(acc, x)   |   acc + x * x   (then take a sqrt)
Script {
  ValueInlet  { id: input; objectName: "In" }
  LineEdit    { id: initial; objectName: "Initial"; text: "0" }
  LineEdit    { id: expr; objectName: "Expression"; text: "acc + x" }
  LineEdit    { id: finish; objectName: "Finally"; text: "acc" }
  ValueInlet  { id: param; objectName: "P" }
  ValueOutlet { id: output; objectName: "Out" }

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

    try {
      var acc = eval("(" + (str(initial) || "0") + ")");
      for (var i = 0; i < n; ++i) {
        const x = a[i];
        acc = eval(src);
      }
      const fin = str(finish).trim();
      const res = (fin.length > 0) ? eval(fin) : acc;
      if (typeof res !== "undefined" && finite(res))
        output.value = res;
    } catch (e) {
      console.log("Reduce: " + e);
    }
  }
}
