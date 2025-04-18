import Score
import QtQuick

Script {
    
  FloatSlider {
    id: pen_size
    objectName: "Pen size"
    min: 0.01
    max: 100
  }
  FloatSlider {
    id: quality
    objectName: "Drawing quality"
    min: 1
    max: 20
  }
  HSVSlider {
    id: stroke_color
    objectName: "Stroke color"
  }

  /* Disabled for now, does not work too well
  Enum {
    id: composition_mode
    objectName: "Composition mode"
    choices: ["source-over", "source-out", "source-in", "source-atop", "destination-atop", "destination-in", "destination-out", "destination-over", "lighter", "copy", "xor", "qt-clear", "qt-destination", "qt-multiply", "qt-screen", "qt-overlay", "qt-darken", "qt-lighten", "qt-color-dodge", "qt-color-burn", "qt-hard-light", "qt-soft-light", "qt-difference", "qt-exclusion"]
  }
  */
  
  TextureOutlet {
    item: Canvas {
      id: canvas
      anchors.fill: parent
      property bool erasing: false
      property var points: []

        onPaint: {
          var ctx = getContext("2d");
          ctx.lineWidth = pen_size.value;
          if(canvas.erasing)
          {
            ctx.globalCompositeOperation = 'destination-out'; 
            ctx.strokeStyle = Qt.rgba(0,0,0,1);
          } 
          else
          {
            ctx.globalCompositeOperation = 'source-over'; 
            ctx.strokeStyle = Qt.rgba(stroke_color.value.x, stroke_color.value.y, stroke_color.value.z, stroke_color.value.w);
          }

          var interpolated = getInterpolatedPoints(points, quality.value);
          if (interpolated.length > 1)
          {
            ctx.beginPath();
            ctx.moveTo(interpolated[0].x, interpolated[0].y);
            for (var i = 1; i < interpolated.length; ++i) {
              ctx.lineTo(interpolated[i].x, interpolated[i].y);
            }
            ctx.stroke();
          }
        }

        MouseArea {
          id: area
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          anchors.fill: parent

          onPressed: {
            canvas.erasing = (mouse.button == Qt.RightButton);
            canvas.points = [{ x: mouseX, y: mouseY }]
          }

          onPositionChanged: {
            canvas.points.push({ x: mouseX, y: mouseY })
            canvas.requestPaint()
          }

          onReleased: {
            canvas.points = []
          }
        }

        function getInterpolatedPoints(pts, stepsPerSegment)
        {
          if (pts.length < 2 || stepsPerSegment <= 2) return pts;
          var result = []

          function interpolateSegment(p0, p1, p2, p3)
          {
            for (var i = 0; i <= stepsPerSegment; ++i) {
              const t = i / stepsPerSegment;
              const tt = t * t;
              const ttt = tt * t;
              const x = 0.5 * ((2 * p1.x) + (-p0.x + p2.x) * t + (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * tt + (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * ttt);
              const y = 0.5 * ((2 * p1.y) + (-p0.y + p2.y) * t + (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * tt + (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * ttt);
              result.push({ x: x, y: y });
            }
          }

          for (var i = 0; i < pts.length - 1; ++i) {
            var p0 = pts[i - 1 < 0 ? i : i - 1];
            var p1 = pts[i];
            var p2 = pts[i + 1];
            var p3 = pts[i + 2 > pts.length - 1 ? pts.length - 1 : i + 2];
            interpolateSegment(p0, p1, p2, p3);
          }

          return result;
        }
      }
    }

    tick: function(token, state) {   }
}