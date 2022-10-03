/**
 * To try: 
 * - Install node.js
 * - npm install ws
 * - node RoadTrafficServer.js
 * 
 * This server has the following API:
 * - It will regularly send the message to its clients:
 * {
 *   sensorValue: {
 *     name: "Some place",
 *     value: 123 // the sensor reading, some dummy number which increments
 *   }
 * }
 * 
 * - It reacts to the following message:
 * { sensor: X } // X can be between 0 and 3
 * 
 * and will change the sensor being updated appropriately.
 * 
 */
const ws = require("ws");

const wss = new ws.WebSocketServer({ port: 8080 });
const clamp = (num, min, max) => Math.min(Math.max(num, min), max);

let sensors = [
    { name: "Hôtel de ville", value: 0 },
    { name: "St. Catherine", value: 140 },
    { name: "Place de la Bourse", value: 7 },
    { name: "Cours de la Libération", value: 15 },
];

let currentSensor = {
    sensorValue: sensors[0]
};

wss.on('connection', function connection(ws) {
  ws.on('message', function message(data) {
    console.log('received: %s', data);

    const rq = JSON.parse(data);
    const idx = parseInt(rq.sensor);

    currentSensor = {
        sensorValue: sensors[clamp(idx, 0, 3)]
    };

    ws.send(JSON.stringify(currentSensor));
  });
  
  setInterval(() => {
    currentSensor.sensorValue.value ++;
    ws.send(JSON.stringify(currentSensor));
  }, 100);
});