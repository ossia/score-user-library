// @documentation https://ossia.io/score-docs/processes/javascript/ui-example.html
import Score
import QtQuick
// This is an example script that showcases the available API.
// View the complete documentation at
// https://ossia.io/score-docs/processes/javascript.html
Script {
  ValueInlet { id: in1; objectName: "Value In" }
  ValueOutlet { id: out1; objectName: "Value Out" }
  FloatSlider { id: sl; min: 10; max: 100; objectName: "Control" }

  property real mx: 0
  property real my: 0

  // Called on every tick
  tick: function(token, state) {
    if (typeof in1.value !== 'undefined') {
      console.log(in1.value);
      out1.value = in1.value * mx + sl.value * my;

      // Update the ui:
      console.log("(exec): exec -> ui", { foo: out1.value });
      uiSend({ foo: out1.value });
    }
  }

  // Use these to handle specific execution events if necessary:
  // start: function() { }
  // stop: function() { }
  // pause: function() { }
  // resume: function() { }

  // Handling UI events (from UI to model)
  uiEvent: function(message) {
    mx = message.x;
    my = message.y;
    console.log("(exec): ui -> exec", message);
  }

  property var modelState;
  loadState: function(state) {
    modelState = state;
    // A list of key-value pairs saved along with the score and preserved
    // across executions.
    console.log("exec: loadState", JSON.stringify(modelState));
  }

  stateUpdated: function(k, v) {
    console.log("(exec): onStateElementChanged", k, JSON.stringify(v));
  }
}
