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

    TextureOutlet {
        objectName: "Output"
        item: Item {
            id: outputRoot
            anchors.fill: parent

            // Letterbox: fill outside area with black
            Rectangle {
                anchors.fill: parent
                color: "#000000"
                visible: {
                    root.stateVersion;
                    var idx = root.activeSlideIndex();
                    return SlideRender.getFormatRatio(root.slides[idx]) > 0;
                }
            }

            Canvas {
                id: slideCanvas
                renderStrategy: Canvas.Cooperative

                // Compute position/size based on slide format
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

                property int ver: root.stateVersion
                onVerChanged: requestPaint()

                onImageLoaded: requestPaint()

                onPaint: {
                    var idx = root.activeSlideIndex();
                    var currentSlide = root.slides[idx];

                    // Load any file-based images
                    var objs = currentSlide.objects;
                    if (objs) {
                        for (var i = 0; i < objs.length; i++) {
                            var url = objs[i].imageFileUrl;
                            if (url && url.length > 0 && !isImageLoaded(url)) {
                                loadImage(url);
                            }
                        }
                    }

                    var ctx = getContext("2d");
                    var inlets = root.getInletItems();
                    SlideRender.paintSlide(ctx, width, height,
                        currentSlide, inlets, masterOpacity.value);
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

    function getInletItems() {
        return [tex0.item, tex1.item, tex2.item, tex3.item,
                tex4.item, tex5.item, tex6.item, tex7.item];
    }

    function hasImageSource() {
        var idx = root.activeSlideIndex();
        var state = root.slides[idx];
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
        // Backward compat for old single-slide message
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

        // Detect slide selector change
        var curIdx = root.activeSlideIndex();
        if (curIdx !== root.prevSlideIdx) {
            root.prevSlideIdx = curIdx;
            root.slideState = root.slides[curIdx];
            changed = true;
            uiSend({ type: "currentSlide", index: curIdx });
        }

        // Always repaint when image/video sources are used (video changes every frame)
        if (root.hasImageSource()) changed = true;

        if (changed) root.stateVersion++;

        var cw = slideCanvas.width, ch = slideCanvas.height;
        if (cw !== root.lastSentW || ch !== root.lastSentH) {
            root.lastSentW = cw;
            root.lastSentH = ch;
            uiSend({ type: "renderSize", width: cw, height: ch });
        }
    }

    start: function() {}
}
