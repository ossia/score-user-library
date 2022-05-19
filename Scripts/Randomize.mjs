
// This function randomizes all the parameters of a process
function randomizeControls(process) {
  // First count the number of inlets 
  const N = Score.inlets(process);
  console.log(process);
  console.log(N);
  if(N === undefined)
    return;

  // For each inlet:
  for (let i = 0; i < N; ++i) {
    // Get it
    const inl = Score.inlet(process, i);

    // Get what its type is ("Float", "Int", "String", etc)
    const val_type = Score.valueType(inl);

    if (val_type === "Float" || val_type === "Int") {
      // In that case check the range of the control
      const min = Score.min(inl);
      const max = Score.max(inl);

      // Generate a value in that range
      const val = min + Math.random() * (max - min);

      // Apply it to the control
      Score.setValue(inl, val);
    } else if (val_type === "String") {
      // If the input is a string it's likely an enumeration
      const values = Score.enumValues(inl); // ["Sin", "Square", ...]
      if(values.length > 0)
      {
        // Pick an enum value at random
        const val = Math.round(Math.random() * (values.length - 1));

        // Apply it
        Score.setValue(inl, values[val]);
      }
    }
  }
}

// This function creates a random automation.
// Automations are defined like this: 
//   [
//    [0, 0.2],
//    [0.5, 0.7],
//    [1., 0.4]
//   ]
// will make a curve that starts at 0.2, goes up to 0.7 at the half of the curve, 
// and reaches 0.4 at the end.
// The y values should be between 0 and 1, 
// the x values can go beyond 1 (to write past the default length of the automation).
function randomizeAutomation(autom) 
{
  let arr = [];
  for (let i = 0; i <= 10; i++) {
    let x = i / 10;
    let y = Math.random();

    arr.push([x, y]);
  }
  Score.setCurvePoints(autom, arr);
}

// This function creates a random series of steps for the step sequencer.
function randomizeStep(step) {
  let arr = [];
  for (let i = 0; i <= 10; i++) {
    arr.push(Math.random());
  }
  Score.setSteps(step, arr);
}

function randomize() 
{
  for(const obj of Score.selectedObjects())
  {
    console.log(obj.objectName );
    if(obj.objectName == "Automation") 
      randomizeAutomation(obj);      
    else if(obj.objectName == "Step")
      randomizeStep(obj);      
    else
      randomizeControls(obj);
  }
}

export function initialize() {
  // This will be called when the module is loaded.
}

// This is used to register actions in the Scripts menu in score
export const actions = [
 { name: "Effects/Randomize"
 , context: ActionContext.Menu
 , shortcut: "Alt+A, Alt+R"
 , action: randomize
 }
]
