.pragma library

function defaultPalette() {
    return ["#ededed", "#171717", "#e85858", "#e59f38", "#f0da68", "#82c75a", "#42b99c", "#4eade3", "#6276de", "#af74d2", "#e484b6", "#87593e"];
}
function palette(colors) {
    var result = defaultPalette();
    if (Array.isArray(colors)) {
        for (var i = 0; i < result.length; ++i) {
            if (typeof colors[i] === "string" && /^#([0-9a-f]{6}|[0-9a-f]{8})$/i.test(colors[i]))
                result[i] = colors[i].toLowerCase();
        }
    }
    return result;
}
function defaults() {
    return {
        version: 1,
        width: 1280,
        height: 720,
        background: "#00000000",
        config: {
            tool: "brush",
            color: "#ffededed",
            width: 12,
            opacity: 1,
            feather: 0,
            filled: false
        },
        palette: defaultPalette(),
        strokes: []
    };
}
function number(value, fallback, min, max) {
    value = Number(value);
    return isFinite(value) ? Math.max(min, Math.min(max, value)) : fallback;
}
function parse(value) {
    var d = typeof value === "string" ? JSON.parse(value) : value;
    if (!d || d.version !== 1 || !Array.isArray(d.strokes))
        throw new Error("Unsupported paint document");
    var config = d.config || {};
    var tools = ["brush", "eraser", "line", "rectangle", "ellipse", "eyedropper"];
    return {
        version: 1,
        width: 1280,
        height: 720,
        background: d.background || "#00000000",
        config: {
            tool: tools.indexOf(config.tool) >= 0 ? config.tool : "brush",
            color: config.color || "#ffededed",
            width: number(config.width, 12, 1, 200),
            opacity: number(config.opacity, 1, 0, 1),
            feather: number(config.feather, 0, 0, 1),
            filled: !!config.filled
        },
        palette: palette(d.palette),
        strokes: d.strokes
    };
}
function append(doc, command) {
    doc.strokes.push(command);
}
function pickColor(doc, color) {
    doc.config.color = color.toString();
    // The sampled alpha already includes paint opacity; do not apply it twice.
    doc.config.opacity = 1;
    doc.config.tool = "brush";
}
function clearCommand() {
    return {
        tool: "clear",
        color: "#ffffffff",
        width: 1,
        opacity: 1,
        filled: false,
        points: [[0, 0]]
    };
}
