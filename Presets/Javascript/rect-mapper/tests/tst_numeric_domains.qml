// QT_QPA_PLATFORM=offscreen qmltestrunner -input tests/tst_numeric_domains.qml
import QtQuick
import QtTest
import "../ShapeData.js" as ShapeData

TestCase {
    name: "MapperNumericDomains"

    function test_unsafe_inputs_cannot_overflow_fade_or_uv_division() {
        var values = [-100, 0, NaN, Infinity, -Infinity, 1e300, 1e-300, "2", null];
        for (var value of values) {
            var shape = ShapeData.createQuad(0);
            shape.blendGamma = value;
            shape.uvScale = [value, value];
            var safe = ShapeData.normalizeShapes([shape])[0];
            // Include the float conversion performed by the shader uniforms.
            var gamma = Qt.vector2d(safe.blendGamma, 0).x;
            var scale = Qt.vector2d(safe.uvScale[0], safe.uvScale[1]);
            var alpha = Math.pow(0.001, gamma);
            verify(isFinite(alpha) && alpha > 0 && alpha <= 1);
            verify(isFinite(0 / scale.x) && isFinite(1 / scale.y));
        }
    }

    function test_valid_gamma_and_mirrored_uv_mapping_are_preserved() {
        var shape = ShapeData.createQuad(0);
        shape.blendGamma = 2.2;
        shape.uvScale = [-2, 0.25];
        var safe = ShapeData.normalizeShapes([shape])[0];
        compare(Math.pow(0.5, safe.blendGamma), Math.pow(0.5, 2.2));
        compare(0.25 / safe.uvScale[0], -0.125);
        compare(0.25 / safe.uvScale[1], 1);
    }

    function test_retained_invalid_input_is_not_a_new_render_edit() {
        var incoming = [ShapeData.createQuad(0)];
        incoming[0].blendGamma = -100;
        incoming[0].uvScale = [0, -Infinity];
        var rendered = ShapeData.normalizeShapes(incoming);
        verify(!ShapeData.shapesDiffer(rendered, incoming));
        // Normalization must not rewrite producer-owned messages.
        compare(incoming[0].blendGamma, -100);
        compare(incoming[0].uvScale[0], 0);
        compare(incoming[0].uvScale[1], -Infinity);
        incoming[0].blendGamma = 2.2;
        verify(ShapeData.shapesDiffer(rendered, incoming));
        verify(Math.pow(0.001, rendered[0].blendGamma) <= 1);
        rendered = ShapeData.normalizeShapes(incoming);
        verify(!ShapeData.shapesDiffer(rendered, incoming));
    }
}
