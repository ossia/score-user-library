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
	var splitedMessage = message.split(','); // create an array from the received message   

     	return [{address: "/Red", value: splitedMessage[0]}, // assign values to namespaces in the tree
		{address: "/Green", value: splitedMessage[1]},
		{address: "/Blue", value: splitedMessage[2]}]; 
	}

    	function createTree() {
        return [{
			name: "Red",
            type:  Ossia.Type.Int,
            min: 0,
            max: 255,
            access: Ossia.Access.Get,
			bounding: Ossia.Bounding.Clip,
            repetition_filter: Ossia.Repetitions.Filtered
                },
		{
			name: "Green",
             		type:  Ossia.Type.Int,
		    	min: 0,
                    	max: 255,
                    	access: Ossia.Access.Get,
			bounding: Ossia.Bounding.Clip,
                    	repetition_filter: Ossia.Repetitions.Filtered
                },
		{
			name: "Blue",
             		type:  Ossia.Type.Int,
		    	min: 0,
                    	max: 255,
                    	access: Ossia.Access.Get,
			bounding: Ossia.Bounding.Clip,
                    	repetition_filter: Ossia.Repetitions.Filtered
                 }]; 
	}
}
