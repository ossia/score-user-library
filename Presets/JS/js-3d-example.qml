import Score as Score
import QtQuick
import QtQuick3D

// This shows how to use Qt Quick 3D content inside a JS object.
// The example is trivially ported from: https://doc.qt.io/qt-6/qtquick3d-intro-example.html
// Simply set a View3D as item and you can create a full 3D scene inside your score :)
Score.Script {
  Score.FloatSlider {
    id: slider_rotation
    objectName: "Rotation"
    min: 0
    max: 360
  }

  Score.TextureOutlet {
    objectName: "out"
    item: View3D {
        id: view
        anchors.fill: parent
        environment: SceneEnvironment {
          clearColor: "skyblue"
          backgroundMode: SceneEnvironment.Color
        }

        PerspectiveCamera {
          position: Qt.vector3d(0, 200, 300)
          eulerRotation.x: -30
        }

        DirectionalLight {
          eulerRotation: Qt.vector3d(-slider_rotation.value, slider_rotation.value, slider_rotation.value)
        }

        Model {
          position: Qt.vector3d(0, -200, 0)
          eulerRotation: Qt.vector3d(slider_rotation.value, slider_rotation.value, slider_rotation.value)
          source: "#Cylinder"
          scale: Qt.vector3d(1.0, 0.2, 1)
          materials: [ PrincipledMaterial {
            baseColor: "red"
          }
          ]
        }

        Model {
          id: sphere
          position: Qt.vector3d(0, 150, 0)
          source: "#Sphere"

          materials: [ PrincipledMaterial {
            baseColor: "blue"
          }
          ]

          SequentialAnimation on y {
            loops: Animation.Infinite
            NumberAnimation {
              duration: 3000
              to: -150
              from: 150
              easing.type:Easing.InQuad
            }
            NumberAnimation {
              duration: 3000
              to: 150
              from: -150
              easing.type:Easing.OutQuad
            }
          }
        }
      }
  }


  tick: function(token, state) {
    sphere.position.x = ((sphere.position.x + 1.0) % 50.);
  }
}
