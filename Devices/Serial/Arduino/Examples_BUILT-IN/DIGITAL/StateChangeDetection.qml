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
        var messageAddress; // a string to contain the address
	var messageValue;   // a string to contain the value
	var messageSplited; // an array to contain each part of a splited message 
	
	if (message.length <= 5) { // if the message is les or equal to 5 characters ie: "on\r\n" or "off\r\n", assign the message to "/buttonState"
		messageValue = message;		
		messageAddress = "/buttonState";
	        } else {    // otherwise, split the string "number of button pushes: i" to extract the integer value at the end
		messageSplited = message.split(": ");
	     	messageValue = messageSplited[1];
	     	messageAddress = messageSplited[0]; // the addres will be the same as the index 0 of messageSplited ie: "number of button pushes"
	        };

     		return [{address: messageAddress, value: messageValue}]; // assign values to namespaces in the tree

	}

    	function createTree() {
        return [{
			name: "buttonState",
             		type:  Ossia.Type.String,
                    	access: Ossia.Access.Get
		},
		{
			name: "number of button pushes",
             		type:  Ossia.Type.Int,
                    	access: Ossia.Access.Get
                 }]; 
	}
}