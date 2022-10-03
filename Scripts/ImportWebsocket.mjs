/**
 * This script creates an ossia QML device tree from JSON.
 * It tries to do some guessing on the data types when they are in strings and depending on the key names:
 * - "on", "true" will convert to bool
 * - "123" will convert to int
 * - todo: more
 */

function importWsDevice() 
{
  const res = Score.prompt({
    title: "Input JSON",
    widgets: [ 
      { name:"Name", type: "lineedit", init: "Device" },
      { name:"Host", type: "lineedit", init: "ws://127.0.0.1:8080" },
      { name:"JSON", type: "textfield" },
    ]
  });

  if (res === undefined) {
    return;
  }

  if (res[0].length === 0) {
    return;
  }

  const name = res[0];
  const host = res[1];
  const obj = JSON.parse(res[2]);
  let str = "";

  let ind = 0;
  let indent = () => " ".repeat(ind * 2);
  let setup_value = (k, v) => {
    const t = typeof(v);
    if(t === "string")
    {
      const num = parseFloat(v);
      // Try some special cases
      if(Number.isInteger(num))
      {
        str += indent() + `type: Ossia.Type.Int,\n`;
        str += indent() + `value: ${num},\n`;
        return;
      }
      else if(!isNaN(num))
      {
        str += indent() + `type: Ossia.Type.Float,\n`;
        str += indent() + `value: ${num},\n`;
        return;
      }

      let tolow = t.toLowerCase();
      if(tolow == "on" || tolow == "off" || tolow == "true" || tolow == "false" || tolow == "yes" || tolow == "no")
      {
        str += indent() + `type: Ossia.Type.Boolean,\n`;
        str += indent() + `value: ${num ? 'true' : 'false'},\n`;
        return;
      }
      else if(tolow == "red" || tolow == "green" || tolow == "blue" || tolow == "black" || tolow == "white")
      {
        str += indent() + `type: Ossia.Type.Vec4,\n`;
        str += indent() + `value: "${tolow}",\n`; // FIXME
        return;
      }
      else
      {
        str += indent() + `type: Ossia.Type.String,\n`;
        str += indent() + `value: "${v}",\n`;
        return;
      }
    }
    else if(t === "number")
    {
      const num = v;
      if(Number.isInteger(num))
      {
        str += indent() + `type: Ossia.Type.Int,\n`;
        str += indent() + `value: ${num},\n`;
        return;
      }
      else if(!isNaN(num))
      {
        str += indent() + `type: Ossia.Type.Float,\n`;
        str += indent() + `value: ${num},\n`;
        return;
      }
    }
    else if(t === "array")
    {
      str += indent() + `type: Ossia.Type.List,\n`;
      return;
    }
  };
  let rec = (o) => 
  {
    for(let key in o)
    {
      let val = o[key];
      str += indent() + "{\n"
      ind++;
      {
        str += indent() + `name: "${key}",\n`
        setup_value(key, val);
        if(typeof(val) === "object")
        {
          str += indent() + 'children: [\n';
          ind++;
          rec(val);
          ind--;
          str += indent() + '],\n';
        }
      }
      ind--;
      str += indent() + "},\n";
    }
  }
  rec(obj);
  console.log(str);

  // Wrap the code in something that can be turned into a device
  str = `import Ossia 1.0 as Ossia

Ossia.WebSockets
{
  property string host: "${host}"
  processFromJson: true

  function createTree() {
    return [ ${str} ];
  }
}`;

  Score.createQMLWebSocketDevice("MyDevice", str);
  // const r2 = Score.prompt({
  //   title: "Output code",
  //   widgets: [ 
  //     { name:"Result", type: "textfield", init: str }
  //   ]
  // });
}

export function initialize() {
  // This will be called when the module is loaded.
}

// This is used to register actions in the Scripts menu in score
export const actions = [
 { name: "Protocols/Websockets/Device from JSON"
 , context: ActionContext.Menu
 , action: importWsDevice
 }
]
