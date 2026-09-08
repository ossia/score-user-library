import Score 1.0

// Generates a set of positions: a ring, a line, a grid or a spiral.
// The quickest way to place N lights, N speakers, N sprites without typing
// coordinates by hand.  Outputs a list of [x, y] pairs.
Script {
  IntSpinBox   { id: count; objectName: "Count"; min: 1; max: 4096; init: 12 }
  ComboBox     { id: shape; objectName: "Shape"; choices: [ "Ring", "Line", "Grid", "Spiral" ]; index: 0 }
  FloatSpinBox { id: cx; objectName: "Center X"; min: -1000000.; max: 1000000.; init: 0. }
  FloatSpinBox { id: cy; objectName: "Center Y"; min: -1000000.; max: 1000000.; init: 0. }
  FloatSpinBox { id: sizeX; objectName: "Width / radius"; min: -1000000.; max: 1000000.; init: 1. }
  FloatSpinBox { id: sizeY; objectName: "Height / inner"; min: -1000000.; max: 1000000.; init: 1. }
  FloatSlider  { id: phase; objectName: "Phase (turns)"; min: -1.; max: 1.; init: 0. }
  FloatSlider  { id: arc; objectName: "Arc (turns)"; min: 0.; max: 1.; init: 1. }
  IntSpinBox   { id: columns; objectName: "Columns"; min: 1; max: 512; init: 4 }
  Toggle       { id: flat; objectName: "Flat output"; checked: false }
  ValueOutlet  { id: output; objectName: "Points" }
  ValueOutlet  { id: countOut; objectName: "Count" }

  function choice(ctl) {
    return (typeof ctl.value === "string" && ctl.value.length > 0)
         ? ctl.value : ctl.choices[ctl.index];
  }

  function build() {
    const n = Math.max(1, count.value);
    const x0 = cx.value, y0 = cy.value;
    const sx = sizeX.value, sy = sizeY.value;
    const ph = phase.value * 2. * Math.PI;
    const sweep = arc.value * 2. * Math.PI;
    var pts = [];

    switch (choice(shape)) {
      case "Line": {
        for (var i = 0; i < n; ++i) {
          const u = (n === 1) ? 0.5 : i / (n - 1);
          pts.push([ x0 + (u - 0.5) * sx, y0 + (u - 0.5) * sy ]);
        }
        break;
      }
      case "Grid": {
        const cols = Math.max(1, columns.value);
        const rows = Math.ceil(n / cols);
        for (var k = 0; k < n; ++k) {
          const col = k % cols, row = Math.floor(k / cols);
          const ux = (cols === 1) ? 0.5 : col / (cols - 1);
          const uy = (rows === 1) ? 0.5 : row / (rows - 1);
          pts.push([ x0 + (ux - 0.5) * sx, y0 + (uy - 0.5) * sy ]);
        }
        break;
      }
      case "Spiral": {
        for (var s = 0; s < n; ++s) {
          const u2 = (n === 1) ? 1. : s / (n - 1);
          const r = sy + (sx - sy) * u2;   // "Height / inner" is the inner radius
          const a = ph + sweep * u2 * Math.max(1., n / 4.);
          pts.push([ x0 + r * Math.cos(a), y0 + r * Math.sin(a) ]);
        }
        break;
      }
      default: {
        // A full ring closes on itself, so the last point must not repeat the first.
        const closed = (arc.value >= 1.);
        const div = closed ? n : Math.max(1, n - 1);
        for (var j = 0; j < n; ++j) {
          const a2 = ph + sweep * (j / div);
          pts.push([ x0 + sx * Math.cos(a2), y0 + sy * Math.sin(a2) ]);
        }
        break;
      }
    }
    return pts;
  }

  property string lastSig: ""

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    // Nothing here depends on time: only recompute when a control moved.
    const sig = [ count.value, choice(shape), cx.value, cy.value, sizeX.value,
                  sizeY.value, phase.value, arc.value, columns.value, boolOf(flat) ].join("/");
    if (sig === lastSig)
      return;
    lastSig = sig;

    const pts = build();
    countOut.value = pts.length;
    if (!boolOf(flat)) {
      output.value = pts;
    } else {
      var f = [];
      for (var i = 0; i < pts.length; ++i) f.push(pts[i][0], pts[i][1]);
      output.value = f;
    }
  }
}
