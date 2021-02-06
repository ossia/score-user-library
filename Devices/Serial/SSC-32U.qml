/* The folowing code creates a tree of parameters to control the lynxmotion SSC-32U servo board. 
 * In it's current state, the device allows dirrect control over the first 5 pins used by the AL5D Robotic Arm. 
 * A user manual for this board can be found online: 
 * http://www.lynxmotion.com/images/data/lynxmotion_ssc-32u_usb_user_guide.pdf
 * On Linux, permission to acces the serial port requires the user to be added to the dialout group
 * $ sudo usermod -a -G dialout "your-username"
 * modemanager can also cause permission errors and might need to be uninstalled
 * $ sudo apt remove modemmanager
 */

import Ossia 1.0 as Ossia

Ossia.Serial
{
    function openListening(address) {}

    function closeListening(address) {}

    function createTree() {
        return [ {
                    name: "Pin_#0",
                    children: [
                        {
                            name: "PWM",
                            type: Ossia.Type.Int,
                            access: Ossia.Access.Set,
                            min: 500,
                            max: 2500,
                            request: "#0P$val\r"
                        }
                    ]
                },
                {
                    name: "Pin_#1",
                    children: [
                        {
                            name: "PWM",
                            type: Ossia.Type.Int,
                            access: Ossia.Access.Set,
                            min: 500,
                            max: 2500,
                            request: "#1P$val\r"
                        }
                    ]
                },
                {
                    name: "Pin_#2",
                    children: [
                        {
                            name: "PWM",
                            type: Ossia.Type.Int,
                            access: Ossia.Access.Set,
                            min: 500,
                            max: 2500,
                            request: "#2P$val\r"
                        }
                    ]
                },
                {
                    name: "Pin_#3",
                    children: [
                        {
                            name: "PWM",
                            type: Ossia.Type.Int,
                            access: Ossia.Access.Set,
                            min: 500,
                            max: 2500,
                            request: "#3P$val\r"
                        }
                    ]
                },
                {
                    name: "Pin_#4",
                    children: [
                        {
                            name: "PWM",
                            type: Ossia.Type.Int,
                            access: Ossia.Access.Set,
                            min: 500,
                            max: 2500,
                            request: "#4P$val\r"
                        }
                    ]
                },{
                    name: "Pin_#5",
                    children: [
                        {
                            name: "PWM",
                            type: Ossia.Type.Int,
                            access: Ossia.Access.Set,
                            min: 500,
                            max: 2500,
                            request: "#5P$val\r"
                        }
                    ]
                }
          ];
    }
}
