import Score 
import QtQuick

/**
 * From input keycodes, create a FPS camera movement, e.g. 
 * gives the camera position and camera target (e.g. lookAt).
 * Controls are: 
 * - wasd / zqsd for position
 * - up / down / left / right for camera orientation
 * - left shift / left ctrl for going up / down
 */
Script {
  ValueInlet { id: keypress; objectName: "Keycode press" }
  ValueInlet { id: keyrelease; objectName: "Keycode release"  }
  ValueOutlet { id: position; objectName: "Camera position"  }
  ValueOutlet { id: center; objectName: "Camera target" }

  // Note: this assumes codes from the Window device.
  // They have been tested to be valid on Linux / X11 with a french AZERTY keyboard (ZQSD instead of WASD).
  // Maybe not the case on other platforms, like macOS.
  // The commented version is if using the raw evdev input device keycodes instead.
  readonly property int g_W_KEYCODE: 90 // 17
  readonly property int g_S_KEYCODE: 83 // 31
  readonly property int g_A_KEYCODE: 81 // 30
  readonly property int g_D_KEYCODE: 68 // 32

  readonly property int g_UP_KEYCODE: 16777235 // 103
  readonly property int g_DOWN_KEYCODE: 16777237 // 105
  readonly property int g_LEFT_KEYCODE: 16777234 // 108
  readonly property int g_RIGHT_KEYCODE: 16777236 // 106

  readonly property int g_LCTRL_KEYCODE: 16777249 // 29
  readonly property int g_LSHIFT_KEYCODE: 16777248 // 42
  
  property real cur_x: 0
  property real cur_y: 0
  property real cur_z: 0
  
  property real cur_pitch: 0
  property real cur_yaw: 0
  
  property var pressed: new Set();

  tick: function(token, state) {
    for(const k of keypress.values) {
      const code = k.value;
      pressed.add(code);
    }
    for(const k of keyrelease.values) {
      const code = k.value;
      pressed.delete(code);
    }

    let move_x = 0.0; // front-back
    let move_y = 0.0; // up-down
    let move_z = 0.0; // left-right

    let move_pitch = 0.0; // up-down
    let move_yaw = 0.0; // rotation

    if(pressed.has(g_W_KEYCODE)) move_x += 0.02;
    if(pressed.has(g_S_KEYCODE)) move_x -= 0.02;
    if(pressed.has(g_LSHIFT_KEYCODE)) move_y += 0.02;
    if(pressed.has(g_LCTRL_KEYCODE)) move_y -= 0.02;
    if(pressed.has(g_A_KEYCODE)) move_z += 0.02;
    if(pressed.has(g_D_KEYCODE)) move_z -= 0.02;
    
    if(pressed.has(g_UP_KEYCODE)) move_pitch += 0.01;
    if(pressed.has(g_DOWN_KEYCODE)) move_pitch -= 0.01;
    if(pressed.has(g_LEFT_KEYCODE)) move_yaw += 0.01;
    if(pressed.has(g_RIGHT_KEYCODE)) move_yaw -= 0.01;
    
    // 1. Update the rotation, e.g. where we look at.
    //    Clamp it as there's a pole at 90 / -90°
    cur_pitch = Math.min(Math.max(cur_pitch + move_pitch, -0.5 * 3.1415), 0.5 * 3.1415);
    cur_yaw = cur_yaw + move_yaw;  
    if(cur_yaw >= Math.PI)
     cur_yaw = cur_yaw - 2. * Math.PI;
    if(cur_yaw < -Math.PI)
     cur_yaw = cur_yaw + 2. * Math.PI;
    const cur_roll = 0.;

    // 2. We want to move in the direction pointerd to by the camera on a straight plane
    //    We compute the vector that goes from "current position" to "looked at position"
    // 1. Forward direction vector from yaw and pitch
    const look_dir_x = Math.cos(cur_pitch) * Math.sin(cur_yaw);
    const look_dir_y = Math.sin(cur_pitch);
    const look_dir_z = Math.cos(cur_pitch) * Math.cos(cur_yaw);

    // 2. Update position using movement input
    cur_x += move_x * Math.sin(cur_yaw) + move_z * Math.cos(cur_yaw);
    cur_y += move_y;
    cur_z += move_x * Math.cos(cur_yaw) - move_z * Math.sin(cur_yaw);

    position.value = Qt.vector3d(cur_x, cur_y, cur_z);
    center.value = Qt.vector3d(cur_x + look_dir_x, cur_y + look_dir_y, cur_z + look_dir_z);
  }
}