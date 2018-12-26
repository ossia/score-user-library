/* 
 * This example comunicates with the arduino sketch of the same name   
 * you can find this corresponding example sketch on the arduino website
 * visit: https://www.arduino.cc/en/Tutorial/BuiltInExamples
 * These examples are included in the Arduino IDE 
 * as well as in the Web Editor under Examples/BUILT IN
 * for any issue on the ossia-score side, please report to:
 * https://github.com/OSSIA/score-user-library/issues 
 */

import QtQuick 2.0
import Ossia 1.0 as Ossia

Ossia.Serial
{
	function openListening(address) {}
    	function closeListening(address) {}

     	function onMessage(message) { // evaluated each time a message is received
        var tabSplited = message.split('\t'); // split at the "tab" to seperate sensor and output strings
	var sensorSplited = tabSplited[0].split("= "); // split again both strings to extract the integer values
	var outputSplited = tabSplited[1].split("= ");  

        return [{address: "/sensor", value: sensorSplited[1]}, // assign values to namespaces in the tree
   		{address: "/output", value: outputSplited[1]}]; 

	}

    	function createTree() {
        return [{
			name: "sensor",
             		type:  Ossia.Type.Int,
			min: 0,
			max: 1023,
                    	access: Ossia.Access.Get,
			bounding: Ossia.Bounding.Clip,
                    	repetition_filter: Ossia.Repetitions.Filtered
		},
		{
			name: "output",
             		type:  Ossia.Type.Int,
			min: 0,
			max: 255,
                    	access: Ossia.Access.Get,
			bounding: Ossia.Bounding.Clip,
                    	repetition_filter: Ossia.Repetitions.Filtered
                 }]; 
	}
}