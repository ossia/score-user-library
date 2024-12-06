/**
 * This script creates an OSCQuery tree from a given device.
 */

function getOSCQuery() 
{
  const res = Score.prompt({
    title: "Input device",
    widgets: [ 
      { name:"Name", type: "lineedit", init: "device name (as in device explorer)" }
    ]
  });

  if (res === undefined) {
    return;
  }

  if (res[0].length === 0) {
    return;
  }

  const name = res[0];
  const result = Score.deviceToOSCQuery(name);
  
  Score.prompt({
    title: "Input device",
    widgets: [ 
      { name:"JSON", type: "textfield", init: result },
    ]
  });
}

export function initialize() {
  // This will be called when the module is loaded.
}

// This is used to register actions in the Scripts menu in score
export const actions = [
 { name: "Protocols/Device to OSCQuery"
 , context: ActionContext.Menu
 , action: getOSCQuery
 }
]
