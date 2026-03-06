.pragma library

// ============================================================
// Default state & object factory
// ============================================================

function defaultSlideState() {
    return {
        bgType: "solid",
        bgColor: "#000000",
        bgGradStart: "#000000",
        bgGradEnd: "#333333",
        bgGradAngle: 90,
        bgTexSource: 0,
        bgTexFit: "cover",
        slideFormat: "fill",
        customWidth: 1920,
        customHeight: 1080,
        objects: []
    };
}

function mergeState(base, overrides) {
    var result = {};
    for (var k in base) result[k] = base[k];
    if (overrides) {
        for (var k in overrides) {
            if (k === "objects" && Array.isArray(overrides[k])) {
                result[k] = overrides[k];
            } else {
                result[k] = overrides[k];
            }
        }
    }
    return result;
}

function cloneSlide(slide) {
    return JSON.parse(JSON.stringify(slide));
}

function createObject(type, index) {
    var offset = (index % 5) * 0.05;
    var obj = {
        id: "obj-" + Date.now() + "-" + index,
        name: capitalize(type) + " " + (index + 1),
        type: type,
        visible: true,
        locked: false,

        x: 0.1 + offset,
        y: 0.1 + offset,
        w: 0.3,
        h: 0.2,
        rotation: 0,
        cornerRadius: 0,

        fillEnabled: true,
        fillType: "solid",
        fillColor: type === "text" ? "transparent" : "#ffffff",
        gradStartColor: "#ffffff",
        gradEndColor: "#4466ff",
        gradAngle: 90,

        strokeEnabled: false,
        strokeColor: "#000000",
        strokeWidth: 2,
        strokeStyle: "solid",

        opacity: 1.0,

        imageSource: 0,
        imageFit: "cover",
        imageCropL: 0, imageCropR: 0,
        imageCropT: 0, imageCropB: 0,
        imageBorderColor: "#000000",
        imageBorderWidth: 0,
        imageFileUrl: "",

        text: "Text",
        fontFamily: "IBM Plex Sans",
        fontSize: 36,
        fontWeight: "normal",
        fontStyle: "normal",
        textColor: "#ffffff",
        hAlign: "center",
        vAlign: "center",
        wordWrap: true,
        lineSpacing: 1.3
    };

    if (type === "ellipse") {
        obj.w = 0.2;
        obj.h = 0.2;
    } else if (type === "image") {
        obj.fillEnabled = false;
        obj.w = 0.4;
        obj.h = 0.3;
    } else if (type === "text") {
        obj.fillEnabled = false;
        obj.w = 0.4;
        obj.h = 0.15;
    }
    return obj;
}

function capitalize(s) {
    return s.charAt(0).toUpperCase() + s.slice(1);
}

function getFormatRatio(state) {
    var fmt = state.slideFormat || "fill";
    switch (fmt) {
        case "16:9": return 16 / 9;
        case "4:3": return 4 / 3;
        case "1:1": return 1;
        case "9:16": return 9 / 16;
        case "custom":
            var cw = state.customWidth || 1920;
            var ch = state.customHeight || 1080;
            return ch > 0 ? cw / ch : 16 / 9;
        default: return 0; // "fill"
    }
}

// ============================================================
// Color & gradient utilities (adapted from TextRender.js)
// ============================================================

function hexToRgba(hex, alpha) {
    if (!hex) return "rgba(0,0,0," + alpha + ")";
    hex = hex.replace('#', '');
    if (hex.length === 3) {
        hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
    }
    var r = parseInt(hex.substring(0, 2), 16) || 0;
    var g = parseInt(hex.substring(2, 4), 16) || 0;
    var b = parseInt(hex.substring(4, 6), 16) || 0;
    return "rgba(" + r + "," + g + "," + b + "," + alpha + ")";
}

function createAngleGradient(ctx, x, y, w, h, angle, c1, c2) {
    var rad = angle * Math.PI / 180;
    var cos = Math.cos(rad), sin = Math.sin(rad);
    var proj = Math.abs(w / 2 * cos) + Math.abs(h / 2 * sin);
    var cx = x + w / 2, cy = y + h / 2;
    var grad = ctx.createLinearGradient(
        cx - proj * cos, cy - proj * sin,
        cx + proj * cos, cy + proj * sin
    );
    grad.addColorStop(0, c1);
    grad.addColorStop(1, c2);
    return grad;
}

