import Score 1.0

// Boolean logic between two inputs.
// Anything non-zero and non-empty counts as true.  Element-wise on lists.
Script {
  ValueInlet  { id: inA; objectName: "A" }
  ValueInlet  { id: inB; objectName: "B" }
  Toggle      { id: constB; objectName: "B (if unconnected)"; checked: false }
  ComboBox    { id: op; objectName: "Operation"
                choices: [ "And", "Or", "Xor", "Nand", "Nor", "Xnor",
                           "Not A", "A and not B", "Implies" ]
                index: 0 }
  ValueOutlet { id: output; objectName: "Out" }

  property var latchedB: undefined

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
  function truth(v) {
    if (typeof v === "boolean") return v;
    if (typeof v === "number") return v !== 0;
    if (typeof v === "string") return v.length > 0 && v !== "0" && v.toLowerCase() !== "false";
    return !!v;
  }
  function zipWith(a, b, f) {
    const la = isList(a), lb = isList(b);
    if (!la && !lb) return f(truth(a), truth(b));
    if (la && !lb) {
      var r = new Array(a.length);
      for (var i = 0; i < a.length; ++i) r[i] = zipWith(a[i], b, f);
      return r;
    }
    if (!la && lb) {
      var r2 = new Array(b.length);
      for (var j = 0; j < b.length; ++j) r2[j] = zipWith(a, b[j], f);
      return r2;
    }
    if (a.length === 0 || b.length === 0) return [];
    const n = Math.max(a.length, b.length);
    var r3 = new Array(n);
    for (var k = 0; k < n; ++k) r3[k] = zipWith(a[k % a.length], b[k % b.length], f);
    return r3;
  }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof inB.value !== "undefined")
      latchedB = copyOf(inB.value);
    if (typeof inA.value === "undefined")
      return;

    const b = (latchedB !== undefined) ? latchedB : boolOf(constB);
    const name = choice(op);
    output.value = zipWith(inA.value, b, function(x, y) {
      switch (name) {
        case "Or":          return x || y;
        case "Xor":         return x !== y;
        case "Nand":        return !(x && y);
        case "Nor":         return !(x || y);
        case "Xnor":        return x === y;
        case "Not A":       return !x;
        case "A and not B": return x && !y;
        case "Implies":     return !x || y;
        default:            return x && y;
      }
    });
  }
}
