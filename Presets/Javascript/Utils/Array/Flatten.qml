import Score 1.0

// Collapses nested lists into a single flat one.
// Depth -1 flattens all the way down; 1 only unwraps the first level.
Script {
  ValueInlet  { id: input; objectName: "In" }
  IntSpinBox  { id: depth; objectName: "Depth"; min: -1; max: 32; init: -1 }
  ValueOutlet { id: output; objectName: "Out" }
  ValueOutlet { id: lengthOut; objectName: "Length" }
  ValueOutlet { id: shapeOut; objectName: "Shape" }

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
  function flat(v, d, out, shape) {
    const l = asList(v);
    for (var i = 0; i < l.length; ++i) {
      const e = l[i];
      const nested = isList(e) || (e !== null && typeof e === "object" && typeof e.x === "number");
      if (nested && d !== 0) {
        flat(e, d - 1, out, shape);
      } else if (nested) {
        out.push(e);
        shape.push(asList(e).length);
      } else {
        out.push(e);
        shape.push(1);
      }
    }
  }

  tick: function(token, state) {
    if (typeof input.value === "undefined")
      return;

    var out = [], shape = [];
    flat(input.value, depth.value, out, shape);
    output.value = out;
    lengthOut.value = out.length;
    shapeOut.value = shape;
  }
}
