#pragma once

#include "ofMain.h"
#include "ofxOscQueryServer.h"
#include "ossiaPlayGrabb.h"

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
    ossiaVids::player videos;
    ossiaVids::grabber cameras;
    ofParameter<ofVec4f> backGround;

    ofxOscQueryServer oscQuery;
};
