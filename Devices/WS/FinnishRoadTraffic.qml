import QtQuick 2.0
import Ossia 1.0 as Ossia

Ossia.WebSockets
{
    property string host: "ws://tie.digitraffic.fi/api/v1/plain-websockets/tmsdata/23001"
    
    // Called whenever the Websocket server sends us a message
    function onMessage(message) {
        var res = JSON.parse(message);
        console.log(res["sensorValue"]["name"] + " ==> " + res["sensorValue"]["sensorValue"])
        return [ 
            { address: "/traffic/sensor", value: res["sensorValue"]["sensorValue"] },
            { address: "/traffic/name", value: res["sensorValue"]["name"] }
        ];
    }
    
    function createTree() {
        return [ 
        {
            name: "traffic",
            children: [
                {
                    name: "sensor",
                    type: Ossia.Type.Float
                },
                {
                    name: "name",
                    type: Ossia.Type.String
                },
                
                // Not useful for this particular API but useful 
                // as an example: 
                {
                    name: "request",
                    type: Ossia.Int, 
                    
                    // For the three following functions, 
                    // the return value is sent to the WS server: 
                    
                    // 1. When a message is sent from score
                    request: function (value) {
                        console.log("request: ", value);
                        return JSON.stringify({ sensor: value })
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
