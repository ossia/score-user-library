import Score 1.0

// Two-operand maths. A and B may each be a number or a list:
//   number + number  -> number
//   list   + number  -> the number is applied to every element
//   list   + list    -> element-wise; the shorter one cycles, vvvv style
// B keeps its last received value, so it can be left unconnected and typed in.
Script {
  ValueInlet   { id: inA; objectName: "A" }
  ValueInlet   { id: inB; objectName: "B" }
  FloatSpinBox { id: constB; objectName: "B (if unconnected)"; min: -1000000.; max: 1000000.; init: 1. }
  ComboBox     { id: op; objectName: "Operation"
                 choices: [ "Add", "Subtract", "Multiply", "Divide", "Modulo",
                            "Power", "Min", "Max", "Average", "Difference",
                            "Hypot", "Atan2", "Log base" ]
                 index: 0 }
  ValueOutlet  { id: output; objectName: "Out" }

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
  // Broadcasts f over any mix of numbers and lists.
  function zipWith(a, b, f) {
    const la = isList(a), lb = isList(b);
    if (!la && !lb)
      return f(Number(a), Number(b));
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
  function operator(name) {
    switch (name) {
      case "Subtract":   return function(x, y) { return x - y; };
      case "Multiply":   return function(x, y) { return x * y; };
      case "Divide":     return function(x, y) { return y === 0 ? 0 : x / y; };
      case "Modulo":     return function(x, y) { return y === 0 ? 0 : ((x % y) + y) % y; };
      case "Power":      return function(x, y) { return Math.pow(x, y); };
      case "Min":        return Math.min;
      case "Max":        return Math.max;
      case "Average":    return function(x, y) { return 0.5 * (x + y); };
      case "Difference": return function(x, y) { return Math.abs(x - y); };
      case "Hypot":      return function(x, y) { return Math.sqrt(x * x + y * y); };
      case "Atan2":      return function(x, y) { return Math.atan2(x, y); };
      case "Log base":   return function(x, y) { return (x <= 0 || y <= 0 || y === 1) ? 0 : Math.log(x) / Math.log(y); };
      default:           return function(x, y) { return x + y; };
    }
  }

  tick: function(token, state) {
    if (typeof inB.value !== "undefined")
      latchedB = copyOf(inB.value);
    if (typeof inA.value === "undefined")
      return;

    const b = (latchedB !== undefined) ? latchedB : constB.value;
    output.value = zipWith(inA.value, b, operator(choice(op)));
  }
}
