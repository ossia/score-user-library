import Score 1.0

// Evaluates a JavaScript expression on every incoming value.
//
// Available inside the expression:
//   x    the incoming value (a number, a string, or an array)
//   px   the previous input,  po  the previous output
//   t    date of the tick in ms,  dt  time since the last tick in ms
//   pos  position inside the parent interval, 0 to 1
//   fs   sample rate,  n  number of values seen so far
//   m    a persistent object, free for you to store anything between ticks
//   a, b two extra inlets, latched to their last received value
//
// Try:  x * 2   |   Math.sin(t / 500)   |   x.map(v => v * a)   |   (m.s = (m.s||0) + x)
Script {
  ValueInlet  { id: input; objectName: "Value In" }
  LineEdit    { id: expr; objectName: "Expression"; text: "x * 2" }
  ValueInlet  { id: inA; objectName: "A" }
  ValueInlet  { id: inB; objectName: "B" }
  ValueOutlet { id: output; objectName: "Value Out" }

  property var px: undefined
  property var po: undefined
  property var m: ({})
  property var a: 0
  property var b: 0
  property int n: 0
  property real prevT: 0

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
    const t = 1000. * (token.date * state.model_to_physical) / state.sample_rate;
    const dt = t - prevT;
    prevT = t;

    if (typeof inA.value !== "undefined") a = inA.value;
    if (typeof inB.value !== "undefined") b = inB.value;

    if (typeof input.value === "undefined")
      return;

    const x = input.value;
    const pos = token.position();
    const fs = state.sample_rate;
    const src = str(expr);
    if (src.length === 0)
      return;

    var o;
    try { o = eval(src); }
    catch (e) { console.log("Expression: " + e); return; }

    px = x;
    po = o;
    n++;
    if (typeof o !== "undefined" && finite(o))
      output.value = o;
  }
}
