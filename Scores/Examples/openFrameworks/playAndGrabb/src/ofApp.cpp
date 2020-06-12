#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

    parameters.add(backGround.set("BackGround",
                   ofVec4f(0, 0, 0, 255),
                   ofVec4f(0, 0, 0, 0),
                   ofVec4f(255, 255, 255, 255)));

    videos.setup("movies");
    parameters.add(videos.parameters);

    cameras.setup(320, 240, 1);
    parameters.add(cameras.parameters);

    oscQuery.setup(parameters);
}

//--------------------------------------------------------------
void ofApp::update(){

    videos.update();
    cameras.update();
}

//--------------------------------------------------------------
void ofApp::draw(){

    ofBackground(backGround->x,
                 backGround->y,
                 backGround->z,
                 backGround->w);

    videos.draw();
    cameras.draw();
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){

}

void ofApp::exit(){

    //videos.close();
    cameras.close();
}
