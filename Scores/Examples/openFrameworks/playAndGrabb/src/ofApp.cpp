#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

    parameters.add(backGround.set("BackGround",
                   ofVec4f(255, 0, 0, 0),
                   ofVec4f(0, 0, 0, 0),
                   ofVec4f(255, 255, 255, 255)));

    ofSetCircleResolution(10);

    videos.setup(); // default to the "data" directory inside "bin"
    parameters.add(videos.parameters);

    cameras.setup(1); // default to exclude the device at index 1 and grab 320 by 240 videos
    parameters.add(cameras.parameters);

    oscQuery.setup(parameters);

    oscQuery[backGround].setClipMode("both").setUnit("color.argb8");

    videos.setAtributes(oscQuery);
    cameras.setAtributes(oscQuery);
}

//--------------------------------------------------------------
void ofApp::update(){

    videos.update();
    cameras.update();
}

//--------------------------------------------------------------
void ofApp::draw(){

    ofBackground(backGround->y,
                 backGround->z,
                 backGround->w,
                 backGround->x);

    videos.draw();
    cameras.draw();
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

    videos.resize();
    cameras.resize();
}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){

}

void ofApp::exit(){

    videos.close();
    cameras.close();
}
