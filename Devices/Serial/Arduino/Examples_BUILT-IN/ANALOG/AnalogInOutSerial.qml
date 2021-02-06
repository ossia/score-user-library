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

    property string buffer: "";

    function handleDelimiter(stream, delimiter, execute) {
        var formated = ""; // a variable to store the message in the delimited format

        buffer += stream; // store incomming characters as they arrive

        for(var i = 0; i <= buffer.length; ++i) {
            if(buffer[i] !== delimiter) {
                if(buffer[i] !== undefined) {
                    formated += buffer[i]; }
                // add stored characters one by one to the formated variable if they are defined and different from the delimiter
            } else {
                execute(formated);
                formated = "";
                // if the current character in the buffer is the delimiter, pass "fomated" to the function before emptying the string
            }
        }

        buffer = formated; // reset the buffer to contain the incomplete formated message if any
                           //to be complete with the next incomming characters in the stream
    }

    property var splitedStream : [];

    function onMessage(message, raw) { // evaluated each time a message is received

        handleDelimiter(raw, '\n',
                        function(delimited) {
                            splitedStream = delimited.split(/[\t=]/); // split at the '\t' and '=' characters to seperate each elements
                        }
        )

        return [{address: "/ "+splitedStream[0], value: parseInt(splitedStream[1])}, // assign values to namespaces in the tree
        {address: "/"+splitedStream[2], value: parseInt(splitedStream[3])}];
    }

    function createTree() {
        return [
        {
            name: " sensor ",
            type:  Ossia.Type.Int,
            min: 0,
            max: 1023,
            access: Ossia.Access.Get,
            bounding: Ossia.Bounding.Clip,
            repetition_filter: Ossia.Repetitions.Filtered
        },
        {
            name: " output ",
            type:  Ossia.Type.Int,
            min: 0,
            max: 255,
            access: Ossia.Access.Get,
            bounding: Ossia.Bounding.Clip,
            repetition_filter: Ossia.Repetitions.Filtered
        }
        ];
    }
}
