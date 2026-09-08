import Score 1.0

// [toggle] / T flip-flop — every bang inverts the state.
Script {
  Impulse     { id: bang; objectName: "Bang"; onImpulse: pending++ }
  Toggle      { id: initial; objectName: "Initial state"; checked: false }
  Impulse     { id: reset; objectName: "Reset"; onImpulse: doReset = true }
  ValueOutlet { id: output; objectName: "State" }
  ValueOutlet { id: onRise; objectName: "On true" }
  ValueOutlet { id: onFall; objectName: "On false" }

  property bool started: false
  property bool flag: false
  property int pending: 0
  property bool doReset: false

  // A control port carries no value until the model pushes one: until then,
  // fall back to the state the QML declares.
  function boolOf(ctl) { return (typeof ctl.value === "undefined") ? ctl.checked : !!ctl.value; }

  tick: function(token, state) {
    if (!started || doReset) {
      started = true; doReset = false; pending = 0;
      flag = boolOf(initial);
      output.value = flag;
    }

    while (pending > 0) {
      pending--;
      flag = !flag;
      output.value = flag;
      if (flag) onRise.value = true; else onFall.value = true;
    }
  }
}
