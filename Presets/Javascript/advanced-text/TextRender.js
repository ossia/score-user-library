.pragma library

function defaultState() {
    return {
        text: "HELLO WORLD",
        textTransform: "none",
        fontFamily: "IBM Plex Sans",
        fontSize: 72,
        fontWeight: "normal",
        fontStyle: "normal",
        underline: false,
        strikethrough: false,

        fillEnabled: true,
        fillType: "solid",
        fillColor: "#ffffff",
        gradStartColor: "#ffffff",
        gradEndColor: "#4466ff",
        gradAngle: 90,

        strokeEnabled: false,
        strokeColor: "#000000",
        strokeWidth: 3,
        strokeJoin: "round",

        shadowEnabled: false,
        shadowColor: "#000000",
        shadowOffsetX: 4,
        shadowOffsetY: 4,
        shadowBlur: 10,
        shadowOpacity: 0.7,

        bgEnabled: false,
        bgColor: "#000000",
        bgOpacity: 0.5,
        bgPaddingH: 20,
        bgPaddingV: 10,
        bgCornerRadius: 8,

        hAlign: "center",
        vAlign: "center",
        wordWrap: false,
        boundingBoxW: 0.8,
        boundingBoxH: 0,
        lineSpacing: 1.3,
        tracking: 0,

        posX: 0.5,
        posY: 0.5,
        rotation: 0,
        scaleX: 1.0,
        scaleY: 1.0,
        skewX: 0,
        skewY: 0,
        anchorH: "center",
        anchorV: "center",

        opacity: 1.0,

        // Phase 2: Write-On modes
        writeOnMode: "typewriter",
        writeOnDirection: "forward",
        writeOnScope: "character",
        writeOnOverlap: 5,
        writeOnCursor: false,
        writeOnCursorChar: "\u258c",
        writeOnScrambleIter: 5,

        // Phase 2: Scrolling
        scrollMode: "none",
        scrollSpeed: 50,
        scrollLoop: true,
        scrollFadeEdges: 0.1,

        // Phase 2: Per-character wave
        charWaveEnabled: false,
        charWaveAmplitude: 10,
        charWaveFrequency: 2,
        charWaveProperty: "posY",

        // Phase 3: Multiple strokes (up to 3 layers)
        stroke2Enabled: false,
        stroke2Color: "#333333",
        stroke2Width: 8,
        stroke2Join: "round",
        stroke3Enabled: false,
        stroke3Color: "#666666",
        stroke3Width: 14,
        stroke3Join: "round",

        // Phase 3: Multiple shadows (up to 2 layers)
        shadow2Enabled: false,
        shadow2Color: "#000000",
        shadow2OffsetX: 8,
        shadow2OffsetY: 8,
        shadow2Blur: 20,
        shadow2Opacity: 0.5,

        // Phase 3: Per-character animation (Resolume-style cascade)
        charAnimEnabled: false,
        charAnimScope: "character",    // character / word / line
        charAnimOrder: "forward",      // forward / reverse / random / fromCenter / toCenter
        charAnimDelay: 0.1,            // seconds between successive elements
        charAnimRandomSeed: 42,
        // Per-character property offsets (starting state; animates toward rest)
        charAnimPosX: 0,
        charAnimPosY: 50,
        charAnimRotation: 0,
        charAnimScale: 0.5,
        charAnimOpacity: 0,
        charAnimFillColor: "",         // empty = no override
        charAnimCharOffset: 0,         // unicode shift for scramble effect

        // Phase 3: Texture fill UV
        texFillScaleX: 1,
        texFillScaleY: 1,
        texFillOffsetX: 0,
        texFillOffsetY: 0,

        // Phase 3: Gradient mapping scope
        gradientScope: "fullText",     // fullText / perLine / perWord / perCharacter

        // Phase 3: Background scope & border
        bgScope: "fullText",           // fullText / perLine / perWord
        bgBorderEnabled: false,
        bgBorderColor: "#ffffff",
        bgBorderWidth: 1
    };
}

function mergeState(base, overrides) {
    var result = {};
    for (var k in base) result[k] = base[k];
    if (overrides) {
        for (var k in overrides) result[k] = overrides[k];
    }
    return result;
}

function buildFontString(s) {
    var parts = [];
    if (s.fontStyle === "italic") parts.push("italic");
    if (s.fontWeight === "bold") parts.push("bold");
    parts.push(Math.max(1, s.fontSize || 72) + "px");
    parts.push('"' + (s.fontFamily || "Arial") + '"');
    return parts.join(" ");
}

function applyTextTransform(text, transform) {
    switch (transform) {
        case "uppercase": return text.toUpperCase();
        case "lowercase": return text.toLowerCase();
        case "titlecase":
            return text.replace(/\b\w/g, function(c) { return c.toUpperCase(); });
        default: return text;
    }
}

function wrapText(ctx, text, maxWidth, tracking) {
    if (!text) return [""];
    var paragraphs = text.split('\n');
    var result = [];
    for (var p = 0; p < paragraphs.length; p++) {
        var line = paragraphs[p];
        if (!maxWidth || maxWidth <= 0) {
            result.push(line);
            continue;
        }
        var mw = measureLine(ctx, line, tracking);
        if (mw <= maxWidth) {
            result.push(line);
            continue;
        }
        var words = line.split(' ');
        var current = '';
        for (var w = 0; w < words.length; w++) {
            var test = current ? current + ' ' + words[w] : words[w];
            if (measureLine(ctx, test, tracking) > maxWidth && current) {
                result.push(current);
                current = words[w];
            } else {
                current = test;
            }
        }
        result.push(current);
    }
    return result;
}

function measureLine(ctx, text, tracking) {
    if (!text || text.length === 0) return 0;
    if (!tracking) return ctx.measureText(text).width;
    var w = 0;
    for (var i = 0; i < text.length; i++) {
        w += ctx.measureText(text[i]).width;
        if (i < text.length - 1) w += tracking;
    }
    return w;
}

