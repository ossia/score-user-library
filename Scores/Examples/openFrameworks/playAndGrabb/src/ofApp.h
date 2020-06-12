#pragma once

#include "ofMain.h"
#include "ofxOscQueryServer.h"
#include "ossiaPlayGrabb.h"
//#include "ossiaVid.h"

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
    ossiaVidsPlayer videos;
    ossiaVidsGrabber cameras;
    ofParameter<ofVec4f> backGround;
    ofxOscQueryServer oscQuery;
};
