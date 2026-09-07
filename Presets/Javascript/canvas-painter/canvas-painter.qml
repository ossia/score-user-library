import Score
import QtQuick
import "PaintModel.js" as Model

Script {
    id: root
    property var doc: Model.defaults()
    property int revision: 0
    property string serialized: ""
    property var pendingCommits: []

    function apply(value) {
        if (value === serialized)
            return;
        try {
            doc = value ? Model.parse(value) : Model.defaults();
            serialized = value || JSON.stringify(doc);
            revision++;
            output.load(doc);
        } catch (error) {
            console.error("canvas-painter: " + error);
        }
    }
    function commit() {
        serialized = JSON.stringify(doc);
        revision++;
        // Process-lifetime transport commits on the GUI command stack. This is
        // independent of ScriptUI lifetime, including when the editor is closed.
        pendingCommits.push(serialized);
        root.commitState("paintDoc", serialized);
        root.uiSend({
            type: "document",
            doc: serialized
        });
    }
    loadState: function (state) {
        apply(state && state.paintDoc);
    }
    stateUpdated: function (key, value) {
        if (key !== "paintDoc")
            return;
        var pending = pendingCommits.indexOf(value);
        if (pending >= 0) {
            pendingCommits.splice(pending, 1);
            return;
        }
        apply(value);
    }
    uiEvent: function (message) {
        if (!message)
            return;
        if (message.type === "document")
            apply(message.doc);
        else if (message.type === "gesture")
            output.receive(message.event);
        else if (message.type === "config") {
            doc.config = message.config;
            revision++;
        } else if (message.type === "hello")
            root.uiSend({
                type: "document",
                doc: JSON.stringify(doc)
            });
    }
    TextureOutlet {
        objectName: "Output"
        item: PaintView {
            id: output
            anchors.fill: parent
            config: {
                root.revision;
                return root.doc.config;
            }
            backgroundColor: {
                root.revision;
                return root.doc.background;
            }
            onGesture: function (event) {
                root.uiSend({
                    type: "gesture",
                    event: event
                });
            }
            onCommitted: function (command) {
                Model.append(root.doc, command);
                root.commit();
            }
            onSampled: function (color) {
                Model.pickColor(root.doc, color);
                root.commit();
            }
        }
    }
}