function createRadialGrad(ctx, x, y, w, h, c1, c2) {
    var cx = x + w / 2, cy = y + h / 2;
    var r = Math.max(w, h) / 2;
    var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, r);
    grad.addColorStop(0, c1);
    grad.addColorStop(1, c2);
    return grad;
}

function roundRect(ctx, x, y, w, h, r) {
    r = Math.min(r, w / 2, h / 2);
    if (r <= 0) {
        ctx.rect(x, y, w, h);
        return;
    }
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.arcTo(x + w, y, x + w, y + r, r);
    ctx.lineTo(x + w, y + h - r);
    ctx.arcTo(x + w, y + h, x + w - r, y + h, r);
    ctx.lineTo(x + r, y + h);
    ctx.arcTo(x, y + h, x, y + h - r, r);
    ctx.lineTo(x, y + r);
    ctx.arcTo(x, y, x + r, y, r);
    ctx.closePath();
}

// ============================================================
// Main paint entry point
// ============================================================

function paintSlide(ctx, w, h, state, inlets, masterOpacity, skipIdx) {
    ctx.clearRect(0, 0, w, h);
    if (!state) return;

    var alpha = (masterOpacity !== undefined) ? masterOpacity : 1.0;
    if (alpha <= 0) return;
    if (alpha < 1) ctx.globalAlpha = alpha;

    // Scale factor: absolute pixel values (fontSize, strokeWidth, etc.)
    // are authored for 1080p. Scale them to the actual canvas size.
    var s = h / 1080;

    paintBackground(ctx, w, h, state, inlets);

    var objs = state.objects;
    if (!objs) return;
    for (var i = 0; i < objs.length; i++) {
        if (i === skipIdx) continue;
        var obj = objs[i];
        if (!obj || obj.visible === false) continue;
        paintObject(ctx, w, h, obj, inlets, s);
    }

    if (alpha < 1) ctx.globalAlpha = 1;
}

// ============================================================
// Background
// ============================================================

function paintBackground(ctx, w, h, state, inlets) {
    var t = state.bgType || "solid";
    if (t === "solid") {
        ctx.fillStyle = state.bgColor || "#000000";
        ctx.fillRect(0, 0, w, h);
    } else if (t === "linearGradient") {
        ctx.fillStyle = createAngleGradient(ctx, 0, 0, w, h,
            state.bgGradAngle || 90,
            state.bgGradStart || "#000000",
            state.bgGradEnd || "#333333");
        ctx.fillRect(0, 0, w, h);
    } else if (t === "radialGradient") {
        ctx.fillStyle = createRadialGrad(ctx, 0, 0, w, h,
            state.bgGradStart || "#000000",
            state.bgGradEnd || "#333333");
        ctx.fillRect(0, 0, w, h);
    } else if (t === "texture") {
        ctx.fillStyle = "#000000";
        ctx.fillRect(0, 0, w, h);
        var src = state.bgTexSource || 0;
        if (inlets && inlets[src]) {
            var fit = state.bgTexFit || "cover";
            drawImageFit(ctx, inlets[src], 0, 0, w, h, fit);
        }
    }
}

// ============================================================
// Per-object dispatch
// ============================================================

function paintObject(ctx, w, h, obj, inlets, s) {
    var px = obj.x * w;
    var py = obj.y * h;
    var pw = obj.w * w;
    var ph = obj.h * h;

    if (pw <= 0 || ph <= 0) return;

    ctx.save();

    // Apply opacity
    if (obj.opacity !== undefined && obj.opacity < 1) {
        ctx.globalAlpha *= obj.opacity;
    }

    // Apply rotation around object center
    if (obj.rotation) {
        var cx = px + pw / 2;
        var cy = py + ph / 2;
        ctx.translate(cx, cy);
        ctx.rotate(obj.rotation * Math.PI / 180);
        ctx.translate(-cx, -cy);
    }

    switch (obj.type) {
        case "rect":
            paintRect(ctx, obj, px, py, pw, ph, s);
            break;
        case "ellipse":
            paintEllipse(ctx, obj, px, py, pw, ph, s);
            break;
        case "image":
            paintImage(ctx, obj, px, py, pw, ph, inlets, s);
            break;
        case "text":
            paintText(ctx, obj, px, py, pw, ph, s);
            break;
    }

    ctx.restore();
}

// ============================================================
// Shape painters
// ============================================================

