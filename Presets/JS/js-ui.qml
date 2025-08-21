import Score as Score
import QtQuick
import QtQuick.Controls as QQC

Score.Script {    
    Score.Toggle {
      objectName: "Show UI"
      checked: true      
    }
    
    Score.TextureOutlet {
        objectName: "out"
        item: Item {
            id: self
            anchors.fill: parent
            
            Rectangle {
              id: rect
              color: "blue"
              width: 100
              height: 100
            }
            
            QQC.Button {
                anchors.bottom: parent.bottom
                text: self.height
                onClicked: console.log("oki")
            }
        }
    }
    

  tick: function(token, state) {
      rect.x = ((rect.x + 1) % 100)
      rect.y = ((rect.y + 1) % 100)
  }
}