function drawSegment(ctx, text, x, y, tracking, mode) {
    if (!text || text.length === 0) return;
    if (!tracking) {
        if (mode === "fill") ctx.fillText(text, x, y);
        else ctx.strokeText(text, x, y);
        return;
    }
    var cx = x;
    for (var i = 0; i < text.length; i++) {
        if (mode === "fill") ctx.fillText(text[i], cx, y);
        else ctx.strokeText(text[i], cx, y);
        cx += ctx.measureText(text[i]).width + tracking;
    }
}

function roundRect(ctx, x, y, w, h, r) {
    r = Math.min(Math.max(0, r), w / 2, h / 2);
    ctx.beginPath();
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

// ---- Phase 2 helpers ----

function layoutCharacters(ctx, lines, lineWidths, tracking, bx, by, lineH, hAlign, blockW) {
    var chars = [];
    var gi = 0;
    for (var li = 0; li < lines.length; li++) {
        var line = lines[li];
        var lx = bx;
        if (hAlign === "center") lx = bx + (blockW - lineWidths[li]) / 2;
        else if (hAlign === "right") lx = bx + blockW - lineWidths[li];
        var ly = by + li * lineH;
        var cx = lx;
        for (var ci = 0; ci < line.length; ci++) {
            var ch = line[ci];
            var cw = ctx.measureText(ch).width;
            chars.push({ ch: ch, x: cx, y: ly, w: cw, li: li, ci: ci, gi: gi });
            cx += cw + (tracking || 0);
            gi++;
        }
    }
    return chars;
}

function charWriteOnProgress(gi, totalChars, writeOn, s) {
    if (writeOn >= 1) return 1;
    if (writeOn <= 0) return 0;
    if (totalChars <= 0) return 1;

    var overlap = Math.max(1, s.writeOnOverlap || 5);
    var idx;
    switch (s.writeOnDirection || "forward") {
        case "reverse":
            idx = totalChars - 1 - gi;
            break;
        case "fromCenter":
            var center = (totalChars - 1) / 2;
            idx = Math.round(center - Math.abs(gi - center));
            // Invert so center chars appear first
            idx = Math.round(center) - idx;
            break;
        case "random":
            // Deterministic pseudo-random based on index
            idx = ((gi * 2654435761) >>> 0) % totalChars;
            break;
        default:
            idx = gi;
    }

    var progress = (writeOn * (totalChars + overlap - 1) - idx) / overlap;
    return Math.max(0, Math.min(1, progress));
}

function scrambleChar(gi, progress, iterations) {
    var pool = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%&*";
    var step = Math.floor(progress * (iterations || 5));
    var seed = ((gi * 7 + step * 13) >>> 0) % pool.length;
    return pool[seed];
}

function charWaveOffset(gi, elapsed, s) {
    if (!s.charWaveEnabled) return 0;
    var amp = s.charWaveAmplitude || 10;
    var freq = s.charWaveFrequency || 2;
    var phase = gi * 0.3;
    return amp * Math.sin(2 * Math.PI * freq * elapsed + phase);
}

function computeScrollOffset(s, elapsed, w, h, blockW, blockH) {
    if (!s.scrollMode || s.scrollMode === "none" || !elapsed)
        return { x: 0, y: 0 };
    var speed = s.scrollSpeed || 50;
    var dist = speed * elapsed;
    var ox = 0, oy = 0;

    switch (s.scrollMode) {
        case "up": oy = -dist; break;
        case "down": oy = dist; break;
        case "left": ox = -dist; break;
        case "right": ox = dist; break;
    }

    if (s.scrollLoop) {
        if (s.scrollMode === "up" || s.scrollMode === "down") {
            var total = blockH + h;
            if (total > 0) {
                oy = ((oy % total) + total) % total;
                if (oy > blockH) oy -= total;
            }
        } else {
            var total = blockW + w;
            if (total > 0) {
                ox = ((ox % total) + total) % total;
                if (ox > blockW) ox -= total;
            }
        }
    }
    return { x: ox, y: oy };
}

function edgeFade(pos, size, fadeEdge, canvasSize) {
    if (!fadeEdge || fadeEdge <= 0) return 1;
    var fs = fadeEdge * canvasSize;
    if (fs <= 0) return 1;
    var top = Math.min(1, Math.max(0, pos / fs));
    var bot = Math.min(1, Math.max(0, (canvasSize - pos - size) / fs));
    return Math.min(top, bot);
}

// ---- Phase 3: Resolume-style cascade per-character animation ----

// Compute the cascade index for a character based on scope and order
function cascadeIndex(chars, ci, s) {
    var c = chars[ci];
    var order = s.charAnimOrder || "forward";
    var scope = s.charAnimScope || "character";

    // Determine element index based on scope
    var elemIdx, totalElems;
    if (scope === "word") {
        // Group by words: count word boundaries
        elemIdx = 0; totalElems = 0;
        var inWord = false;
        var wordMap = [];
        for (var i = 0; i < chars.length; i++) {
            if (chars[i].ch === ' ' || chars[i].ch === '\t') {
                inWord = false;
            } else {
                if (!inWord) { totalElems++; inWord = true; }
                wordMap[i] = totalElems - 1;
            }
        }
        elemIdx = wordMap[ci] || 0;
    } else if (scope === "line") {
        elemIdx = c.li;
        totalElems = 0;
        for (var i = 0; i < chars.length; i++)
            if (chars[i].li > totalElems) totalElems = chars[i].li;
        totalElems++;
    } else {
        elemIdx = c.gi;
        totalElems = chars.length;
    }

    // Reorder based on order mode
    switch (order) {
        case "reverse":
            return { idx: totalElems - 1 - elemIdx, total: totalElems };
        case "fromCenter":
            var center = (totalElems - 1) / 2;
            var dist = Math.abs(elemIdx - center);
            return { idx: Math.round(dist), total: totalElems };
        case "toCenter":
            var center = (totalElems - 1) / 2;
            var dist = Math.abs(elemIdx - center);
            return { idx: Math.round(center - dist + center), total: totalElems };
        case "random":
            var seed = s.charAnimRandomSeed || 42;
            var hash = ((elemIdx * 2654435761 + seed * 1597334677) >>> 0) % totalElems;
            return { idx: hash, total: totalElems };
        default: // forward
            return { idx: elemIdx, total: totalElems };
    }
}

// Compute per-character cascade animation progress (0-1)
// Based on elapsed time and per-element delay
function cascadeProgress(chars, ci, elapsed, s) {
    if (!s.charAnimEnabled) return 1;
    var info = cascadeIndex(chars, ci, s);
    var delay = s.charAnimDelay || 0.1;
    var startTime = info.idx * delay;
    var t = elapsed - startTime;
    // Clamp to 0-1 over one delay period (the transition window)
    if (t < 0) return 0;
    if (delay <= 0) return 1;
    return Math.min(1, t / delay);
}

// Apply per-character cascade animation transforms
function applyCascadeAnim(ctx, c, progress, s, fontSize) {
    if (progress >= 1 && !s.charAnimPosX && !s.charAnimPosY
        && !s.charAnimRotation && s.charAnimScale === 1
        && s.charAnimOpacity === 1 && !s.charAnimCharOffset) return null;

    var t = progress; // 0 = at animated state, 1 = at rest state
    var result = { alpha: 1, ch: null };

    // Position offset: lerp from offset to 0
    var px = s.charAnimPosX || 0;
    var py = s.charAnimPosY || 0;
    if (px || py) {
        ctx.translate(px * (1 - t), py * (1 - t));
    }

    // Rotation: lerp from rotation to 0
    var rot = s.charAnimRotation || 0;
    if (rot) {
        var cx = c.x + c.w / 2, cy = c.y + fontSize / 2;
        ctx.translate(cx, cy);
        ctx.rotate(rot * (1 - t) * Math.PI / 180);
        ctx.translate(-cx, -cy);
    }

    // Scale: lerp from charAnimScale to 1
    var sc = s.charAnimScale;
    if (sc !== undefined && sc !== 1) {
        var sv = 1 + (sc - 1) * (1 - t);
        var cx = c.x + c.w / 2, cy = c.y + fontSize / 2;
        ctx.translate(cx, cy);
        ctx.scale(sv, sv);
        ctx.translate(-cx, -cy);
    }

    // Opacity: lerp from charAnimOpacity to 1
    var op = s.charAnimOpacity;
    if (op !== undefined && op !== 1) {
        result.alpha = 1 + (op - 1) * (1 - t);
    }

    // Character offset (unicode shift)
    var co = s.charAnimCharOffset || 0;
    if (co && t < 1) {
        var shift = Math.round(co * (1 - t));
        if (shift !== 0) {
            result.ch = String.fromCharCode(c.ch.charCodeAt(0) + shift);
        }
    }

    return result;
}

// Get stroke layers as array (outermost first for correct rendering order)
function getStrokeLayers(s) {
    var layers = [];
    if (s.stroke3Enabled && s.stroke3Width > 0)
        layers.push({ color: s.stroke3Color || "#666", width: s.stroke3Width, join: s.stroke3Join || "round" });
    if (s.stroke2Enabled && s.stroke2Width > 0)
        layers.push({ color: s.stroke2Color || "#333", width: s.stroke2Width, join: s.stroke2Join || "round" });
    if (s.strokeEnabled && s.strokeWidth > 0)
        layers.push({ color: s.strokeColor || "#000", width: s.strokeWidth, join: s.strokeJoin || "round" });
    return layers;
}

// Get shadow layers as array
function getShadowLayers(s) {
    var layers = [];
    if (s.shadow2Enabled) {
        layers.push({
            color: s.shadow2Color || "#000", offsetX: s.shadow2OffsetX || 0,
            offsetY: s.shadow2OffsetY || 0, blur: s.shadow2Blur || 0,
            opacity: s.shadow2Opacity !== undefined ? s.shadow2Opacity : 0.5
        });
    }
    if (s.shadowEnabled) {
        layers.push({
            color: s.shadowColor || "#000", offsetX: s.shadowOffsetX || 0,
            offsetY: s.shadowOffsetY || 0, blur: s.shadowBlur || 0,
            opacity: s.shadowOpacity !== undefined ? s.shadowOpacity : 0.7
        });
    }
    return layers;
}

// Create gradient fill scoped to a specific region
function createScopedGradient(ctx, s, x, y, w, h) {
    if (s.fillType === "linearGradient") {
        return createAngleGradient(ctx, x, y, w, h,
            s.gradAngle || 0, s.gradStartColor || "#fff", s.gradEndColor || "#000");
    } else if (s.fillType === "radialGradient") {
        var gcx = x + w / 2, gcy = y + h / 2;
        var grad = ctx.createRadialGradient(gcx, gcy, 0, gcx, gcy, Math.max(w, h) / 2);
        grad.addColorStop(0, s.gradStartColor || "#fff");
        grad.addColorStop(1, s.gradEndColor || "#000");
        return grad;
    }
    return s.fillColor || "#ffffff";
}

// ---- Texture fill rendering (reversed draw order with Canvas compositing) ----
// Technique: draw text shapes first, source-in with texture, then
// destination-over for stroke/shadow behind the textured fill.

function paintTextTextureFill(ctx, w, h, s, inlet, texItem,
    lines, lineWidths, blockW, blockH, lineH, fontSize, fontStr, tracking,
    bx, by, posX, posY, opacity, writeOn, totalChars, elapsed, woMode,
    needsPerChar, hasScroll, scrollOff, hasFadeEdge, ancX, ancY)
{
    var strokeLayers = getStrokeLayers(s);
    var shadowLayers = getShadowLayers(s);

    ctx.font = fontStr;
    ctx.textBaseline = "top";

    // Texture fill UV mapping
    var texScaleX = s.texFillScaleX || 1;
    var texScaleY = s.texFillScaleY || 1;
    var texOffsetX = s.texFillOffsetX || 0;
    var texOffsetY = s.texFillOffsetY || 0;

    // ---- Step 1: Draw text fill shapes as white (the mask) ----
    ctx.fillStyle = "#ffffff";

    if (needsPerChar) {
        var chars = layoutCharacters(ctx, lines, lineWidths, tracking,
            bx, by, lineH, s.hAlign || "center", blockW);

        for (var ci = 0; ci < chars.length; ci++) {
            var c = chars[ci];
            var prog = charWriteOnProgress(c.gi, totalChars, writeOn, s);
            if (prog <= 0) continue;

            var drawCh = c.ch;
            ctx.save();

            // Apply write-on effects
            var charAlpha = 1;
            switch (woMode) {
                case "fade": charAlpha = prog; break;
                case "scale":
                    var scv = prog;
                    var ccx = c.x + c.w / 2, ccy = c.y + fontSize / 2;
                    ctx.translate(ccx, ccy); ctx.scale(scv, scv); ctx.translate(-ccx, -ccy);
                    break;
                case "slide":
                    ctx.translate(0, (1 - prog) * fontSize); charAlpha = prog; break;
                case "scramble":
                    if (prog < 1) drawCh = scrambleChar(c.gi, prog, s.writeOnScrambleIter || 5);
                    break;
                default: if (prog < 0.5) { ctx.restore(); continue; }
            }

            // Wave offset
            var wave = charWaveOffset(c.gi, elapsed, s);
            if (wave !== 0) {
                var wp = s.charWaveProperty || "posY";
                if (wp === "posY") ctx.translate(0, wave);
                else if (wp === "posX") ctx.translate(wave, 0);
                else if (wp === "rotation") {
                    var rx = c.x + c.w / 2, ry = c.y + fontSize / 2;
                    ctx.translate(rx, ry); ctx.rotate(wave * Math.PI / 180); ctx.translate(-rx, -ry);
                } else if (wp === "scale") {
                    var ws = 1 + wave / 100;
                    var wx = c.x + c.w / 2, wy = c.y + fontSize / 2;
                    ctx.translate(wx, wy); ctx.scale(ws, ws); ctx.translate(-wx, -wy);
                } else if (wp === "opacity") {
                    charAlpha *= Math.max(0, 0.5 + wave / (2 * (s.charWaveAmplitude || 10)));
                }
            }

            // Cascade animation
            if (s.charAnimEnabled) {
                var cp = cascadeProgress(chars, ci, elapsed, s);
                var cr = applyCascadeAnim(ctx, c, cp, s, fontSize);
                if (cr) { charAlpha *= cr.alpha; if (cr.ch) drawCh = cr.ch; }
            }

            ctx.globalAlpha = opacity * charAlpha;
            ctx.fillText(drawCh, c.x, c.y);
            ctx.restore();
        }
    } else {
        // Fast line-by-line: draw visible text shapes as white
        var charsSoFar = 0;
        var visibleChars = (writeOn < 1.0) ? Math.ceil(writeOn * totalChars) : totalChars;
        for (var li = 0; li < lines.length; li++) {
            var lt = lines[li];
            var vis = Math.min(lt.length, Math.max(0, visibleChars - charsSoFar));
            charsSoFar += lt.length;
            if (vis <= 0) continue;
            var drawT = lt.substring(0, vis);
            var lx = bx;
            var ha = s.hAlign || "center";
            if (ha === "center") lx = bx + (blockW - lineWidths[li]) / 2;
            else if (ha === "right") lx = bx + blockW - lineWidths[li];
            var ly = by + li * lineH;
            drawSegment(ctx, drawT, lx, ly, tracking, "fill");
        }
    }

    // ---- Step 2: Composite texture over text mask ----
    ctx.globalCompositeOperation = "source-in";
    ctx.globalAlpha = 1;
    // Draw the texture over the text bounding box; source-in clips to text shapes
    try {
        var tw = blockW * texScaleX;
        var th = blockH * texScaleY;
        var tx = bx + texOffsetX * blockW - (tw - blockW) / 2;
        var ty = by + texOffsetY * blockH - (th - blockH) / 2;
        ctx.drawImage(texItem, tx, ty, tw, th);
    } catch(e) {
        // drawImage failed — fallback to white fill (already drawn)
    }

    // ---- Step 3: Draw stroke behind fill using destination-over ----
    ctx.globalCompositeOperation = "destination-over";
    ctx.globalAlpha = opacity;
    ctx.font = fontStr;
    ctx.textBaseline = "top";

    if (strokeLayers.length > 0) {
        if (needsPerChar) {
            var chars2 = layoutCharacters(ctx, lines, lineWidths, tracking,
                bx, by, lineH, s.hAlign || "center", blockW);
            // Draw strokes innermost first (they go behind with destination-over)
            for (var si = strokeLayers.length - 1; si >= 0; si--) {
                var sl = strokeLayers[si];
                ctx.strokeStyle = sl.color;
                ctx.lineWidth = sl.width;
                ctx.lineJoin = sl.join;
                ctx.lineCap = "round";
                for (var ci = 0; ci < chars2.length; ci++) {
                    var c = chars2[ci];
                    var prog = charWriteOnProgress(c.gi, totalChars, writeOn, s);
                    if (prog <= 0) continue;
                    ctx.save();
                    applyCharTransforms(ctx, c, prog, woMode, s, fontSize, elapsed, chars2, ci);
                    ctx.strokeText(c.ch, c.x, c.y);
                    ctx.restore();
                }
            }
        } else {
            var charsSoFar2 = 0;
            var visibleChars2 = (writeOn < 1.0) ? Math.ceil(writeOn * totalChars) : totalChars;
            // Innermost stroke first
            for (var si = strokeLayers.length - 1; si >= 0; si--) {
                var sl = strokeLayers[si];
                ctx.strokeStyle = sl.color;
                ctx.lineWidth = sl.width;
                ctx.lineJoin = sl.join;
                ctx.lineCap = "round";
                charsSoFar2 = 0;
                for (var li = 0; li < lines.length; li++) {
                    var lt = lines[li];
                    var vis = Math.min(lt.length, Math.max(0, visibleChars2 - charsSoFar2));
                    charsSoFar2 += lt.length;
                    if (vis <= 0) continue;
                    var drawT = lt.substring(0, vis);
                    var lx = bx;
                    var ha = s.hAlign || "center";
                    if (ha === "center") lx = bx + (blockW - lineWidths[li]) / 2;
                    else if (ha === "right") lx = bx + blockW - lineWidths[li];
                    drawSegment(ctx, drawT, lx, by + li * lineH, tracking, "stroke");
                }
            }
        }
    }

    // ---- Step 4: Draw shadows behind everything ----
    if (shadowLayers.length > 0) {
        // Draw shadows (outermost first in destination-over → appears furthest back)
        for (var si = shadowLayers.length - 1; si >= 0; si--) {
            var sh = shadowLayers[si];
            ctx.save();
            var shc = hexToRgba(sh.color, sh.opacity);
            ctx.fillStyle = shc;
            if (sh.blur > 0) {
                ctx.shadowColor = shc;
                ctx.shadowBlur = sh.blur;
                ctx.shadowOffsetX = 0;
                ctx.shadowOffsetY = 0;
            }
            if (needsPerChar) {
                var chars3 = layoutCharacters(ctx, lines, lineWidths, tracking,
                    bx, by, lineH, s.hAlign || "center", blockW);
                for (var ci = 0; ci < chars3.length; ci++) {
                    var c = chars3[ci];
                    var prog = charWriteOnProgress(c.gi, totalChars, writeOn, s);
                    if (prog <= 0) continue;
                    ctx.save();
                    applyCharTransforms(ctx, c, prog, woMode, s, fontSize, elapsed, chars3, ci);
                    ctx.fillText(c.ch, c.x + sh.offsetX, c.y + sh.offsetY);
                    ctx.restore();
                }
            } else {
                var charsSoFar3 = 0;
                var visibleChars3 = (writeOn < 1.0) ? Math.ceil(writeOn * totalChars) : totalChars;
                for (var li = 0; li < lines.length; li++) {
                    var lt = lines[li];
                    var vis = Math.min(lt.length, Math.max(0, visibleChars3 - charsSoFar3));
                    charsSoFar3 += lt.length;
                    if (vis <= 0) continue;
                    var drawT = lt.substring(0, vis);
                    var lx = bx;
                    var ha = s.hAlign || "center";
                    if (ha === "center") lx = bx + (blockW - lineWidths[li]) / 2;
                    else if (ha === "right") lx = bx + blockW - lineWidths[li];
                    drawSegment(ctx, drawT, lx + sh.offsetX, by + li * lineH + sh.offsetY,
                        tracking, "fill");
                }
            }
            ctx.restore();
        }
    }

    // ---- Step 5: Background behind everything ----
    if (s.bgEnabled) {
        ctx.save();
        ctx.globalAlpha = (s.bgOpacity !== undefined ? s.bgOpacity : 0.5) * opacity;
        ctx.fillStyle = s.bgColor || "#000000";
        var pH = s.bgPaddingH || 0, pV = s.bgPaddingV || 0;
        roundRect(ctx, bx - pH, by - pV,
            blockW + pH * 2, blockH + pV * 2, s.bgCornerRadius || 0);
        ctx.fill();
        if (s.bgBorderEnabled && s.bgBorderWidth > 0) {
            ctx.strokeStyle = s.bgBorderColor || "#fff";
            ctx.lineWidth = s.bgBorderWidth;
            ctx.stroke();
        }
        ctx.restore();
    }

    // Reset compositing
    ctx.globalCompositeOperation = "source-over";
}

// Helper: apply per-character transforms (shared between texture fill passes)
function applyCharTransforms(ctx, c, prog, woMode, s, fontSize, elapsed, chars, ci) {
    switch (woMode) {
        case "fade": break; // alpha only, handled separately
        case "scale":
            var scv = prog;
            var ccx = c.x + c.w / 2, ccy = c.y + fontSize / 2;
            ctx.translate(ccx, ccy); ctx.scale(scv, scv); ctx.translate(-ccx, -ccy);
            break;
        case "slide":
            ctx.translate(0, (1 - prog) * fontSize); break;
        default: break;
    }
    var wave = charWaveOffset(c.gi, elapsed, s);
    if (wave !== 0) {
        var wp = s.charWaveProperty || "posY";
        if (wp === "posY") ctx.translate(0, wave);
        else if (wp === "posX") ctx.translate(wave, 0);
        else if (wp === "rotation") {
            var rx = c.x + c.w / 2, ry = c.y + fontSize / 2;
            ctx.translate(rx, ry); ctx.rotate(wave * Math.PI / 180); ctx.translate(-rx, -ry);
        } else if (wp === "scale") {
            var ws = 1 + wave / 100;
            var wx = c.x + c.w / 2, wy = c.y + fontSize / 2;
            ctx.translate(wx, wy); ctx.scale(ws, ws); ctx.translate(-wx, -wy);
        }
    }
    if (s.charAnimEnabled) {
        var cp = cascadeProgress(chars, ci, elapsed, s);
        applyCascadeAnim(ctx, c, cp, s, fontSize);
    }
}

// ---- Main paint function ----

function paintText(ctx, w, h, state, inlet, texItem) {
    if (w <= 0 || h <= 0) return;
    var s = state;
    ctx.clearRect(0, 0, w, h);

    var text = applyTextTransform(
        inlet.text || s.text || "",
        s.textTransform || "none"
    );
    if (!text) return;

    var fontStr = buildFontString(s);
    ctx.font = fontStr;
    ctx.textBaseline = "top";
    var tracking = s.tracking || 0;
    var fontSize = s.fontSize || 72;
    var lineH = fontSize * (s.lineSpacing || 1.3);

    // Word wrap
    var maxWrap = (s.wordWrap && s.boundingBoxW > 0) ? s.boundingBoxW * w : 0;
    var lines = wrapText(ctx, text, maxWrap, tracking);

    // Measure
    var lineWidths = [];
    var maxLW = 0;
    for (var i = 0; i < lines.length; i++) {
        var lw = measureLine(ctx, lines[i], tracking);
        lineWidths.push(lw);
        if (lw > maxLW) maxLW = lw;
    }
    var totalH = lines.length * lineH;
    var blockW = maxLW, blockH = totalH;

    // WriteOn
    var writeOn = (inlet.writeOn !== undefined) ? inlet.writeOn : 1.0;
    var totalChars = 0;
    for (var i = 0; i < lines.length; i++) totalChars += lines[i].length;
    var elapsed = inlet.elapsed || 0;

    // Scroll offset (computed before transform so we know text dimensions)
    var scrollOff = computeScrollOffset(s, elapsed, w, h, blockW, blockH);
    var hasScroll = (scrollOff.x !== 0 || scrollOff.y !== 0);
    var hasFadeEdge = hasScroll && s.scrollFadeEdges > 0;

    // Determine per-character mode
    var woMode = s.writeOnMode || "typewriter";
    var needsPerChar = (writeOn < 1 && woMode !== "typewriter")
        || s.charWaveEnabled
        || s.charAnimEnabled;

    // Anchor offset
    var ancX = 0, ancY = 0;
    var ah = s.anchorH || "center";
    if (ah === "center") ancX = -blockW / 2;
    else if (ah === "right") ancX = -blockW;
    var av = s.anchorV || "center";
    if (av === "center") ancY = -blockH / 2;
    else if (av === "bottom") ancY = -blockH;

    // Global transform
    var posX = (s.posX !== undefined ? s.posX : 0.5) * w;
    var posY = (s.posY !== undefined ? s.posY : 0.5) * h;
    var opacity = (s.opacity !== undefined ? s.opacity : 1.0)
        * (inlet.opacity !== undefined ? inlet.opacity : 1.0);

    ctx.save();
    ctx.globalAlpha = opacity;
    ctx.translate(posX, posY);
    if (s.rotation) ctx.rotate(s.rotation * Math.PI / 180);
    var scx = s.scaleX || 1, scy = s.scaleY || 1;
    if (scx !== 1 || scy !== 1) ctx.scale(scx, scy);
    if (s.skewX || s.skewY) {
        ctx.transform(
            1, Math.tan((s.skewY || 0) * Math.PI / 180),
            Math.tan((s.skewX || 0) * Math.PI / 180), 1, 0, 0
        );
    }

    // Apply scroll offset
    if (hasScroll) ctx.translate(scrollOff.x, scrollOff.y);

    var bx = ancX, by = ancY;

    // Background box (fullText scope drawn here; perLine/perWord drawn in their loops)
    if (s.bgEnabled && (!s.bgScope || s.bgScope === "fullText")) {
        var pH = s.bgPaddingH || 0, pV = s.bgPaddingV || 0;
        ctx.save();
        ctx.globalAlpha = (s.bgOpacity !== undefined ? s.bgOpacity : 0.5) * opacity;
        ctx.fillStyle = s.bgColor || "#000000";
        roundRect(ctx, bx - pH, by - pV,
            blockW + pH * 2, blockH + pV * 2, s.bgCornerRadius || 0);
        ctx.fill();
        if (s.bgBorderEnabled && s.bgBorderWidth > 0) {
            ctx.strokeStyle = s.bgBorderColor || "#fff";
            ctx.lineWidth = s.bgBorderWidth;
            ctx.stroke();
        }
        ctx.restore();
    }

    // Texture fill mode: reversed draw order with Canvas compositing
    var isTextureFill = (s.fillType === "texture") && texItem;
    if (isTextureFill) {
        paintTextTextureFill(ctx, w, h, s, inlet, texItem, lines, lineWidths,
            blockW, blockH, lineH, fontSize, fontStr, tracking, bx, by,
            posX, posY, opacity, writeOn, totalChars, elapsed, woMode,
            needsPerChar, hasScroll, scrollOff, hasFadeEdge, ancX, ancY);
        ctx.restore();
        return;
    }

    // Fill style
    var fillStyle;
    var gradScope = s.gradientScope || "fullText";
    var hasColorOverride = inlet.colorOverride && inlet.colorOverride.w > 0;
    if (hasColorOverride) {
        var co = inlet.colorOverride;
        fillStyle = "rgba(" + Math.round(co.x*255) + ","
            + Math.round(co.y*255) + "," + Math.round(co.z*255)
            + "," + co.w + ")";
    } else if ((s.fillType === "linearGradient" || s.fillType === "radialGradient")
               && gradScope === "fullText") {
        fillStyle = createScopedGradient(ctx, s, bx, by, blockW, blockH);
    } else if (s.fillType !== "linearGradient" && s.fillType !== "radialGradient") {
        fillStyle = s.fillColor || "#ffffff";
    }
    // For perLine/perWord/perCharacter gradient scopes, fillStyle is set per element below

    // Collect multi-layer strokes and shadows
    var strokeLayers = getStrokeLayers(s);
    var shadowLayers = getShadowLayers(s);

    ctx.font = fontStr;
    ctx.textBaseline = "top";

    // ======== Per-character rendering path ========
    if (needsPerChar) {
        var chars = layoutCharacters(ctx, lines, lineWidths, tracking, bx, by, lineH, s.hAlign || "center", blockW);
        var lineExtents = []; // track visible extents per line for underline/strikethrough

        for (var ci = 0; ci < chars.length; ci++) {
            var c = chars[ci];
            var prog = charWriteOnProgress(c.gi, totalChars, writeOn, s);

            // Track line extents for decorations
            if (prog > 0 && (s.underline || s.strikethrough)) {
                if (!lineExtents[c.li])
                    lineExtents[c.li] = { sx: c.x, ex: c.x + c.w, y: c.y };
                else
                    lineExtents[c.li].ex = c.x + c.w;
            }

            if (prog <= 0) continue;

            var wave = charWaveOffset(c.gi, elapsed, s);
            var ea = hasFadeEdge
                ? edgeFade(posY + scrollOff.y + c.y - ancY, fontSize,
                    s.scrollFadeEdges, h)
                : 1;

            ctx.save();

            // WriteOn mode effects
            var charAlpha = ea;
            var drawCh = c.ch;

            switch (woMode) {
                case "fade":
                    charAlpha *= prog;
                    break;
                case "scale":
                    var scv = prog;
                    var ccx = c.x + c.w / 2, ccy = c.y + fontSize / 2;
                    ctx.translate(ccx, ccy);
                    ctx.scale(scv, scv);
                    ctx.translate(-ccx, -ccy);
                    break;
                case "slide":
                    ctx.translate(0, (1 - prog) * fontSize);
                    charAlpha *= prog;
                    break;
                case "scramble":
                    if (prog < 1)
                        drawCh = scrambleChar(c.gi, prog, s.writeOnScrambleIter || 5);
                    break;
                default: // typewriter fallback
                    if (prog < 0.5) { ctx.restore(); continue; }
            }

            // Wave offset
            if (wave !== 0) {
                var wp = s.charWaveProperty || "posY";
                if (wp === "posY") ctx.translate(0, wave);
                else if (wp === "posX") ctx.translate(wave, 0);
                else if (wp === "rotation") {
                    var rx = c.x + c.w / 2, ry = c.y + fontSize / 2;
                    ctx.translate(rx, ry);
                    ctx.rotate(wave * Math.PI / 180);
                    ctx.translate(-rx, -ry);
                } else if (wp === "scale") {
                    var ws = 1 + wave / 100;
                    var wx = c.x + c.w / 2, wy = c.y + fontSize / 2;
                    ctx.translate(wx, wy);
                    ctx.scale(ws, ws);
                    ctx.translate(-wx, -wy);
                } else if (wp === "opacity") {
                    var amp = s.charWaveAmplitude || 10;
                    charAlpha *= Math.max(0, 0.5 + wave / (2 * amp));
                }
            }

            // Cascade animation (Resolume-style)
            var cascadeResult = null;
            if (s.charAnimEnabled) {
                var cp = cascadeProgress(chars, ci, elapsed, s);
                cascadeResult = applyCascadeAnim(ctx, c, cp, s, fontSize);
                if (cascadeResult) {
                    charAlpha *= cascadeResult.alpha;
                    if (cascadeResult.ch) drawCh = cascadeResult.ch;
                }
            }

            ctx.globalAlpha = opacity * charAlpha;
            ctx.font = fontStr;
            ctx.textBaseline = "top";

            // Per-character gradient scope
            var charFill = fillStyle;
            if (!hasColorOverride && (s.fillType === "linearGradient" || s.fillType === "radialGradient")) {
                if (gradScope === "perCharacter") {
                    charFill = createScopedGradient(ctx, s, c.x, c.y, c.w, fontSize);
                } else if (gradScope === "perLine") {
                    var lx0 = bx;
                    if ((s.hAlign || "center") === "center") lx0 = bx + (blockW - lineWidths[c.li]) / 2;
                    else if (s.hAlign === "right") lx0 = bx + blockW - lineWidths[c.li];
                    charFill = createScopedGradient(ctx, s, lx0, c.y, lineWidths[c.li], fontSize);
                } else if (gradScope === "perWord") {
                    // Find word bounds around this character
                    var ws = ci, we = ci;
                    while (ws > 0 && chars[ws-1].li === c.li && chars[ws-1].ch !== ' ') ws--;
                    while (we < chars.length-1 && chars[we+1].li === c.li && chars[we+1].ch !== ' ') we++;
                    var wx = chars[ws].x, ww = chars[we].x + chars[we].w - wx;
                    charFill = createScopedGradient(ctx, s, wx, c.y, ww, fontSize);
                }
            }

            // Cascade fill color override
            if (s.charAnimEnabled && s.charAnimFillColor && cascadeResult) {
                var cp2 = cascadeProgress(chars, ci, elapsed, s);
                if (cp2 < 1) charFill = s.charAnimFillColor;
            }

            // Shadows (multi-layer, outermost shadow drawn first)
            for (var si = 0; si < shadowLayers.length; si++) {
                var sh = shadowLayers[si];
                ctx.save();
                var shc = hexToRgba(sh.color, sh.opacity);
                ctx.fillStyle = shc;
                if (sh.blur > 0) {
                    ctx.shadowColor = shc;
                    ctx.shadowBlur = sh.blur;
                    ctx.shadowOffsetX = 0;
                    ctx.shadowOffsetY = 0;
                }
                ctx.fillText(drawCh, c.x + sh.offsetX, c.y + sh.offsetY);
                ctx.restore();
            }

            // Strokes (multi-layer, outermost stroke drawn first)
            for (var si = 0; si < strokeLayers.length; si++) {
                var sl = strokeLayers[si];
                ctx.strokeStyle = sl.color;
                ctx.lineWidth = sl.width;
                ctx.lineJoin = sl.join;
                ctx.lineCap = "round";
                ctx.strokeText(drawCh, c.x, c.y);
            }

            // Fill
            if (s.fillEnabled !== false) {
                ctx.fillStyle = charFill;
                ctx.fillText(drawCh, c.x, c.y);
            }

            ctx.restore();
        }

        // Underline / Strikethrough (drawn per-line across visible chars)
        if (s.underline || s.strikethrough) {
            ctx.strokeStyle = (typeof fillStyle === 'string')
                ? fillStyle : (s.fillColor || "#fff");
            ctx.lineWidth = Math.max(1, fontSize / 20);
            for (var ei = 0; ei < lineExtents.length; ei++) {
                var ext = lineExtents[ei];
                if (!ext) continue;
                if (s.underline) {
                    ctx.beginPath();
                    ctx.moveTo(ext.sx, ext.y + fontSize * 1.05);
                    ctx.lineTo(ext.ex, ext.y + fontSize * 1.05);
                    ctx.stroke();
                }
                if (s.strikethrough) {
                    ctx.beginPath();
                    ctx.moveTo(ext.sx, ext.y + fontSize * 0.45);
                    ctx.lineTo(ext.ex, ext.y + fontSize * 0.45);
                    ctx.stroke();
                }
            }
        }

        // Typewriter cursor
        if (s.writeOnCursor && writeOn > 0 && writeOn < 1) {
            var cursorIdx = Math.min(chars.length - 1,
                Math.floor(writeOn * totalChars));
            if (cursorIdx >= 0 && cursorIdx < chars.length) {
                var cc = chars[cursorIdx];
                var blink = (Math.floor(elapsed * 2) % 2 === 0);
                if (blink) {
                    ctx.fillStyle = fillStyle || s.fillColor || "#fff";
                    ctx.globalAlpha = opacity;
                    ctx.fillText(s.writeOnCursorChar || "\u258c",
                        cc.x + cc.w, cc.y);
                }
            }
        }

    // ======== Fast line-by-line rendering path ========
    } else {
        var charsSoFar = 0;
        // Simple typewriter: compute visible chars
        var visibleChars = (writeOn < 1.0)
            ? Math.ceil(writeOn * totalChars) : totalChars;

        for (var li = 0; li < lines.length; li++) {
            var lt = lines[li];
            var lChars = lt.length;
            var vis = Math.min(lChars, Math.max(0, visibleChars - charsSoFar));
            charsSoFar += lChars;
            if (vis <= 0) continue;
            var drawT = lt.substring(0, vis);
            var drawW = measureLine(ctx, drawT, tracking);

            var lx = bx;
            var ha = s.hAlign || "center";
            if (ha === "center") lx = bx + (blockW - lineWidths[li]) / 2;
            else if (ha === "right") lx = bx + blockW - lineWidths[li];
            var ly = by + li * lineH;

            // Edge fade for scrolling
            var lineAlpha = 1;
            if (hasFadeEdge) {
                lineAlpha = edgeFade(posY + scrollOff.y + ly - ancY,
                    fontSize, s.scrollFadeEdges, h);
                if (lineAlpha <= 0) continue;
            }
            if (lineAlpha < 1) {
                ctx.save();
                ctx.globalAlpha = opacity * lineAlpha;
            }

            // Per-line background (bgScope = perLine)
            if (s.bgEnabled && (s.bgScope === "perLine")) {
                var pH = s.bgPaddingH || 0, pV = s.bgPaddingV || 0;
                ctx.save();
                ctx.globalAlpha = (s.bgOpacity !== undefined ? s.bgOpacity : 0.5) * opacity;
                ctx.fillStyle = s.bgColor || "#000000";
                roundRect(ctx, lx - pH, ly - pV,
                    lineWidths[li] + pH * 2, fontSize + lineH - fontSize + pV * 2,
                    s.bgCornerRadius || 0);
                ctx.fill();
                if (s.bgBorderEnabled && s.bgBorderWidth > 0) {
                    ctx.strokeStyle = s.bgBorderColor || "#fff";
                    ctx.lineWidth = s.bgBorderWidth;
                    ctx.stroke();
                }
                ctx.restore();
            }

            // Per-line gradient scope
            var lineFill = fillStyle;
            if (!hasColorOverride && (s.fillType === "linearGradient" || s.fillType === "radialGradient")
                && gradScope === "perLine") {
                lineFill = createScopedGradient(ctx, s, lx, ly, lineWidths[li], fontSize);
            }

            // Shadows (multi-layer)
            for (var si = 0; si < shadowLayers.length; si++) {
                var sh = shadowLayers[si];
                ctx.save();
                var sc = hexToRgba(sh.color, sh.opacity);
                ctx.fillStyle = sc;
                if (sh.blur > 0) {
                    ctx.shadowColor = sc;
                    ctx.shadowBlur = sh.blur;
                    ctx.shadowOffsetX = 0;
                    ctx.shadowOffsetY = 0;
                }
                drawSegment(ctx, drawT,
                    lx + sh.offsetX, ly + sh.offsetY,
                    tracking, "fill");
                ctx.restore();
            }

            // Strokes (multi-layer, outermost first)
            for (var si = 0; si < strokeLayers.length; si++) {
                var sl = strokeLayers[si];
                ctx.save();
                ctx.strokeStyle = sl.color;
                ctx.lineWidth = sl.width;
                ctx.lineJoin = sl.join;
                ctx.lineCap = "round";
                drawSegment(ctx, drawT, lx, ly, tracking, "stroke");
                ctx.restore();
            }

            // Fill
            if (s.fillEnabled !== false) {
                ctx.fillStyle = lineFill || fillStyle;
                drawSegment(ctx, drawT, lx, ly, tracking, "fill");
            }

            // Underline
            if (s.underline) {
                var ulY = ly + fontSize * 1.05;
                ctx.beginPath();
                ctx.moveTo(lx, ulY);
                ctx.lineTo(lx + drawW, ulY);
                ctx.strokeStyle = (typeof fillStyle === 'string')
                    ? fillStyle : (s.fillColor || "#fff");
                ctx.lineWidth = Math.max(1, fontSize / 20);
                ctx.stroke();
            }

            // Strikethrough
            if (s.strikethrough) {
                var stY = ly + fontSize * 0.45;
                ctx.beginPath();
                ctx.moveTo(lx, stY);
                ctx.lineTo(lx + drawW, stY);
                ctx.strokeStyle = (typeof fillStyle === 'string')
                    ? fillStyle : (s.fillColor || "#fff");
                ctx.lineWidth = Math.max(1, fontSize / 20);
                ctx.stroke();
            }

            if (lineAlpha < 1) ctx.restore();
        }

        // Typewriter cursor (fast path)
        if (s.writeOnCursor && writeOn > 0 && writeOn < 1 && woMode === "typewriter") {
            var cursorCharIdx = Math.floor(writeOn * totalChars);
            var cumul = 0;
            for (var li = 0; li < lines.length; li++) {
                if (cumul + lines[li].length >= cursorCharIdx) {
                    var localIdx = cursorCharIdx - cumul;
                    var clx = bx;
                    if ((s.hAlign || "center") === "center")
                        clx = bx + (blockW - lineWidths[li]) / 2;
                    else if (s.hAlign === "right")
                        clx = bx + blockW - lineWidths[li];
                    var cursorX = clx + measureLine(ctx,
                        lines[li].substring(0, localIdx), tracking);
                    var cursorY = by + li * lineH;
                    var blink = (Math.floor(elapsed * 2) % 2 === 0);
                    if (blink) {
                        ctx.fillStyle = fillStyle || s.fillColor || "#fff";
                        ctx.fillText(s.writeOnCursorChar || "\u258c",
                            cursorX, cursorY);
                    }
                    break;
                }
                cumul += lines[li].length;
            }
        }
    }

    ctx.restore();
}