function paintRect(ctx, obj, x, y, w, h, s) {
    var r = (obj.cornerRadius || 0) * s;

    if (obj.fillEnabled !== false) {
        ctx.beginPath();
        roundRect(ctx, x, y, w, h, r);
        applyFill(ctx, obj, x, y, w, h);
        ctx.fill();
    }

    if (obj.strokeEnabled) {
        ctx.beginPath();
        roundRect(ctx, x, y, w, h, r);
        applyStroke(ctx, obj, s);
        ctx.stroke();
    }
}

function paintEllipse(ctx, obj, x, y, w, h, s) {
    var cx = x + w / 2;
    var cy = y + h / 2;
    var rx = w / 2;
    var ry = h / 2;

    if (obj.fillEnabled !== false) {
        ctx.beginPath();
        ctx.ellipse(cx, cy, rx, ry, 0, 0, 2 * Math.PI);
        applyFill(ctx, obj, x, y, w, h);
        ctx.fill();
    }

    if (obj.strokeEnabled) {
        ctx.beginPath();
        ctx.ellipse(cx, cy, rx, ry, 0, 0, 2 * Math.PI);
        applyStroke(ctx, obj, s);
        ctx.stroke();
    }
}

function paintImage(ctx, obj, x, y, w, h, inlets, s) {
    var src = obj.imageSource || 0;
    var texItem = inlets ? inlets[src] : null;
    var hasFileUrl = obj.imageFileUrl && obj.imageFileUrl.length > 0;

    // Draw fill behind image if enabled
    if (obj.fillEnabled) {
        ctx.beginPath();
        ctx.rect(x, y, w, h);
        applyFill(ctx, obj, x, y, w, h);
        ctx.fill();
    }

    // Apply crop
    var cl = obj.imageCropL || 0;
    var cr = obj.imageCropR || 0;
    var ct = obj.imageCropT || 0;
    var cb = obj.imageCropB || 0;
    var cropX = x + cl * w;
    var cropY = y + ct * h;
    var cropW = w * (1 - cl - cr);
    var cropH = h * (1 - ct - cb);

    if (cropW > 0 && cropH > 0) {
        if (hasFileUrl) {
            ctx.save();
            ctx.beginPath();
            ctx.rect(cropX, cropY, cropW, cropH);
            ctx.clip();
            try { ctx.drawImage(obj.imageFileUrl, cropX, cropY, cropW, cropH); } catch(e) {}
            ctx.restore();
        } else if (texItem) {
            ctx.save();
            ctx.beginPath();
            ctx.rect(cropX, cropY, cropW, cropH);
            ctx.clip();
            drawImageFit(ctx, texItem, cropX, cropY, cropW, cropH, obj.imageFit || "cover");
            ctx.restore();
        }
    }

    // Image border
    var bw = (obj.imageBorderWidth || 0) * s;
    if (bw > 0) {
        ctx.strokeStyle = obj.imageBorderColor || "#000000";
        ctx.lineWidth = bw;
        ctx.strokeRect(x, y, w, h);
    }

    // Outer stroke
    if (obj.strokeEnabled) {
        ctx.beginPath();
        ctx.rect(x, y, w, h);
        applyStroke(ctx, obj, s);
        ctx.stroke();
    }
}

function paintText(ctx, obj, x, y, w, h, s) {
    // Draw fill background if enabled
    if (obj.fillEnabled) {
        ctx.beginPath();
        ctx.rect(x, y, w, h);
        applyFill(ctx, obj, x, y, w, h);
        ctx.fill();
    }

    if (obj.strokeEnabled) {
        ctx.beginPath();
        ctx.rect(x, y, w, h);
        applyStroke(ctx, obj, s);
        ctx.stroke();
    }

    // Render text
    var text = obj.text || "";
    if (!text) return;

    var fontSize = (obj.fontSize || 36) * s;
    var fontParts = [];
    if (obj.fontStyle === "italic") fontParts.push("italic");
    if (obj.fontWeight === "bold") fontParts.push("bold");
    fontParts.push(fontSize + "px");
    fontParts.push('"' + (obj.fontFamily || "IBM Plex Sans") + '"');
    ctx.font = fontParts.join(" ");
    ctx.fillStyle = obj.textColor || "#ffffff";

    var lineH = fontSize * (obj.lineSpacing || 1.3);
    var hAlign = obj.hAlign || "center";
    var vAlign = obj.vAlign || "center";

    ctx.textBaseline = "top";
    ctx.textAlign = hAlign === "center" ? "center" : (hAlign === "right" ? "right" : "left");

    // Word wrap
    var lines;
    if (obj.wordWrap !== false) {
        lines = wrapText(ctx, text, w);
    } else {
        lines = text.split('\n');
    }

    // Vertical positioning
    var totalH = lines.length * lineH;
    var startY;
    if (vAlign === "top") {
        startY = y;
    } else if (vAlign === "bottom") {
        startY = y + h - totalH;
    } else {
        startY = y + (h - totalH) / 2;
    }

    // Horizontal anchor
    var textX;
    if (hAlign === "center") {
        textX = x + w / 2;
    } else if (hAlign === "right") {
        textX = x + w;
    } else {
        textX = x;
    }

    for (var i = 0; i < lines.length; i++) {
        ctx.fillText(lines[i], textX, startY + i * lineH);
    }
}

