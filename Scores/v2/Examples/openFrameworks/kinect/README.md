# Kinect oscquery exemple

### Setup and Run 

The [ofxOscQuery](https://github.com/bltzr/ofxOscQuery) addon is required to run this exemple.
To use with qbs inside qtcreator, first run the ```install_template.sh``` script inside the openFrameworks repository (```./openFrameworks/scripts/qtcreator/install_template.sh```).

To then open this exemple in qtcreator, click "new project" and choose the "Import an existing Application" template for openFrameworks. In the generated "kinect.qbs" file, a few likes are likly to be missing statrting at line 11. The missing file paths and addon has to be manually added as shown below :

```
        files: [
            "src/main.cpp",
            "src/ofApp.cpp",
            "src/ofApp.h",
            "../ossiaUtils/ossiaUtils.cpp",
            "../ossiaUtils/ossiaUtils.h",
            "../ossiaUtils/ossiaVid.cpp",
            "../ossiaUtils/ossiaVid.h"
        ]

        of.addons: [
            "ofxOscQuery",
            "ofxKinect",
            "ofxOpenCv"
        ]

        cpp.defines: ["OSCQUERY", "KINECT", "CV"]
```

The program should then be able to be compiled

### Usage

By default, videos have to be put in the "bin/data" directory to be loaded. A chosen video directory can also be passed as the ```videos.setup()``` argument.

All video cature devices will also be enabled simultaniously if ```cameras.setup()``` is left with the default argument. The default width and size of the capture is 320x240. Alternatively a custom resolution can be specified as folows ```cameras.setup(800, 600)```. A specific video device can also be excluded by passing it's index to the setup memeber function. ```cameras.setup(0, 240, 160)``` will exclude the first device and set the resolution to 240x160.

Once the program is runnig, the device can be automaticly detected by score as an oscquery server, exposing all of it's parameter and atributes once conected to.
