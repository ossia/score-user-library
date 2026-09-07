import QtQuick
import QtCanvas2D

Item {
    id: root
    property color fillColor: "transparent"
    signal colorSampled(color color)
    clip: true

    property var _commands: []
    property var _active: null
    property var _removedGroups: []
    property int _sampleGeneration: 0
    property var _pendingSample: null

    onFillColorChanged: cancelSample()
    onWidthChanged: cancelSample()
    onHeightChanged: cancelSample()

    function bounded(value, fallback, low, high) {
        value = Number(value);
        return isFinite(value) ? Math.max(low, Math.min(high, value)) : fallback;
    }
    function point(x, y) {
        return [bounded(x, 0, 0, 1280), bounded(y, 0, 0, 720)];
    }
    function samePoint(a, b) {
        return a[0] === b[0] && a[1] === b[1];
    }
    function hexByte(value) {
        return ("0" + Math.round(value * 255).toString(16)).slice(-2);
    }
    function style(config) {
        config = config || {};
        var tool = config.tool;
        if (tool !== "eraser" && tool !== "line" && tool !== "rectangle" && tool !== "ellipse" && tool !== "clear")
            tool = "brush";
        var color;
        try {
            color = Qt.color(config.color === undefined ? "#ededed" : String(config.color));
        } catch (error) {
            color = Qt.rgba(1, 1, 1, 1);
        }
        if (!color || !color.valid)
            color = Qt.rgba(1, 1, 1, 1);
        return {
            tool: tool,
            color: "#" + hexByte(color.a) + hexByte(color.r) + hexByte(color.g) + hexByte(color.b),
            width: bounded(config.width === undefined ? 8 : config.width, 8, 1, 200),
            opacity: bounded(config.opacity === undefined ? 1 : config.opacity, 1, 0, 1),
            feather: bounded(config.feather === undefined ? 0 : config.feather, 0, 0, 1),
            filled: !!config.filled,
            points: []
        };
    }
    function retained(command, group, key) {
        return {
            command: command,
            key: key,
            group: group,
            path: null,
            pointCount: 0,
            dirty: true,
            featherLayers: null
        };
    }
    function loadCommands(commands) {
        cancelSample();
        _active = null;
        commands = commands || [];
        var next = [];
        var common = true;
        for (var i = 0; i < commands.length; ++i) {
            var source = commands[i] || {};
            var command = style(source);
            var points = source.points || [];
            for (var j = 0; j < points.length; ++j) {
                var xy = points[j];
                if (xy && xy.length === 2)
                    command.points.push(point(xy[0], xy[1]));
            }
            var key = JSON.stringify(command);
            if (common && i < _commands.length && _commands[i].key === key) {
                next.push(_commands[i]);
            } else {
                common = false;
                if (i < _commands.length)
                    _removedGroups.push(i);
                next.push(retained(command, i, key));
            }
        }
        for (var k = commands.length; k < _commands.length; ++k)
            _removedGroups.push(k);
        _commands = next;
        ink.requestPaint();
    }
    function beginStroke(config, x, y) {
        cancelSample();
        var command = style(config);
        command.points.push(point(x, y));
        // Live paths have no GPU cache group; committed paths retain their geometry.
        _active = retained(command, -1);
        ink.requestPaint();
    }
    function extendStroke(x, y) {
        if (!_active)
            return;
        var points = _active.command.points;
        var p = point(x, y);
        if (samePoint(p, points[points.length - 1]))
            return;
        cancelSample();
        var tool = _active.command.tool;
        if (tool === "brush" || tool === "eraser" || points.length === 1)
            points.push(p);
        else
            points[points.length - 1] = p;
        _active.dirty = true;
        ink.requestPaint();
    }
    function endStroke() {
        if (!_active)
            return {};
        cancelSample();
        _active.group = _commands.length;
        _active.key = JSON.stringify(_active.command);
        // Callers own the returned document data, not the retained render model.
        var result = JSON.parse(_active.key);
        _commands.push(_active);
        _active = null;
        ink.requestPaint();
        return result;
    }
    function cancelStroke() {
        cancelSample();
        if (!_active)
            return;
        _active = null;
        ink.requestPaint();
    }
    function cancelSample() {
        ++_sampleGeneration;
        _pendingSample = null;
    }
    function sampleColor(x, y) {
        cancelSample();
        _pendingSample = {
            point: point(x, y),
            generation: _sampleGeneration
        };
        // The paint handler schedules the grab only after recording the latest ink.
        ink.requestPaint();
    }
    function grabSample() {
        var sample = _pendingSample;
        if (!sample || !ink.available || width <= 0 || height <= 0)
            return;
        // grabToImage's targetSize is logical: Qt multiplies it by the window DPR.
        // The fixed document-sized Canvas2D uses exactly the same physical size.
        var pixels = ink.effectiveColorBufferSize;
        if (pixels.width <= 0 || pixels.height <= 0)
            return;
        _pendingSample = null;
        var x = Math.min(pixels.width - 1, Math.floor(sample.point[0] * pixels.width / 1280));
        var y = Math.min(pixels.height - 1, Math.floor(sample.point[1] * pixels.height / 720));
        // Record a full frame for the grab as well: Canvas2D is not an accumulating canvas.
        ink.requestPaint();
        root.grabToImage(function (result) {
            if (sample.generation !== root._sampleGeneration)
                return;
            root.colorSampled(Util.imagePixelColor(result.image, x, y));
        }, Qt.size(1280, 720));
    }
    function isDot(points) {
        return points.length === 1 || (points.length === 2 && samePoint(points[0], points[1]));
    }
    function updatePath(ctx, entry) {
        if (!entry.dirty)
            return;
        var command = entry.command;
        var points = command.points;
        if (!entry.path)
            entry.path = ctx.createPath2D();
        var path = entry.path;
        var freehand = command.tool === "brush" || command.tool === "eraser";
        // After the initial disk becomes a polyline, append only new segments.
        if (freehand && entry.pointCount >= 2 && !isDot(points)) {
            for (var i = entry.pointCount; i < points.length; ++i)
                path.lineTo(points[i][0], points[i][1]);
        } else {
            path.clear();
            if (points.length) {
                var first = points[0];
                var last = points[points.length - 1];
                if (isDot(points)) {
                    path.circle(first[0], first[1], command.width / 2);
                } else if (command.tool === "rectangle" || command.tool === "ellipse") {
                    var x = Math.min(first[0], last[0]);
                    var y = Math.min(first[1], last[1]);
                    var w = Math.abs(last[0] - first[0]);
                    var h = Math.abs(last[1] - first[1]);
                    if (command.tool === "rectangle")
                        path.rect(x, y, w, h);
                    else
                        path.ellipseRect(x, y, w, h);
                } else {
                    path.moveTo(first[0], first[1]);
                    for (var j = 1; j < points.length; ++j)
                        path.lineTo(points[j][0], points[j][1]);
                }
            }
        }
        entry.pointCount = points.length;
        entry.dirty = false;
    }
    function drawFeatheredBrush(ctx, entry) {
        var command = entry.command;
        if (!entry.featherLayers) {
            var color = Qt.color(command.color);
            var alpha = command.opacity * color.a;
            entry.featherColor = Qt.rgba(color.r, color.g, color.b, 1);
            entry.featherLayers = [];
            // Canvas2D's antialias is capped at 10 pixels and extends outwards.
            // Instead approximate a linear inward coverage ramp with nested paths.
            // Midpoint radii keep the soft edge inside the nominal brush width.
            var count = Math.max(1, Math.min(32, Math.ceil(command.width * command.feather / 2)));
            for (var i = 0; i < count; ++i) {
                entry.featherLayers.push({
                    width: command.width * (1 - command.feather * (i + 0.5) / count),
                    // Source-over must add alpha/count, not compound stroke opacity.
                    alpha: (alpha / count) / (1 - alpha * i / count),
                    path: null
                });
            }
        }
        ctx.strokeStyle = entry.featherColor;
        ctx.fillStyle = entry.featherColor;
        // Stencil each whole polyline once per layer, including self-intersections.
        // Sampling a gesture more often must not deposit extra translucent dabs.
        ctx.highQualityStroking = true;
        var dot = isDot(command.points);
        for (var j = 0; j < entry.featherLayers.length; ++j) {
            var layer = entry.featherLayers[j];
            ctx.globalAlpha = layer.alpha;
            if (dot) {
                if (!layer.path) {
                    layer.path = ctx.createPath2D();
                    layer.path.circle(command.points[0][0], command.points[0][1], layer.width / 2);
                }
                ctx.fill(layer.path, entry.group);
            } else {
                ctx.lineWidth = layer.width;
                // Native cache keys include stroke width: all layers share one path.
                ctx.stroke(entry.path, entry.group);
            }
        }
        ctx.highQualityStroking = false;
    }
    function drawCommand(ctx, entry) {
        var command = entry.command;
        if (command.tool === "clear") {
            ctx.globalAlpha = 1;
            ctx.globalCompositeOperation = "source-over";
            ctx.clearRect(0, 0, 1280, 720);
            return;
        }
        if (!command.points.length)
            return;
        updatePath(ctx, entry);
        ctx.globalCompositeOperation = command.tool === "eraser" ? "destination-out" : "source-over";
        if (command.tool === "brush" && command.feather > 0) {
            drawFeatheredBrush(ctx, entry);
            return;
        }
        ctx.globalAlpha = command.opacity;
        ctx.strokeStyle = command.tool === "eraser" ? "white" : command.color;
        ctx.fillStyle = command.tool === "eraser" ? "white" : command.color;
        ctx.lineWidth = command.width;
        if (isDot(command.points) || (command.filled && (command.tool === "rectangle" || command.tool === "ellipse")))
            ctx.fill(entry.path, entry.group);
        else
            ctx.stroke(entry.path, entry.group);
    }

    // Background is not paint: erasing/clearing ink always reveals the current color.
    // The checkerboard lives outside this Item and is never included in a color grab.
    Rectangle {
        anchors.fill: parent
        color: root.fillColor
    }
    Canvas2D {
        id: ink
        width: 1280
        height: 720
        transform: Scale {
            xScale: root.width / 1280
            yScale: root.height / 720
        }
        fillColor: "transparent"
        alphaBlending: true
        antialiasing: true
        contextType: "2d"
        onAvailableChanged: {
            if (available)
                requestPaint();
            else
                root.cancelSample();
        }
        onEffectiveColorBufferSizeChanged: {
            // A queued sample can use the new size; an already-started grab cannot.
            if (root._pendingSample)
                requestPaint();
            else
                root.cancelSample();
        }
        onPaint: {
            var ctx = getContext("2d");
            if (!ctx)
                return;
            ctx.reset();
            for (var i = 0; i < root._removedGroups.length; ++i)
                ctx.removePathGroup(root._removedGroups[i]);
            root._removedGroups = [];
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            // Upstream clears the render target before each paint. Replay retained paths
            // plus exactly one live stroke, so opacity, cancel, and erasers never accumulate.
            for (var j = 0; j < root._commands.length; ++j)
                root.drawCommand(ctx, root._commands[j]);
            if (root._active)
                root.drawCommand(ctx, root._active);
            if (root._pendingSample)
                Qt.callLater(root.grabSample);
        }
    }
}
