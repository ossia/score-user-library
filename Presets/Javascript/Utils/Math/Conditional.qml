import Score 1.0

// [if] — picks between two expressions depending on a test.
// Same variables as the Expression node: x, px, po, t, dt, pos, fs, n, m, a, b.
// Leaving "Else" empty means: emit nothing when the test fails.
Script {
  ValueInlet  { id: input; objectName: "Value In" }
  LineEdit    { id: in_if; objectName: "If"; text: "x > 0.5" }
  LineEdit    { id: in_then; objectName: "Then"; text: "1" }
  LineEdit    { id: in_else; objectName: "Else"; text: "0" }
  ValueInlet  { id: inA; objectName: "A" }
  ValueInlet  { id: inB; objectName: "B" }
  ValueOutlet { id: output; objectName: "Value Out" }
  ValueOutlet { id: test; objectName: "Test" }

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

    var o;
    try {
      const cond = eval(str(in_if));
      test.value = !!cond;
      const branch = cond ? str(in_then) : str(in_else);
      if (branch.trim().length === 0)
        { px = x; return; }
      o = eval(branch);
    } catch (e) {
      console.log("Conditional: " + e);
      return;
    }

    px = x;
    po = o;
    n++;
    if (typeof o !== "undefined" && finite(o))
      output.value = o;
  }
}
