import Score 1.0

// Reads and writes JSON, and digs into a structure with a path.
//   Parse     : text -> value
//   Stringify : value -> text
//   Get       : follow "Path" inside the incoming value (parsing it first if
//               it is text).  Path looks like  a.b[0].c
Script {
  ValueInlet  { id: input; objectName: "In" }
  ComboBox    { id: mode; objectName: "Mode"; choices: [ "Parse", "Stringify", "Get" ]; index: 0 }
  LineEdit    { id: path; objectName: "Path"; text: "" }
  Toggle      { id: pretty; objectName: "Pretty"; checked: false }
  ValueOutlet { id: output; objectName: "Out" }
  ValueOutlet { id: okOut; objectName: "Valid" }

  function str(ctl) { return (typeof ctl.value === "string") ? ctl.value : ctl.text; }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }
  // "a.b[0].c" -> [ "a", "b", 0, "c" ]
  function parsePath(p) {
    var steps = [];
    const parts = p.split(".");
    for (var i = 0; i < parts.length; ++i) {
      var seg = parts[i];
      if (seg.length === 0) continue;
      const br = seg.indexOf("[");
      if (br < 0) { steps.push(seg); continue; }
      if (br > 0) steps.push(seg.slice(0, br));
      var rest = seg.slice(br);
      while (rest.length > 0) {
        const close = rest.indexOf("]");
        if (close < 0) break;
        const n = parseInt(rest.slice(1, close), 10);
        if (isFinite(n)) steps.push(n);
        rest = rest.slice(close + 1);
      }
    }
    return steps;
  }

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const v = input.value;
    const m = choice(mode);

    if (m === "Stringify") {
      try {
        output.value = JSON.stringify(v, null, boolOf(pretty) ? 2 : 0);
        okOut.value = true;
      } catch (e) {
        okOut.value = false;
      }
      return;
    }

    var parsed = v;
    if (typeof v === "string") {
      try { parsed = JSON.parse(v); okOut.value = true; }
      catch (e) { okOut.value = false; return; }
    } else {
      okOut.value = true;
    }

    if (m === "Parse") {
      output.value = parsed;
      return;
    }

    var cur = parsed;
    const steps = parsePath(str(path));
    for (var i = 0; i < steps.length; ++i) {
      if (cur === null || cur === undefined) { okOut.value = false; return; }
      cur = cur[steps[i]];
    }
    if (cur === undefined) { okOut.value = false; return; }
    output.value = cur;
  }
}
