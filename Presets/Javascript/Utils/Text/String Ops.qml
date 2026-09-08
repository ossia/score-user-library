import Score 1.0

// The usual string operations, one node.
// "A" and "B" are the arguments some operations need: the separator to split
// on, the text to search for, the replacement, a length...
Script {
  ValueInlet  { id: input; objectName: "In" }
  ComboBox    { id: op; objectName: "Operation"
                choices: [ "Upper case", "Lower case", "Trim", "Length", "Reverse",
                           "Split", "Join", "Replace", "Slice", "Pad start", "Pad end",
                           "Contains", "Starts with", "Ends with", "Index of", "Repeat" ]
                index: 0 }
  LineEdit    { id: argA; objectName: "A"; text: "," }
  LineEdit    { id: argB; objectName: "B"; text: "" }
  ValueOutlet { id: output; objectName: "Out" }

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function asList(v) {
    if (v === undefined || v === null) return [];
    if (isList(v)) { var r = new Array(v.length); for (var i = 0; i < v.length; ++i) r[i] = v[i]; return r; }
    return [ v ];
  }
  function str(ctl) { return (typeof ctl.value === "string") ? ctl.value : ctl.text; }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }
  function text(v) {
    if (isList(v)) {
      var parts = [];
      for (var i = 0; i < v.length; ++i) parts.push(text(v[i]));
      return parts.join(" ");
    }
    return (v === undefined || v === null) ? "" : String(v);
  }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    const v = input.value;
    const a = str(argA), b = str(argB);
    const name = choice(op);

    // Join is the only one that reads the input as a list rather than as text.
    if (name === "Join") {
      const l = asList(v);
      var parts = new Array(l.length);
      for (var i = 0; i < l.length; ++i) parts[i] = text(l[i]);
      output.value = parts.join(a);
      return;
    }

    const s = text(v);
    switch (name) {
      case "Lower case":  output.value = s.toLowerCase(); break;
      case "Trim":        output.value = s.trim(); break;
      case "Length":      output.value = s.length; break;
      case "Reverse":     output.value = s.split("").reverse().join(""); break;
      case "Split":       output.value = (a.length > 0) ? s.split(a) : s.split(""); break;
      case "Replace":     output.value = (a.length > 0) ? s.split(a).join(b) : s; break;
      case "Slice": {
        const from = parseInt(a, 10);
        const to = (b.trim().length > 0) ? parseInt(b, 10) : undefined;
        output.value = s.slice(isFinite(from) ? from : 0, to);
        break;
      }
      case "Pad start": {
        const n = parseInt(a, 10) || 0;
        const fill = (b.length > 0) ? b : " ";
        var p = s;
        while (p.length < n) p = fill + p;
        output.value = p;
        break;
      }
      case "Pad end": {
        const n2 = parseInt(a, 10) || 0;
        const fill2 = (b.length > 0) ? b : " ";
        var q = s;
        while (q.length < n2) q = q + fill2;
        output.value = q;
        break;
      }
      case "Contains":    output.value = s.indexOf(a) >= 0; break;
      case "Starts with": output.value = s.lastIndexOf(a, 0) === 0; break;
      case "Ends with":   output.value = a.length === 0 || s.slice(-a.length) === a; break;
      case "Index of":    output.value = s.indexOf(a); break;
      case "Repeat": {
        const n3 = Math.max(0, parseInt(a, 10) || 0);
        var acc = "";
        for (var k = 0; k < n3; ++k) acc += s;
        output.value = acc;
        break;
      }
      default:            output.value = s.toUpperCase(); break;
    }
  }
}
