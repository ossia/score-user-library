#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

    parameters.add(backGround.set("BackGround",
                   ofVec4f(255, 0, 0, 0),
                   ofVec4f(0, 0, 0, 0),
                   ofVec4f(255, 255, 255, 255)));

    kinect.setup(); // default to "RGB" instead of infrared

    parameters.add(kinect.parameters);

    oscQuery.setup(parameters);

    oscQuery[backGround].setClipMode("both").setUnit("color.argb8");

    kinect.setAtributes(oscQuery);
}

//--------------------------------------------------------------
void ofApp::update(){

    kinect.update();
}

//--------------------------------------------------------------
void ofApp::draw(){

    ofBackground(backGround->y,
                 backGround->z,
                 backGround->w,
                 backGround->x);

    kinect.draw();
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

    kinect.resize();
}

void ofApp::exit(){

    kinect.close();
}
