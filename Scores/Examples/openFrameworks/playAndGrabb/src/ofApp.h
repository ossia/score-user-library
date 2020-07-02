#pragma once

#include "ofMain.h"
#include "../../ossiaUtils/ossiaUtils.h" // // includes "ofxOscQueryServer.h", "ossiaVid.h"

class ofApp : public ofBaseApp{

public:
    void setup();
    void update();
    void draw();
    void exit();

    void windowResized(int w, int h);
    void dragEvent(ofDragInfo dragInfo);
    void gotMessage(ofMessage msg);

    ofParameterGroup parameters;
    ossiaUtils::players videos;
    ossiaUtils::grabbers cameras;
    ofParameter<ofVec4f> backGround;

    ofxOscQueryServer oscQuery;
};
