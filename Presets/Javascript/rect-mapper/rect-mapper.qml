import Score
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import "MeshUtils.js" as MeshUtils
import "ShapeData.js" as ShapeData

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
        objectName: "Subdivisions"
        min: 4
        max: 64
        init: 12
    }
    ValueInlet {
        id: rectsIn
        objectName: "Quads"
    }

    readonly property string rootPath: "file://" + Util.settings("d6966670-f69f-48d0-96f6-72a5e2190cbc").RootPath + "/packages/default/Presets/Javascript/rect-mapper/"
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
                    visible: root.getVisible(quadModel.idx)

                    property var meshData: {
                        // Explicit dependencies so QML re-evaluates on changes
                        var _v = root.stateVersion;
                        var _s = root.subdivisions;
                        return root.computeMesh(quadModel.idx);
                    }
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
                        property real shapeOpacity: root.getOpacity(quadModel.idx)
                        property vector2d uvOffset: root.getUvOffset(quadModel.idx)
                        property vector2d uvScale: root.getUvScale(quadModel.idx)
                        property real uvRotation: root.getUvRotation(quadModel.idx)
                        property real manualUv: root.isManualUv(quadModel.idx)

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

    // Per-shape mesh cache
    property var meshCacheData: []
    property var meshCacheKeys: []

    function computeMesh(idx) {
        if (idx < 0 || idx >= rects.length || !rects[idx].vertices)
            return { positions: [], normals: [], uvs: [], indices: [] };

        var shape = rects[idx];
        var w = renderRoot.width;
        var h = renderRoot.height;
        var N = root.subdivisions;
        var z = idx * 0.1;

        var key = MeshUtils.meshCacheKey(shape, N, w, h);
        if (idx < meshCacheKeys.length && meshCacheKeys[idx] === key)
            return meshCacheData[idx];

        var result;
        var uvMode = shape.uvMode || "auto";
        var isSimpleQuad = (shape.vertices.length === 4 && (!shape.edges || shape.edges.length === 0));

        if (uvMode === "interpolated") {
            // Interpolated: quads use existing warp paths; non-quads force warped mesh
            if (isSimpleQuad && shape.warp && shape.gridOffsets) {
                result = MeshUtils.computeQuadMeshWithGrid(shape.vertices, shape.gridW || 4, shape.gridH || 4, shape.gridOffsets, N, w, h, z);
            } else if (isSimpleQuad) {
                result = MeshUtils.computeQuadMesh(shape.vertices, N, w, h, z);
            } else {
                result = MeshUtils.computePolygonMeshWarped(shape.vertices, shape.edges, N, w, h, z);
            }
        } else {
            // auto, aligned, manual: use standard logic
            if (isSimpleQuad && shape.warp && shape.gridOffsets) {
                result = MeshUtils.computeQuadMeshWithGrid(shape.vertices, shape.gridW || 4, shape.gridH || 4, shape.gridOffsets, N, w, h, z);
            } else if (isSimpleQuad && shape.warp) {
                result = MeshUtils.computeQuadMesh(shape.vertices, N, w, h, z);
            } else if (shape.warp) {
                result = MeshUtils.computePolygonMeshWarped(shape.vertices, shape.edges, N, w, h, z);
            } else {
                result = MeshUtils.computePolygonMesh(shape.vertices, shape.edges, N, w, h, z);
            }
        }

        // Aligned UV mode: override UVs to axis-aligned bounding box
        if (uvMode === "aligned") {
            result = MeshUtils.recomputeAlignedUVs(result, w, h);
        }

        while (meshCacheData.length <= idx) {
            meshCacheData.push(null);
            meshCacheKeys.push("");
        }
        meshCacheData[idx] = result;
        meshCacheKeys[idx] = key;

        return result;
    }

    function getBlend(idx, edge) {
        if (idx < 0 || idx >= rects.length) return 0;
        var b = rects[idx].blend;
        return b ? (b[edge] || 0) : 0;
    }

    function getBlendGamma(idx) {
        if (idx < 0 || idx >= rects.length) return 1.0;
        return rects[idx].blendGamma || 1.0;
    }

    function getSrcBlend(idx) {
        if (idx < 0 || idx >= rects.length) return 1;
        var v = rects[idx].srcBlend;
        return (typeof v === 'number') ? v : 1;
    }

    function getDstBlend(idx) {
        if (idx < 0 || idx >= rects.length) return 7;
        var v = rects[idx].dstBlend;
        return (typeof v === 'number') ? v : 7;
    }

    function getTexSrc(idx) {
        if (idx < 0 || idx >= rects.length) return texSrc0;
        var s = rects[idx].source || 0;
        var srcs = [texSrc0, texSrc1, texSrc2, texSrc3, texSrc4, texSrc5, texSrc6, texSrc7];
        return srcs[Math.max(0, Math.min(7, s))];
    }

    function getOpacity(idx) {
        if (idx < 0 || idx >= rects.length) return 1.0;
        var v = rects[idx].opacity;
        return (v !== undefined) ? v : 1.0;
    }

    function getVisible(idx) {
        if (idx < 0 || idx >= rects.length) return true;
        var v = rects[idx].visible;
        return (v !== undefined) ? v : true;
    }

    function getUvOffset(idx) {
        if (idx < 0 || idx >= rects.length) return Qt.vector2d(0, 0);
        var o = rects[idx].uvOffset || [0, 0];
        return Qt.vector2d(o[0], o[1]);
    }

    function getUvScale(idx) {
        if (idx < 0 || idx >= rects.length) return Qt.vector2d(1, 1);
        var s = rects[idx].uvScale || [1, 1];
        return Qt.vector2d(s[0], s[1]);
    }

    function getUvRotation(idx) {
        if (idx < 0 || idx >= rects.length) return 0;
        return rects[idx].uvRotation || 0;
    }

    function isManualUv(idx) {
        if (idx < 0 || idx >= rects.length) return 0.0;
        return (rects[idx].uvMode === "manual") ? 1.0 : 0.0;
    }

    loadState: function (state) {
        if (state && state.mapperState) {
            try {
                var s = typeof state.mapperState === "string" ? JSON.parse(state.mapperState) : state.mapperState;
                root.rects = s || [];
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
                root.rects = Array.isArray(s) ? s : [];
            } catch (e) {
                return;
            }
            root.stateVersion++;
        }
    }

    uiEvent: function (message) {
        if (!message) return;
        if (message.type === "updateRects") {
            root.rects = message.rects || [];
            root.stateVersion++;
        }
    }

    tick: function (token, state) {
        if (typeof rectsIn.value !== 'undefined' && rectsIn.value !== null) {
            var v = rectsIn.value;
            try {
                var data = typeof v === "string" ? JSON.parse(v) : v;
                if (Array.isArray(data)) {
                    if (ShapeData.shapesDiffer(root.rects, data)) {
                        root.rects = data;
                        meshCacheData = [];
                        meshCacheKeys = [];
                        root.stateVersion++;
                    }
                }
            } catch (e) {}
        }

        var w = renderRoot.width;
        var h = renderRoot.height;
        if (w !== root.lastSentW || h !== root.lastSentH) {
            root.lastSentW = w;
            root.lastSentH = h;
            uiSend({ type: "renderSize", width: w, height: h });
        }
    }

    start: function () {}
}
