import Score
import QtQuick
import "SlideRender.js" as SlideRender

Script {
    id: root

    TextureInlet { id: tex0; objectName: "Image 1" }
    TextureInlet { id: tex1; objectName: "Image 2" }
    TextureInlet { id: tex2; objectName: "Image 3" }
    TextureInlet { id: tex3; objectName: "Image 4" }
    TextureInlet { id: tex4; objectName: "Image 5" }
    TextureInlet { id: tex5; objectName: "Image 6" }
    TextureInlet { id: tex6; objectName: "Image 7" }
    TextureInlet { id: tex7; objectName: "Image 8" }

    FloatSlider {
        id: masterOpacity
        objectName: "Opacity"
        min: 0; max: 1; init: 1
    }

    IntSlider {
        id: slideSelector
        objectName: "Slide"
        min: 1; max: 100; init: 1
    }

    // Inlet items array for indexed access
    property var inletItems: [tex0.item, tex1.item, tex2.item, tex3.item,
                               tex4.item, tex5.item, tex6.item, tex7.item]

    TextureOutlet {
        objectName: "Output"
        item: Item {
            id: outputRoot
            anchors.fill: parent

            // Hidden container: parents inlet items into the scene graph
            // so ShaderEffectSource can render them.
            Item {
                id: inletContainer
                anchors.fill: parent
                visible: false

                Component.onCompleted: {
                    for (var i = 0; i < root.inletItems.length; i++) {
                        var it = root.inletItems[i];
                        if (it) {
                            it.parent = inletContainer;
                            it.width = Qt.binding(function() { return inletContainer.width; });
                            it.height = Qt.binding(function() { return inletContainer.height; });
                        }
                    }
                }
            }

            // Letterbox: fill outside slide area with black
            Rectangle {
                anchors.fill: parent
                color: "#000000"
                visible: {
                    root.stateVersion;
                    var idx = root.activeSlideIndex();
                    return SlideRender.getFormatRatio(root.slides[idx]) > 0;
                }
            }

            // Slide area
            Item {
                id: slideArea
                opacity: masterOpacity.value
                clip: true

                property real formatRatio: {
                    root.stateVersion;
                    var idx = root.activeSlideIndex();
                    return SlideRender.getFormatRatio(root.slides[idx]);
                }

                x: {
                    if (formatRatio <= 0) return 0;
                    var viewRatio = outputRoot.width / Math.max(1, outputRoot.height);
                    if (viewRatio > formatRatio) return (outputRoot.width - outputRoot.height * formatRatio) / 2;
                    return 0;
                }
                y: {
                    if (formatRatio <= 0) return 0;
                    var viewRatio = outputRoot.width / Math.max(1, outputRoot.height);
                    if (viewRatio <= formatRatio) return (outputRoot.height - outputRoot.width / formatRatio) / 2;
                    return 0;
                }
                width: {
                    if (formatRatio <= 0) return outputRoot.width;
                    var viewRatio = outputRoot.width / Math.max(1, outputRoot.height);
                    if (viewRatio > formatRatio) return outputRoot.height * formatRatio;
                    return outputRoot.width;
                }
                height: {
                    if (formatRatio <= 0) return outputRoot.height;
                    var viewRatio = outputRoot.width / Math.max(1, outputRoot.height);
                    if (viewRatio <= formatRatio) return outputRoot.width / formatRatio;
                    return outputRoot.height;
                }

                // ---- Background ----
                Rectangle {
                    id: bgSolid
                    anchors.fill: parent
                    z: 0
                    visible: {
                        root.stateVersion;
                        var s = root.currentSlide();
                        return s.bgType === "solid" || s.bgType === "linearGradient" || s.bgType === "radialGradient";
                    }
                    color: {
                        root.stateVersion;
                        var s = root.currentSlide();
                        return (s.bgType === "solid") ? (s.bgColor || "#000000") : "#000000";
                    }
                    gradient: {
                        root.stateVersion;
                        var s = root.currentSlide();
                        if (s.bgType === "linearGradient" || s.bgType === "radialGradient")
                            return bgGrad;
                        return null;
                    }

                    Gradient {
                        id: bgGrad
                        orientation: {
                            root.stateVersion;
                            var a = root.currentSlide().bgGradAngle || 90;
                            return (a >= 45 && a < 135) || (a >= 225 && a < 315)
                                ? Gradient.Horizontal : Gradient.Vertical;
                        }
                        GradientStop {
                            position: 0
                            color: { root.stateVersion; return root.currentSlide().bgGradStart || "#000000"; }
                        }
                        GradientStop {
                            position: 1
                            color: { root.stateVersion; return root.currentSlide().bgGradEnd || "#333333"; }
                        }
                    }
                }

                // Background texture
                ShaderEffectSource {
                    id: bgTex
                    anchors.fill: parent
                    z: 0
                    visible: {
                        root.stateVersion;
                        return root.currentSlide().bgType === "texture";
                    }
                    sourceItem: {
                        root.stateVersion;
                        var s = root.currentSlide();
                        if (s.bgType !== "texture") return null;
                        var src = s.bgTexSource || 0;
                        return root.inletItems[src] || null;
                    }
                    live: true
                }

                // ---- Objects ----
                Repeater {
                    id: objectRepeater
                    model: {
                        root.stateVersion;
                        var objs = root.currentSlide().objects;
                        return objs ? objs.length : 0;
                    }

                    // Each object is its own Item for proper z-ordering
                    Item {
                        id: objDelegate
                        property int idx: index
                        property var obj: {
                            root.stateVersion;
                            var objs = root.currentSlide().objects;
                            return (objs && idx < objs.length) ? objs[idx] : null;
                        }
                        property real s: slideArea.height / 1080

                        visible: obj && obj.visible !== false
                        x: obj ? obj.x * slideArea.width : 0
                        y: obj ? obj.y * slideArea.height : 0
                        width: obj ? obj.w * slideArea.width : 0
                        height: obj ? obj.h * slideArea.height : 0
                        opacity: obj ? (obj.opacity !== undefined ? obj.opacity : 1) : 1
                        rotation: obj ? (obj.rotation || 0) : 0
                        z: index + 1

                        // ---- Rectangle / Ellipse ----
                        Rectangle {
                            id: shapeFill
                            anchors.fill: parent
                            visible: obj && (obj.type === "rect" || obj.type === "ellipse") && obj.fillEnabled !== false
                            radius: {
                                if (!obj) return 0;
                                if (obj.type === "ellipse") return Math.min(parent.width, parent.height) / 2;
                                return (obj.cornerRadius || 0) * objDelegate.s;
                            }
                            color: {
                                if (!obj || obj.fillType === "linearGradient" || obj.fillType === "radialGradient")
                                    return "transparent";
                                return obj.fillColor || "#ffffff";
                            }
                            gradient: {
                                if (!obj) return null;
                                if (obj.fillType === "linearGradient" || obj.fillType === "radialGradient")
                                    return shapeGrad;
                                return null;
                            }
                            Gradient {
                                id: shapeGrad
                                orientation: {
                                    if (!obj) return Gradient.Vertical;
                                    var a = obj.gradAngle || 90;
                                    return (a >= 45 && a < 135) || (a >= 225 && a < 315)
                                        ? Gradient.Horizontal : Gradient.Vertical;
                                }
                                GradientStop { position: 0; color: obj ? (obj.gradStartColor || "#ffffff") : "#ffffff" }
                                GradientStop { position: 1; color: obj ? (obj.gradEndColor || "#4466ff") : "#4466ff" }
                            }
                        }

                        // Shape stroke
                        Rectangle {
                            anchors.fill: parent
                            visible: obj && (obj.type === "rect" || obj.type === "ellipse") && obj.strokeEnabled
                            radius: shapeFill.radius
                            color: "transparent"
                            border.color: obj ? (obj.strokeColor || "#000000") : "#000000"
                            border.width: obj ? ((obj.strokeWidth || 2) * objDelegate.s) : 0
                        }

                        // ---- Image ----
                        // Fill behind image
                        Rectangle {
                            anchors.fill: parent
                            visible: obj && obj.type === "image" && obj.fillEnabled
                            color: obj ? (obj.fillColor || "#ffffff") : "#ffffff"
                        }

                        // Image content (texture inlet)
                        Item {
                            id: imgCropArea
                            visible: obj && obj.type === "image" && !(obj.imageFileUrl && obj.imageFileUrl.length > 0)
                            clip: true
                            x: obj ? (obj.imageCropL || 0) * parent.width : 0
                            y: obj ? (obj.imageCropT || 0) * parent.height : 0
                            width: obj ? parent.width * (1 - (obj.imageCropL || 0) - (obj.imageCropR || 0)) : 0
                            height: obj ? parent.height * (1 - (obj.imageCropT || 0) - (obj.imageCropB || 0)) : 0

                            ShaderEffectSource {
                                id: imgTex
                                sourceItem: {
                                    if (!obj || obj.type !== "image") return null;
                                    if (obj.imageFileUrl && obj.imageFileUrl.length > 0) return null;
                                    var src = obj.imageSource || 0;
                                    return root.inletItems[src] || null;
                                }
                                live: true

                                // Fit mode sizing
                                property real srcW: sourceItem ? Math.max(1, sourceItem.width) : 1
                                property real srcH: sourceItem ? Math.max(1, sourceItem.height) : 1
                                property string fitMode: obj ? (obj.imageFit || "cover") : "cover"

                                x: fitMode === "stretch" ? 0 : (imgCropArea.width - width) / 2
                                y: fitMode === "stretch" ? 0 : (imgCropArea.height - height) / 2
                                width: {
                                    if (fitMode === "stretch") return imgCropArea.width;
                                    var scale = fitMode === "contain"
                                        ? Math.min(imgCropArea.width / srcW, imgCropArea.height / srcH)
                                        : Math.max(imgCropArea.width / srcW, imgCropArea.height / srcH);
                                    return srcW * scale;
                                }
                                height: {
                                    if (fitMode === "stretch") return imgCropArea.height;
                                    var scale = fitMode === "contain"
                                        ? Math.min(imgCropArea.width / srcW, imgCropArea.height / srcH)
                                        : Math.max(imgCropArea.width / srcW, imgCropArea.height / srcH);
                                    return srcH * scale;
                                }
                            }
                        }

                        // Image content (file-based URL) - uses Canvas for this one object
                        Canvas {
                            id: fileImgCanvas
                            anchors.fill: parent
                            visible: obj && obj.type === "image" && obj.imageFileUrl && obj.imageFileUrl.length > 0
                            renderStrategy: Canvas.Cooperative
                            property int ver: root.stateVersion
                            onVerChanged: if (visible) requestPaint()
                            onImageLoaded: requestPaint()
                            onPaint: {
                                if (!obj || !visible) return;
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                var url = obj.imageFileUrl;
                                if (url && url.length > 0) {
                                    if (!isImageLoaded(url)) { loadImage(url); return; }
                                    try { ctx.drawImage(url, 0, 0, width, height); } catch(e) {}
                                }
                            }
                        }

                        // Image border
                        Rectangle {
                            anchors.fill: parent
                            visible: obj && obj.type === "image" && (obj.imageBorderWidth || 0) > 0
                            color: "transparent"
                            border.color: obj ? (obj.imageBorderColor || "#000000") : "#000000"
                            border.width: obj ? ((obj.imageBorderWidth || 0) * objDelegate.s) : 0
                        }

                        // Image outer stroke
                        Rectangle {
                            anchors.fill: parent
                            visible: obj && obj.type === "image" && obj.strokeEnabled
                            color: "transparent"
                            border.color: obj ? (obj.strokeColor || "#000000") : "#000000"
                            border.width: obj ? ((obj.strokeWidth || 2) * objDelegate.s) : 0
                        }

                        // ---- Text ----
                        // Text fill background
                        Rectangle {
                            anchors.fill: parent
                            visible: obj && obj.type === "text" && obj.fillEnabled
                            color: obj ? (obj.fillColor || "transparent") : "transparent"
                        }

                        // Text stroke background
                        Rectangle {
                            anchors.fill: parent
                            visible: obj && obj.type === "text" && obj.strokeEnabled
                            color: "transparent"
                            border.color: obj ? (obj.strokeColor || "#000000") : "#000000"
                            border.width: obj ? ((obj.strokeWidth || 2) * objDelegate.s) : 0
                        }

                        // Text content
                        Text {
                            anchors.fill: parent
                            visible: obj && obj.type === "text"
                            text: obj ? (obj.text || "") : ""
                            font.family: obj ? (obj.fontFamily || "IBM Plex Sans") : "IBM Plex Sans"
                            font.pixelSize: obj ? ((obj.fontSize || 36) * objDelegate.s) : 36
                            font.bold: obj ? obj.fontWeight === "bold" : false
                            font.italic: obj ? obj.fontStyle === "italic" : false
                            color: obj ? (obj.textColor || "#ffffff") : "#ffffff"
                            wrapMode: obj && obj.wordWrap !== false ? Text.WordWrap : Text.NoWrap
                            lineHeight: obj ? (obj.lineSpacing || 1.3) : 1.3
                            lineHeightMode: Text.ProportionalHeight

                            horizontalAlignment: {
                                if (!obj) return Text.AlignHCenter;
                                switch (obj.hAlign) {
                                    case "left": return Text.AlignLeft;
                                    case "right": return Text.AlignRight;
                                    default: return Text.AlignHCenter;
                                }
                            }
                            verticalAlignment: {
                                if (!obj) return Text.AlignVCenter;
                                switch (obj.vAlign) {
                                    case "top": return Text.AlignTop;
                                    case "bottom": return Text.AlignBottom;
                                    default: return Text.AlignVCenter;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    property var slides: [SlideRender.defaultSlideState()]
    property var slideState: slides[0]
    property int stateVersion: 0
    property real lastSentW: 0
    property real lastSentH: 0
    property real prevOpacity: -1
    property int prevSlideIdx: -1

    function activeSlideIndex() {
        var idx = slideSelector.value - 1;
        return Math.max(0, Math.min(idx, root.slides.length - 1));
    }

    function currentSlide() {
        var idx = root.activeSlideIndex();
        return root.slides[idx] || SlideRender.defaultSlideState();
    }

    function getInletItems() {
        return root.inletItems;
    }

    function hasImageSource() {
        var state = root.currentSlide();
        if (state.bgType === "texture") return true;
        var objs = state.objects;
        if (!objs) return false;
        for (var i = 0; i < objs.length; i++) {
            if (objs[i].type === "image") return true;
        }
        return false;
    }

    function loadMultiSlideState(s) {
        if (s.slides && Array.isArray(s.slides)) {
            root.slides = s.slides.map(function(sl) {
                return SlideRender.mergeState(SlideRender.defaultSlideState(), sl);
            });
        } else {
            root.slides = [SlideRender.mergeState(SlideRender.defaultSlideState(), s)];
        }
        root.slideState = root.slides[root.activeSlideIndex()];
    }

    loadState: function(state) {
        if (state && state.slideState) {
            try {
                var s = typeof state.slideState === "string"
                    ? JSON.parse(state.slideState) : state.slideState;
                root.loadMultiSlideState(s);
            } catch(e) {
                root.slides = [SlideRender.defaultSlideState()];
                root.slideState = root.slides[0];
            }
        } else {
            root.slides = [SlideRender.defaultSlideState()];
            root.slideState = root.slides[0];
        }
        root.stateVersion++;
    }

    stateUpdated: function(k, v) {
        if (k === "slideState") {
            try {
                var s = typeof v === "string" ? JSON.parse(v) : v;
                root.loadMultiSlideState(s);
            } catch(e) { return; }
            root.stateVersion++;
        }
    }

    uiEvent: function(message) {
        if (!message) return;
        if (message.type === "updateSlides") {
            root.slides = (message.slides || [SlideRender.defaultSlideState()]).map(
                function(sl) {
                    return SlideRender.mergeState(SlideRender.defaultSlideState(), sl);
                });
            root.slideState = root.slides[root.activeSlideIndex()];
            root.stateVersion++;
        }
        else if (message.type === "updateSlide") {
            root.slides = [SlideRender.mergeState(
                SlideRender.defaultSlideState(), message.state || {})];
            root.slideState = root.slides[0];
            root.stateVersion++;
        }
    }

    tick: function(token, state) {
        var changed = false;

        if (masterOpacity.value !== root.prevOpacity) {
            root.prevOpacity = masterOpacity.value;
            changed = true;
        }

        var curIdx = root.activeSlideIndex();
        if (curIdx !== root.prevSlideIdx) {
            root.prevSlideIdx = curIdx;
            root.slideState = root.slides[curIdx];
            changed = true;
            uiSend({ type: "currentSlide", index: curIdx });
        }

        if (root.hasImageSource()) changed = true;

        if (changed) root.stateVersion++;

        var cw = slideArea.width, ch = slideArea.height;
        if (cw !== root.lastSentW || ch !== root.lastSentH) {
            root.lastSentW = cw;
            root.lastSentH = ch;
            uiSend({ type: "renderSize", width: cw, height: ch });
        }
    }

    start: function() {}
}
