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
	var splitedMessage = message.split("in, "); // create an array from the received message   
	  

     	return [{address: "/in", value: splitedMessage[0]}, // assign values to namespaces in the tree 
		{address: "/cm", value: parseInt(splitedMessage[1])}]; // extract the integer value from the second part of the splited message 
	}

    	function createTree() {
        return [{
			name: "in",
             		type:  Ossia.Type.Int,
                    	access: Ossia.Access.Get,
                    	repetition_filter: Ossia.Repetitions.Filtered
                },
		{
			name: "cm",
             		type:  Ossia.Type.Int,
                    	access: Ossia.Access.Get,
                    	repetition_filter: Ossia.Repetitions.Filtered
                }]; 
	}
}