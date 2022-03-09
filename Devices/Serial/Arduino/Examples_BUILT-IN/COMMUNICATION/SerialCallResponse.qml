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

    property var serialInArray: []

    function onRead(message) { // evaluated each time a message is received
		var outArray = []

		if (message == 'A') {
			console.log("awayting request");  
		} else {   
			var ints = new Uint8Array(message);

			ints.forEach((element, index) => {
				serialInArray.push(element);

				if (serialInArray.length == 3) {
					
					outArray = outArray.concat([
						{address: "/firstSensor", value: serialInArray[0]}, // assign values to namespaces in the tree
						{address: "/secondSensor", value: serialInArray[1]},
						{address: "/thirdSensor", value: serialInArray[2]}
					]);

					serialInArray = [];
				}
			})
	
			return outArray;
        }
	}

    	function createTree() {
        return [
            {
			    name: "sendRequest",
            	type:  Ossia.Type.Pulse,
            	access: Ossia.Access.Set,
	    	},
		    {
			    name: "firstSensor",
            	type:  Ossia.Type.Int,
            	access: Ossia.Access.Get,
	    		min: 0,
		    	max: 255,
			    bounding: Ossia.Bounding.Clip,
			    repetition_filter: Ossia.Repetitions.Filtered
		    },
		    {
			    name: "secondSensor",
            	type:  Ossia.Type.Int,
            	access: Ossia.Access.Get,
	    		min: 0,
		    	max: 255,
			    bounding: Ossia.Bounding.Clip,
			    repetition_filter: Ossia.Repetitions.Filtered
		    },
		    {
			    name: "thirdSensor",
            	type:  Ossia.Type.Int,
                access: Ossia.Access.Get,
		    	min: 0,
			    max: 255,
			    bounding: Ossia.Bounding.Clip,
			    repetition_filter: Ossia.Repetitions.Filtered
            }
        ]; 
	}
}