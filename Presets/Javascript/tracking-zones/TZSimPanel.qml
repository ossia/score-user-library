import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "UiUtil.js" as U
import OssiaUI as S

// Simulator (dummies, random walkers) and recorder / playback of tracking data.
Item {
    id: panel
    property var owner

    component NumBox: TextField {
        id: nb
        property real value: 0
        property int decimals: 1
        signal edited(real v)
        property real def: NaN
        implicitWidth: 52; implicitHeight: 22; font.pixelSize: 10; topPadding: 2; bottomPadding: 2; selectByMouse: true
        text: U.fmt(value, decimals)
        function rebind() { text = Qt.binding(function () { return U.fmt(value, decimals); }); }
        S.SNumDrag { field: nb; value: nb.value; decimals: nb.decimals; onDragged: function (v) { nb.text = U.fmt(v, nb.decimals); } onCommitted: function (v) { nb.edited(v); nb.rebind(); } onReset: { if (!isNaN(nb.def)) { nb.edited(nb.def); nb.rebind(); } } }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        // ---- simulator ----
        GroupBox {
            title: "Simulation"
            Layout.fillHeight: true; Layout.preferredWidth: 430
            font.pixelSize: 11
            clip: true
            ColumnLayout {
                anchors.fill: parent; spacing: 4
                RowLayout {
                    S.SCheck { text: "Enabled"; checked: owner.simEnabled; onToggled: owner.simEnabled = checked; ToolTip.visible: hovered; ToolTip.text: "Generate virtual entities as source 5. Requires the Simulation process control to be enabled." }
                    Label { font.pixelSize: 11; color: palette.placeholderText; text: { owner.simVersion; return owner.simEntities.length + " entities"; } }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: "Dummy tool"; implicitHeight: 22; font.pixelSize: 11
                        palette.button: owner.tool === "sim" ? S.Theme.accentFill : S.Theme.control
                        onClicked: owner.tool = owner.tool === "sim" ? "select" : "sim"
                        ToolTip.visible: hovered; ToolTip.text: "Click a view to add a dummy, drag to move it, right-click to remove it"
                    }
                }
                RowLayout {
                    Button { text: "+1 walker"; implicitHeight: 22; font.pixelSize: 11; onClicked: owner.addWalkers(1) }
                    Button { text: "+5 walkers"; implicitHeight: 22; font.pixelSize: 11; onClicked: owner.addWalkers(5) }
                    Button { text: "+20 walkers"; implicitHeight: 22; font.pixelSize: 11; onClicked: owner.addWalkers(20) }
                    Button { text: "Clear"; implicitHeight: 22; font.pixelSize: 11; onClicked: owner.clearSim() }
                }
                RowLayout {
                    Label { text: "Speed"; font.pixelSize: 11; Layout.preferredWidth: 44 }
                    S.SSlider { from: 0; to: 4; defaultValue: 1; value: owner.simSpeed; Layout.fillWidth: true; onMoved: owner.simSpeed = value }
                    Label { text: U.fmt(owner.simSpeed, 1) + " m/s"; font.pixelSize: 11; Layout.preferredWidth: 52 }
                }
                RowLayout {
                    Label { text: "Noise"; font.pixelSize: 11; Layout.preferredWidth: 44 }
                    S.SSlider { from: 0; to: 2; defaultValue: 0.2; value: owner.simNoise; Layout.fillWidth: true; onMoved: owner.simNoise = value }
                    Label { text: U.fmt(owner.simNoise, 2); font.pixelSize: 11; Layout.preferredWidth: 52 }
                }
                RowLayout {
                    Label { text: "Bounds"; font.pixelSize: 11; Layout.preferredWidth: 44; ToolTip.visible: bh.hovered; ToolTip.text: "Walkers stay inside this rectangle (dashed in the 2D view)"; HoverHandler { id: bh } }
                    Label { text: "centre"; font.pixelSize: 10; color: palette.placeholderText }
                    NumBox { def: 0; value: { owner.docVersion; return owner.simBounds.x; } onEdited: function (v) { var b = owner.simBounds; b.x = v; owner.simBounds = b; owner.docVersion++; } }
                    NumBox { def: 0; value: { owner.docVersion; return owner.simBounds.y; } onEdited: function (v) { var b = owner.simBounds; b.y = v; owner.simBounds = b; owner.docVersion++; } }
                    Label { text: "size"; font.pixelSize: 10; color: palette.placeholderText }
                    NumBox { def: 8; value: { owner.docVersion; return owner.simBounds.w; } onEdited: function (v) { var b = owner.simBounds; b.w = Math.max(0.5, v); owner.simBounds = b; owner.docVersion++; } }
                    NumBox { def: 6; value: { owner.docVersion; return owner.simBounds.h; } onEdited: function (v) { var b = owner.simBounds; b.h = Math.max(0.5, v); owner.simBounds = b; owner.docVersion++; } }
                    Label { text: "m"; font.pixelSize: 10; color: palette.placeholderText }
                    Item { Layout.fillWidth: true }
                }
                Item { Layout.fillHeight: true }
            }
        }

        // ---- recorder / playback ----
        GroupBox {
            title: "Record & playback"
            Layout.fillHeight: true; Layout.fillWidth: true
            font.pixelSize: 11
            clip: true
            ColumnLayout {
                anchors.fill: parent; spacing: 4
                RowLayout {
                    Button { text: owner.recording ? "Stop recording" : "● Record"; implicitHeight: 22; font.pixelSize: 11; palette.button: owner.recording ? S.Theme.danger : S.Theme.control; onClicked: owner.recording ? owner.stopRecording() : owner.startRecording(); ToolTip.visible: hovered; ToolTip.text: "Record calibrated entities from all sources. Save as JSON in " + owner.recordingsDir + "." }
                    Label { text: owner.recording && owner.snapshot ? owner.snapshot.recordingFrames + " frames" : ""; font.pixelSize: 11; color: palette.placeholderText }
                    Item { Layout.fillWidth: true }
                    Button { text: "Load recording…"; implicitHeight: 22; font.pixelSize: 11; onClicked: Util.openFileDialog("Load recording", "Recordings (*.json)", owner.recordingsDir, function(path) { if (panel && path) panel.owner.loadRecording(path); }); ToolTip.visible: hovered; ToolTip.text: "Load a JSON recording. Playback replaces live input with recorded entities." }
                    Button { text: "Load last"; enabled: owner.lastRecordingPath.length > 0; implicitHeight: 22; font.pixelSize: 11; onClicked: owner.loadRecording(owner.lastRecordingPath); ToolTip.visible: hovered; ToolTip.text: "Load the last saved recording. Playback replaces live input with recorded entities." }
                }
                RowLayout {
                    visible: owner.playbackInfo !== null
                    Button { text: owner.playbackInfo && owner.playbackInfo.playing ? "Pause" : "Play"; implicitWidth: 52; implicitHeight: 22; onClicked: owner.playbackControl(owner.playbackInfo && owner.playbackInfo.playing ? "pause" : "play"); ToolTip.visible: hovered; ToolTip.text: "Playback replaces live input with recorded entities." }
                    Button { text: "Stop"; implicitWidth: 44; implicitHeight: 22; onClicked: owner.playbackControl("stop") }
                    S.SSlider {
                        id: scrub; Layout.fillWidth: true; from: 0; to: owner.playbackInfo ? Math.max(0.001, owner.playbackInfo.duration) : 1
                        value: owner.playbackInfo && !pressed ? owner.playbackInfo.pos : value
                        onMoved: owner.playbackControl("seek", value)
                    }
                    Label { text: owner.playbackInfo ? U.fmtTime(owner.playbackInfo.pos) + " / " + U.fmtTime(owner.playbackInfo.duration) : ""; font.pixelSize: 11; Layout.preferredWidth: 90 }
                    S.SCheck { text: "Loop"; checked: owner.playbackInfo ? owner.playbackInfo.loop : true; onToggled: owner.playbackControl("loop", checked) }
                    S.SCombo { implicitWidth: 64; model: ["0.25×", "0.5×", "1×", "2×", "4×"]; currentIndex: 2; onActivated: function (i) { owner.playbackControl("speed", [0.25, 0.5, 1, 2, 4][i]); } }
                    Button { text: "Close"; implicitHeight: 22; font.pixelSize: 11; onClicked: owner.playbackControl("close") }
                }
                Item { Layout.fillHeight: true }
            }
        }
    }
}