// ============================================================
// Fill & stroke helpers
// ============================================================

function applyFill(ctx, obj, x, y, w, h) {
    var ft = obj.fillType || "solid";
    if (ft === "linearGradient") {
        ctx.fillStyle = createAngleGradient(ctx, x, y, w, h,
            obj.gradAngle || 90,
            obj.gradStartColor || "#ffffff",
            obj.gradEndColor || "#4466ff");
    } else if (ft === "radialGradient") {
        ctx.fillStyle = createRadialGrad(ctx, x, y, w, h,
            obj.gradStartColor || "#ffffff",
            obj.gradEndColor || "#4466ff");
    } else {
        ctx.fillStyle = obj.fillColor || "#ffffff";
    }
}

function applyStroke(ctx, obj, s) {
    ctx.strokeStyle = obj.strokeColor || "#000000";
    ctx.lineWidth = (obj.strokeWidth || 2) * (s || 1);

    var style = obj.strokeStyle || "solid";
    if (style === "dashed") {
        ctx.setLineDash([ctx.lineWidth * 4, ctx.lineWidth * 2]);
    } else if (style === "dotted") {
        ctx.setLineDash([ctx.lineWidth, ctx.lineWidth * 2]);
    } else {
        ctx.setLineDash([]);
    }
}

// ============================================================
// Image fit modes
// ============================================================

function drawImageFit(ctx, texItem, dx, dy, dw, dh, mode) {
    if (!texItem || !texItem.width || !texItem.height) return;
    var iw = texItem.width;
    var ih = texItem.height;
    if (iw <= 0 || ih <= 0) return;

    try {
        if (mode === "stretch") {
            ctx.drawImage(texItem, dx, dy, dw, dh);
        } else if (mode === "contain") {
            var scale = Math.min(dw / iw, dh / ih);
            var sw = iw * scale;
            var sh = ih * scale;
            ctx.drawImage(texItem, dx + (dw - sw) / 2, dy + (dh - sh) / 2, sw, sh);
        } else if (mode === "tile") {
            ctx.save();
            ctx.beginPath();
            ctx.rect(dx, dy, dw, dh);
            ctx.clip();
            for (var ty = dy; ty < dy + dh; ty += ih) {
                for (var tx = dx; tx < dx + dw; tx += iw) {
                    ctx.drawImage(texItem, tx, ty, iw, ih);
                }
            }
            ctx.restore();
        } else {
            // cover (default)
            var scale = Math.max(dw / iw, dh / ih);
            var sw = iw * scale;
            var sh = ih * scale;
            ctx.drawImage(texItem, dx + (dw - sw) / 2, dy + (dh - sh) / 2, sw, sh);
        }
    } catch(e) {
        // drawImage failed — item not yet renderable, skip silently
    }
}

// ============================================================
// Text wrap helper
// ============================================================

function wrapText(ctx, text, maxWidth) {
    if (!text) return [""];
    var paragraphs = text.split('\n');
    var result = [];
    for (var p = 0; p < paragraphs.length; p++) {
        var line = paragraphs[p];
        if (!maxWidth || maxWidth <= 0) {
            result.push(line);
            continue;
        }
        var mw = ctx.measureText(line).width;
        if (mw <= maxWidth) {
            result.push(line);
            continue;
        }
        var words = line.split(' ');
        var current = '';
        for (var wi = 0; wi < words.length; wi++) {
            var test = current ? current + ' ' + words[wi] : words[wi];
            if (ctx.measureText(test).width > maxWidth && current) {
                result.push(current);
                current = words[wi];
            } else {
                current = test;
            }
        }
        result.push(current);
    }
    return result;
}
