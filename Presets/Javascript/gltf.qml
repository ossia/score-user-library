// @documentation https://ossia.io/score-docs/processes/javascript/gltf.html
import Score as Score
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

Score.Script {
  Score.FileChooser {
    objectName: "glTF file"
    id: model_url
  }
  Score.FileChooser {
    objectName: "Environment map"
    id: env_url
  }
  Score.XYZSpinBoxes {
    id: lightPosition
    objectName: "Light Position"
    min: Qt.vector3d(-1000.0, -1000.0, -1000.0)
    max: Qt.vector3d(1000.0, 1000.0, 1000.0)
  }
  Score.HSVSlider {
    id: lightColor
    objectName: "Light Color"
  }

  Score.TextureOutlet {
    objectName: "out"
    item: View3D {
      anchors.fill: parent

      environment: SceneEnvironment {
        clearColor: "black"

        antialiasingMode: SceneEnvironment.MSAA
        tonemapMode: SceneEnvironment.TonemapModeFilmic
        backgroundMode: SceneEnvironment.SkyBox
        lightProbe: Texture {
          source: env_url.value;
        }
      }

      PerspectiveCamera {
        id: camera
        y: 5
        clipNear: 0.01
        clipFar: 1000
      }

      PointLight {
          id: pointLight
          x: lightPosition.value.x
          y: lightPosition.value.y
          z: lightPosition.value.z
          color: lightColor.value
          brightness: 25
          castsShadow: true
          shadowFactor: 75
      }

      DirectionalLight {
        castsShadow: true
      }

      RuntimeLoader {
        id: importNode
        scale: Qt.vector3d(100, 100, 100)
        source: model_url.value;
      }

      WasdController {
        id: wasd
        controlledObject: camera
      }
    }
  }

  tick: function(token, state) {
      wasd.forceActiveFocus();
  }
}