import Score
import QtQuick
import "PanelModel.js" as Model

Script {
    id: root
    ValueInlet { id: stateCommand; objectName: "State" }
    ValueOutlet { id: stateOutput; objectName: "State" }
    ValueOutlet { id: actionOutput; objectName: "Action" }
    TextureOutlet {
        objectName: "Output"
        item: PanelSurface {
            anchors.fill: parent
            doc: root.doc
            stateId: root.activeState
            onActivated: function(objectId) { root.activate(objectId); }
        }
    }
    property var doc: Model.defaultDoc()
    property string activeState: doc.initial
    property var history: []
    property var pendingActions: []
    property string lastCommand: ""
    property bool stateDirty: true

    function notify() {
        var s = Model.stateById(doc, activeState);
        root.uiSend({ type: "runtime", state: activeState, name: s ? s.name : "", canBack: history.length > 0 });
    }
    function replaceDoc(value, reset) {
        try {
            var replacement = Model.parse(value);
            if (!reset && JSON.stringify(doc) === JSON.stringify(replacement)) return;
            doc = replacement;
            history = history.filter(function(id) { return !!Model.stateById(doc, id); });
            if (reset || !Model.stateById(doc, activeState)) {
                activeState = doc.initial; history = []; stateDirty = true;
            }
            notify();
        } catch (e) { root.uiSend({ type: "error", message: "Panel document: " + e }); }
    }
    function activate(objectId) { command({ activate: objectId }); }
    // State IDs are unambiguous. A unique state name is also accepted.
    // {state: "s2"}, {command: "back"}, {command: "reset"}, {activate: "o4"}.
    function command(value) {
        var result = Model.transition(doc, activeState, history, value);
        history = result.history;
        if (activeState !== result.state) { activeState = result.state; stateDirty = true; }
        if (result.event) {
            var queue = pendingActions.slice(); queue.push(result.event); pendingActions = queue;
            root.uiSend({ type: "action", event: result.event });
        }
        if (result.error) root.uiSend({ type: "error", message: result.error });
        notify();
    }
    loadState: function(state) {
        replaceDoc(state && state.panelDoc ? state.panelDoc : Model.defaultDoc(), true);
    }
    stateUpdated: function(key, value) { if (key === "panelDoc") replaceDoc(value, false); }
    uiEvent: function(message) {
        if (!message) return;
        if (message.type === "doc") replaceDoc(message.doc, false);
        else if (message.type === "activate") activate(message.id);
        else if (message.type === "back") command({ command: "back" });
        else if (message.type === "reset") command({ command: "reset" });
        else if (message.type === "status") notify();
    }
    start: function() {
        history = []; pendingActions = []; lastCommand = "";
        activeState = doc.initial; stateDirty = true; notify();
    }
    tick: function(token, state) {
        var values = stateCommand.values;
        if (values && values.length) {
            for (var i = 0; i < values.length; ++i) command(values[i].value);
            lastCommand = JSON.stringify(stateCommand.value);
        } else if (stateCommand.value !== undefined && stateCommand.value !== null) {
            var key = JSON.stringify(stateCommand.value);
            if (key !== lastCommand) { lastCommand = key; command(stateCommand.value); }
        }
        if (stateDirty) { stateOutput.value = activeState; stateDirty = false; }
        for (var j = 0; j < pendingActions.length; ++j) actionOutput.addValue(0, pendingActions[j]);
        if (pendingActions.length) pendingActions = [];
    }
}
