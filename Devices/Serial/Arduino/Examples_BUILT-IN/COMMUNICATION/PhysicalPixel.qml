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

    	function createTree() {
        return [{
			name: "ASCII",
             		type:  Ossia.Type.String,
                    	access: Ossia.Access.Set,
			request: "$val.asAscii", // convert values to ASCII characters
			description: "H for HIGH (led ON), L for Low (led OFF)"  
                 }]; 
	}
}