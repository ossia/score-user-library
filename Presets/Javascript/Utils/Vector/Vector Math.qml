import Score 1.0

// Vector maths on 2D / 3D / 4D values.
// A and B accept a list, a vec2/vec3/vec4 or a plain number.
// B keeps its last received value, so it can be left unconnected.
Script {
  ValueInlet   { id: inA; objectName: "A" }
  ValueInlet   { id: inB; objectName: "B" }
  LineEdit     { id: constB; objectName: "B (if unconnected)"; text: "1, 1" }
  ComboBox     { id: op; objectName: "Operation"
                 choices: [ "Add", "Subtract", "Multiply", "Divide", "Scale",
                            "Dot", "Cross", "Length", "Normalize", "Distance",
                            "Lerp", "Reflect", "Project", "Angle between",
                            "Negate", "Absolute", "Minimum", "Maximum" ]
                 index: 0 }
  FloatSpinBox { id: amount; objectName: "Amount"; min: -1000000.; max: 1000000.; init: 0.5 }
  ValueOutlet  { id: output; objectName: "Out" }

  property var latchedB: undefined

  function isList(v) {
    return Array.isArray(v)
        || (v !== null && typeof v === "object"
            && typeof v.length === "number" && typeof v.x !== "number");
  }
  function asVec(v) {
    if (v === undefined || v === null) return [];
    if (isList(v)) {
      var r = new Array(v.length);
      for (var i = 0; i < v.length; ++i) r[i] = Number(v[i]) || 0.;
      return r;
    }
    if (typeof v === "object" && typeof v.x === "number") {
      var o = [ v.x, v.y ];
      if (typeof v.z === "number") o.push(v.z);
      if (typeof v.w === "number") o.push(v.w);
      return o;
    }
    const n = Number(v);
    return isFinite(n) ? [ n ] : [];
  }
  function parseVec(text) {
    const parts = text.split(",");
    var r = [];
    for (var i = 0; i < parts.length; ++i) {
      const n = Number(parts[i].trim());
      if (isFinite(n)) r.push(n);
    }
    return r;
  }
  function str(ctl) { return (typeof ctl.value === "string") ? ctl.value : ctl.text; }
  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }

  // Pads both vectors to the same size; a single scalar broadcasts.
  function align(a, b) {
    if (a.length === 1 && b.length > 1) { var pa = []; for (var i = 0; i < b.length; ++i) pa.push(a[0]); return [ pa, b ]; }
    if (b.length === 1 && a.length > 1) { var pb = []; for (var j = 0; j < a.length; ++j) pb.push(b[0]); return [ a, pb ]; }
    const n = Math.max(a.length, b.length);
    var ra = a.slice(), rb = b.slice();
    while (ra.length < n) ra.push(0.);
    while (rb.length < n) rb.push(0.);
    return [ ra, rb ];
  }
  function dot(a, b) { var s = 0.; for (var i = 0; i < a.length; ++i) s += a[i] * b[i]; return s; }
  function len(a) { return Math.sqrt(dot(a, a)); }
  function scaled(a, k) { var r = new Array(a.length); for (var i = 0; i < a.length; ++i) r[i] = a[i] * k; return r; }
  function sub(a, b) { var r = new Array(a.length); for (var i = 0; i < a.length; ++i) r[i] = a[i] - b[i]; return r; }
  function add(a, b) { var r = new Array(a.length); for (var i = 0; i < a.length; ++i) r[i] = a[i] + b[i]; return r; }
  function cross(a, b) {
    // 2D cross is the scalar z of the 3D one — the signed area.
    if (a.length === 2) return a[0] * b[1] - a[1] * b[0];
    return [ a[1] * b[2] - a[2] * b[1],
             a[2] * b[0] - a[0] * b[2],
             a[0] * b[1] - a[1] * b[0] ];
  }

  tick: function(token, state) {
    if (typeof inB.value !== "undefined")
      latchedB = asVec(inB.value);
    if (typeof inA.value === "undefined")
      return;

    const rawA = asVec(inA.value);
    if (rawA.length === 0)
      return;
    const rawB = (latchedB !== undefined && latchedB.length > 0) ? latchedB : parseVec(str(constB));
    const pair = align(rawA, rawB.length > 0 ? rawB : [ 0. ]);
    const a = pair[0], b = pair[1];
    const k = amount.value;

    switch (choice(op)) {
      case "Add":        output.value = add(a, b); break;
      case "Subtract":   output.value = sub(a, b); break;
      case "Multiply": { var m = new Array(a.length); for (var i = 0; i < a.length; ++i) m[i] = a[i] * b[i]; output.value = m; break; }
      case "Divide":   { var d = new Array(a.length); for (var j = 0; j < a.length; ++j) d[j] = (b[j] === 0.) ? 0. : a[j] / b[j]; output.value = d; break; }
      case "Scale":      output.value = scaled(a, k); break;
      case "Dot":        output.value = dot(a, b); break;
      case "Cross":      output.value = cross(a, b); break;
      case "Length":     output.value = len(a); break;
      case "Normalize": { const L = len(a); output.value = (L > 0.) ? scaled(a, 1. / L) : a.slice(); break; }
      case "Distance":   output.value = len(sub(a, b)); break;
      case "Lerp":       output.value = add(a, scaled(sub(b, a), k)); break;
      // r = a - 2 (a.n) n, with n the normalized B
      case "Reflect":   { const L2 = len(b); const nb = (L2 > 0.) ? scaled(b, 1. / L2) : b; output.value = sub(a, scaled(nb, 2. * dot(a, nb))); break; }
      case "Project":   { const bb = dot(b, b); output.value = (bb > 0.) ? scaled(b, dot(a, b) / bb) : scaled(b, 0.); break; }
      case "Angle between": {
        const la = len(a), lb = len(b);
        output.value = (la > 0. && lb > 0.) ? Math.acos(Math.max(-1., Math.min(1., dot(a, b) / (la * lb)))) : 0.;
        break;
      }
      case "Negate":     output.value = scaled(a, -1.); break;
      case "Absolute":  { var ab = new Array(a.length); for (var p = 0; p < a.length; ++p) ab[p] = Math.abs(a[p]); output.value = ab; break; }
      case "Minimum":   { var mn = new Array(a.length); for (var q = 0; q < a.length; ++q) mn[q] = Math.min(a[q], b[q]); output.value = mn; break; }
      case "Maximum":   { var mx = new Array(a.length); for (var s = 0; s < a.length; ++s) mx[s] = Math.max(a[s], b[s]); output.value = mx; break; }
    }
  }
}
