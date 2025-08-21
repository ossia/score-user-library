import Score as Score
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils

Score.Script {
  Score.LineEdit {
    objectName: "glTF file"
    id: model_url
  }
  Score.LineEdit {
    objectName: "Environment map"
    id: env_url
  }

  Score.TextureOutlet {
    objectName: "out"
    item:

    View3D {
      anchors.fill: parent

      environment: SceneEnvironment {
        clearColor: "green"

        antialiasingMode: SceneEnvironment.MSAA
        tonemapMode: SceneEnvironment.TonemapModeFilmic
        backgroundMode: SceneEnvironment.SkyBox
        lightProbe: Texture {
          source: env_url.value
        }
      }

      PerspectiveCamera {
        id: camera
        y: 100
      }

      DirectionalLight {
      }
      RuntimeLoader {
        id: importNode
        scale: Qt.vector3d(100, 100, 100)
        source: model_url.value
      }

      WasdController {
        controlledObject: camera
      }
    }
  }


  tick: function(token, state) {
    rect.x = ((rect.x + 1) % 100)
    rect.y = ((rect.y + 1) % 100)
  }
}
