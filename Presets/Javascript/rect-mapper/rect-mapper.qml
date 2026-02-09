import Score
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers

Script {
    id: root

    TextureInlet {
        id: tex0
        objectName: "Texture 1"
    }
    TextureInlet {
        id: tex1
        objectName: "Texture 2"
    }
    TextureInlet {
        id: tex2
        objectName: "Texture 3"
    }
    TextureInlet {
        id: tex3
        objectName: "Texture 4"
    }
    TextureInlet {
        id: tex4
        objectName: "Texture 5"
    }
    TextureInlet {
        id: tex5
        objectName: "Texture 6"
    }
    TextureInlet {
        id: tex6
        objectName: "Texture 7"
    }
    TextureInlet {
        id: tex7
        objectName: "Texture 8"
    }

    IntSlider {
        id: subdiv
        min: 4
        max: 64
        init: 12
    }
    ValueInlet {
        id: rectsIn
        objectName: "Quads"
    }

    readonly property string rootPath: Util.settings("d6966670-f69f-48d0-96f6-72a5e2190cbc").RootPath + "/packages/default/Presets/Javascript/rect-mapper/"

    Component.onCompleted: console.log("rootPath: ", rootPath)
    TextureOutlet {
        objectName: "Output"
        item: View3D {
            id: renderRoot
            anchors.fill: parent

            environment: SceneEnvironment {
                clearColor: "black"
                backgroundMode: SceneEnvironment.Color
                antialiasingQuality: SceneEnvironment.High
                antialiasingMode: SceneEnvironment.MSAA
            }

            OrthographicCamera {
                id: camera
                z: 100
            }

            Texture {
                id: texSrc0
                sourceItem: tex0.item
            }
            Texture {
                id: texSrc1
                sourceItem: tex1.item
            }
            Texture {
                id: texSrc2
                sourceItem: tex2.item
            }
            Texture {
                id: texSrc3
                sourceItem: tex3.item
            }
            Texture {
                id: texSrc4
                sourceItem: tex4.item
            }
            Texture {
                id: texSrc5
                sourceItem: tex5.item
            }
            Texture {
                id: texSrc6
                sourceItem: tex6.item
            }
            Texture {
                id: texSrc7
                sourceItem: tex7.item
            }

            Repeater3D {
                model: root.rects.length

                Model {
                    id: quadModel
                    property int idx: index

                    property var meshData: root.computeMesh(quadModel.idx)
                    geometry: ProceduralMesh {
                        positions: quadModel.meshData.positions
                        normals: quadModel.meshData.normals
                        uv0s: quadModel.meshData.uvs
                        indexes: quadModel.meshData.indices
                    }

                    materials: CustomMaterial {
                        shadingMode: CustomMaterial.Unshaded
                        cullMode: CustomMaterial.NoCulling

                        readonly property var blendModes: [
                            CustomMaterial.Zero, CustomMaterial.One,
                            CustomMaterial.SrcColor, CustomMaterial.OneMinusSrcColor,
                            CustomMaterial.DstColor, CustomMaterial.OneMinusDstColor,
                            CustomMaterial.SrcAlpha, CustomMaterial.OneMinusSrcAlpha,
                            CustomMaterial.DstAlpha, CustomMaterial.OneMinusDstAlpha
                        ]
                        sourceBlend: blendModes[root.getSrcBlend(quadModel.idx)]
                        destinationBlend: blendModes[root.getDstBlend(quadModel.idx)]

                        property TextureInput srcTex: TextureInput {
                            texture: root.getTexSrc(quadModel.idx)
                        }
                        property real blendTop: root.getBlend(quadModel.idx, "top")
                        property real blendBottom: root.getBlend(quadModel.idx, "bottom")
                        property real blendLeft: root.getBlend(quadModel.idx, "left")
                        property real blendRight: root.getBlend(quadModel.idx, "right")
                        property real blendGamma: root.getBlendGamma(quadModel.idx)

                        vertexShader: `${rootPath}/edgeblend.vert`
                        fragmentShader: `${rootPath}/edgeblend.frag`
                    }
                }
            }
        }
    }

    property var rects: []
    property int stateVersion: 0
    property real lastSentW: 0
    property real lastSentH: 0
    readonly property int subdivisions: subdiv.value

    // Per-quad mesh cache: avoids recomputing geometry for unchanged quads
    property var meshCacheData: []
    property var meshCacheKeys: []

    function computeMesh(idx) {
        if (idx < 0 || idx >= rects.length || !rects[idx].corners)
            return {
                positions: [],
                normals: [],
                uvs: [],
                indices: []
            };

        var c = rects[idx].corners;
        var w = renderRoot.width;
        var h = renderRoot.height;
        var N = root.subdivisions;

        // Build cache key from all inputs that affect the mesh
        var key = N + ":" + w + ":" + h + ":" + c[0][0] + "," + c[0][1] + "," + c[1][0] + "," + c[1][1] + "," + c[2][0] + "," + c[2][1] + "," + c[3][0] + "," + c[3][1];

        if (idx < meshCacheKeys.length && meshCacheKeys[idx] === key)
            return meshCacheData[idx];

        var z = idx * 0.1;

        // corners: c[0]=TL, c[1]=TR, c[2]=BR, c[3]=BL
        var positions = [];
        var normals = [];
        var uvs = [];
        var indices = [];

        // Generate (N+1)x(N+1) vertices via bilinear interpolation
        for (var row = 0; row <= N; row++) {
            var v = row / N;
            for (var col = 0; col <= N; col++) {
                var u = col / N;

                // Bilinear interpolation of the 4 corners
                var nx = (1 - u) * (1 - v) * c[0][0] + u * (1 - v) * c[1][0] + u * v * c[2][0] + (1 - u) * v * c[3][0];
                var ny = (1 - u) * (1 - v) * c[0][1] + u * (1 - v) * c[1][1] + u * v * c[2][1] + (1 - u) * v * c[3][1];

                positions.push(Qt.vector3d((nx - 0.5) * w, (0.5 - ny) * h, z));
                normals.push(Qt.vector3d(0, 0, 1));
                uvs.push(Qt.vector2d(u, 1 - v));
            }
        }

        // Generate triangle indices for each grid cell
        var stride = N + 1;
        for (var row = 0; row < N; row++) {
            for (var col = 0; col < N; col++) {
                var a = row * stride + col;
                var b = row * stride + col + 1;
                var c2 = (row + 1) * stride + col + 1;
                var d = (row + 1) * stride + col;
                indices.push(a, d, c2);
                indices.push(a, c2, b);
            }
        }

        var result = {
            positions: positions,
            normals: normals,
            uvs: uvs,
            indices: indices
        };

        // Store in per-quad cache
        while (meshCacheData.length <= idx) {
            meshCacheData.push(null);
            meshCacheKeys.push("");
        }
        meshCacheData[idx] = result;
        meshCacheKeys[idx] = key;

        return result;
    }

    function getBlend(idx, edge) {
        if (idx < 0 || idx >= rects.length)
            return 0;
        var b = rects[idx].blend;
        if (!b)
            return 0;
        return b[edge] || 0;
    }

    function getBlendGamma(idx) {
        if (idx < 0 || idx >= rects.length)
            return 1.0;
        return rects[idx].blendGamma || 1.0;
    }

    function getSrcBlend(idx) {
        if (idx < 0 || idx >= rects.length) return 1; // One
        var v = rects[idx].srcBlend;
        return (typeof v === 'number') ? v : 1;
    }

    function getDstBlend(idx) {
        if (idx < 0 || idx >= rects.length) return 7; // OneMinusSrcAlpha
        var v = rects[idx].dstBlend;
        return (typeof v === 'number') ? v : 7;
    }

    function getTexSrc(idx) {
        if (idx < 0 || idx >= rects.length)
            return texSrc0;
        var s = rects[idx].source || 0;
        var srcs = [texSrc0, texSrc1, texSrc2, texSrc3, texSrc4, texSrc5, texSrc6, texSrc7];
        return srcs[Math.max(0, Math.min(7, s))];
    }

    function loadRects(data) {
        return data || [];
    }

    function cornersEqual(a, b) {
        if (!a || !b)
            return false;
        for (var i = 0; i < 4; i++)
            if (a[i][0] !== b[i][0] || a[i][1] !== b[i][1])
                return false;
        return true;
    }

    function rectEqual(a, b) {
        if (!a || !b)
            return false;
        if (!a.corners || !b.corners)
            return false;
        if (!cornersEqual(a.corners, b.corners))
            return false;
        if ((a.source || 0) !== (b.source || 0))
            return false;
        var ab = a.blend || {}, bb = b.blend || {};
        if ((ab.top || 0) !== (bb.top || 0) || (ab.bottom || 0) !== (bb.bottom || 0) || (ab.left || 0) !== (bb.left || 0) || (ab.right || 0) !== (bb.right || 0))
            return false;
        if ((a.blendGamma || 1) !== (b.blendGamma || 1))
            return false;
        if ((a.srcBlend === undefined ? 1 : a.srcBlend) !== (b.srcBlend === undefined ? 1 : b.srcBlend))
            return false;
        if ((a.dstBlend === undefined ? 7 : a.dstBlend) !== (b.dstBlend === undefined ? 7 : b.dstBlend))
            return false;
        return true;
    }

    // Diff incoming data against current rects.
    // Returns true if anything changed.
    function applyQuadsDiff(newData) {
        var old = root.rects;

        if (old.length !== newData.length) {
            root.rects = newData;
            meshCacheData = [];
            meshCacheKeys = [];
            return true;
        }

        // Same count: check if any quad actually differs
        for (var i = 0; i < newData.length; i++) {
            if (!rectEqual(old[i], newData[i])) {
                // Replace the whole array so QML detects the property change;
                // the per-quad mesh cache prevents recomputing unchanged quads.
                root.rects = newData;
                return true;
            }
        }
        return false;
    }

    loadState: function (state) {
        if (state && state.mapperState) {
            try {
                var s = typeof state.mapperState === "string" ? JSON.parse(state.mapperState) : state.mapperState;
                root.rects = root.loadRects(s);
            } catch (e) {
                root.rects = [];
            }
        } else {
            root.rects = [];
        }
        root.stateVersion++;
    }

    stateUpdated: function (k, v) {
        if (k === "mapperState") {
            try {
                var s = typeof v === "string" ? JSON.parse(v) : v;
                root.rects = root.loadRects(Array.isArray(s) ? s : []);
            } catch (e) {
                return;
            }
            root.stateVersion++;
        }
    }

    uiEvent: function (message) {
        if (!message)
            return;
        if (message.type === "updateRects") {
            root.rects = message.rects || [];
            root.stateVersion++;
        }
    }

    tick: function (token, state) {
        // Apply quads from ValueInlet if present, using diff to avoid unnecessary recomputation
        if (typeof rectsIn.value !== 'undefined' && rectsIn.value !== null) {
            var v = rectsIn.value;
            try {
                var data = typeof v === "string" ? JSON.parse(v) : v;
                if (Array.isArray(data)) {
                    if (root.applyQuadsDiff(data))
                        root.stateVersion++;
                }
            } catch (e) {}
        }

        var w = renderRoot.width;
        var h = renderRoot.height;
        if (w !== root.lastSentW || h !== root.lastSentH) {
            root.lastSentW = w;
            root.lastSentH = h;
            uiSend({
                type: "renderSize",
                width: w,
                height: h
            });
        }
    }

    start: function () {}
}
