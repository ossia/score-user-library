import Ossia 1.0 as Ossia

// Note: to run this example you need to run the RoadTrafficServer.js 
// available in the library
Ossia.WebSockets
{
    property string host: "ws://127.0.0.1:8080"
    // Called whenever the Websocket gets connected
    function onConnected() {
        console.log("Connected !")
        return [ ]; // Return type: see onMessage
    }
    
    // Called whenever the Websocket gets disconnected
    function onDisonnected() {
        console.log("Connected !")
        return [ ];  // Return type: see onMessage
    }

    // Called whenever the Websocket server sends us a message
    function onMessage(message) {
        // The message has the format: 
        // {
        //   sensorValue: {
        //     name: "Some place",
        //     value: 123 // the sensor reading, some dummy number which increments
        //   }
        // }
        // 
        // We want to convert it into the following ossia address space 
        // and apply a simple mapping: 
        //
        // /traffic/name: "Some place"
        // /traffic/value: 1.23

        // 1. Parse the json
        var res = JSON.parse(message);

        // 2. For each address to update in the tree, return a message:
        // { address: "/foo/bar", value: ... }
        return [ 
            { address: "/traffic/sensor", value: res["sensorValue"]["value"] / 100. },
            { address: "/traffic/name", value: res["sensorValue"]["name"] }
        ];
    }
    
    // This is used to set-up the device tree with the relevant functions
    function createTree() {
        return [ 
        {
            name: "traffic",
            children: [
                // These two will just display the value from onMessage
                {
                    name: "sensor",
                    type: Ossia.Type.Float
                },
                {
                    name: "name",
                    type: Ossia.Type.String
                },

                // This one is a request to be made to the server
                {
                    name: "change_sensor",
                    type: Ossia.Type.Int, 
                    
                    // For the three following functions, 
                    // the return value is sent to the WS server if not undefined: 
                    
                    // 1. When a message is sent from score
                    request: function (value) {
                        // value is:
                        // { 
                        //   type: "some_type"
                        //   value: ... the actual value ... 
                        // }
                        // e.g. { type: Ossia.Type.Int, value: 123 }
                        // in order to differentiate between ints, floats, etc
                        return JSON.stringify({ sensor: value.value });
                    },

                    // 2. When score listens on a node
                    openListening: function () {
                        console.log("open listening");
                    },

                    // 3. When score stops listening on a node
                    closeListening: function () {
                        console.log("open listening");
                    }
                }
            ]
        }
        ];
    }
}
