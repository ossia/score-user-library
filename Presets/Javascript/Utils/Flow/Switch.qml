import Score 1.0

// [switch] — several inputs, one output: only the selected inlet is forwarded.
// Input 0 mutes everything.
Script {
  IntSlider   { id: sel; objectName: "Input"; min: 0; max: 4; init: 1 }
  ValueInlet  { id: in1; objectName: "In 1" }
  ValueInlet  { id: in2; objectName: "In 2" }
  ValueInlet  { id: in3; objectName: "In 3" }
  ValueInlet  { id: in4; objectName: "In 4" }
  ValueOutlet { id: output; objectName: "Out" }

  tick: function(token, state) {
    const ins = [ in1, in2, in3, in4 ];
    const k = sel.value - 1;
    if (k < 0 || k >= ins.length)
      return;
    if (typeof ins[k].value !== "undefined")
      output.value = ins[k].value;
  }
}
