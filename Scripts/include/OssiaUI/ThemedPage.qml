import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

// Root container for a preset editor: paints the score skin and publishes it as
// the QML `palette`, so every stock control below inherits it and the S* widgets
// in this directory can fall back to it.
//
// Use it as the outermost item of a Score.ScriptUI:
//
//   Score.ScriptUI {
//       anchors.fill: parent
//       S.ThemedPage { anchors.fill: parent; ... }
//   }
Page {
    id: page

    padding: 0

    // Control font propagation: every Control and Label below inherits this, so
    // plain `Label {}` in an editor gets the sharper hinting without having to
    // opt in. (Bare `Text {}` items do not inherit and must set it themselves --
    // the S* widgets in this module all do.)
    font.hintingPreference: Theme.hinting

    background: Rectangle { color: Theme.window }

    palette {
        window: Theme.window
        base: Theme.base
        alternateBase: Theme.altBase
        highlight: Theme.accentFill
        highlightedText: Theme.accentText
        windowText: "#c0c0c0"
        text: Theme.text
        button: Theme.control
        buttonText: Theme.textStrong
        brightText: Theme.textStrong
        toolTipBase: Theme.popup
        toolTipText: "#c0c0c0"
        midlight: Theme.accentFill
        light: Theme.accent
        mid: Theme.divider
        dark: Theme.dark
        shadow: Theme.shadow
        placeholderText: Theme.textMuted
        link: Theme.accent
        accent: Theme.accent
    }
}
