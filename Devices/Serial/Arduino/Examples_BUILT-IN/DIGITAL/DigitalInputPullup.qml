/* 
 * This example comunicates with the arduino sketch of the same name   
 * you can find this corresponding example sketch on the arduino website
 * visit: https://www.arduino.cc/en/Tutorial/BuiltInExamples
 * These examples are included in the Arduino IDE 
 * as well as in the Web Editor under Examples/BUILT IN
 * for any issue on the ossia-score side, please report to:
 * https://github.com/OSSIA/score-user-library/issues 
 */

import Ossia 1.0 as Ossia

Ossia.Serial
{
	function openListening(address) {}
    	function closeListening(address) {}

     	function onMessage(message) { // evaluated each time a message is received
        var sensor = false; // make a boolean variable
	
	if (message == 0) { // if 0 is received, set the valriable to false
	        sensor = false;
	        } else {    // otherwise, set it to true;
	        sensor = true;
	        };

     	return [{address: "/sensorVal", value: sensor}]; // assign values to namespaces in the tree
	}

    	function createTree() {
        return [{
			name: "sensorVal",
             		type:  Ossia.Type.Bool,
                    	access: Ossia.Access.Get
                 }]; 
	}
}