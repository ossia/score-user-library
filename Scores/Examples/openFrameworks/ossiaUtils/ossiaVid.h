#ifndef OSSIAVID_H
#define OSSIAVID_H

#include "ofMain.h"

#ifdef ofxKinect
#include "ofxKinect.h"
#include "ofxOpenCv"
#endif

#define MATRIX_SIZE 32

//--------------------------------------------------------------
ofVec4f placeCanvas(const unsigned int* wAndH, const float& s, const ofVec3f& p);

//--------------------------------------------------------------
class ossiaVid
{
public:
    ossiaVid();
    ofParameterGroup params;

    void checkResize();

protected:
    float prevSize;
    ofVec3f prevPlace;
    ofParameter<ofVec3f> placement;
    ofParameter<float> size;
    unsigned int vidWandH[2];
    ofVec4f canvas;

    ofParameter<ofVec4f> color;

    ofParameter<bool> drawVid;
};

//--------------------------------------------------------------
class ossiaPix
{
protected:
    ofParameterGroup pixControl;
    ofParameter<int> lookUp;
    ofParameter<bool> getPixels;
    ofParameter<int> hPoints;
    ofParameter<int> vPoints;
    ofParameter<float> threshold;
    ofParameter<float> pixVal[MATRIX_SIZE * MATRIX_SIZE];
    ofParameter<ofVec4f> averageColor;
    ofParameter<ofVec3f> centroid;
    ofParameter<bool> drawCircles;
    ofParameter<bool> drawCenter;
    ofParameter<float> circleSize;
    ofParameter<int> circleResolution;
    ofParameter<ofVec4f> circleColor;
    ofParameterGroup pixMatrix;

    void setMatrix(ofParameterGroup& params);
    void processPix(const ofPixels& px, ofParameter<float>* pv, const ofVec4f& canvas, const float& z, const float& size);
};

//--------------------------------------------------------------
class ossiaGrabber: public ossiaVid, protected ossiaPix
{
public:
    ossiaGrabber(ofVideoDevice dev);
    void setup(unsigned int width, unsigned int height);
    void update();
    void draw();
    void close();
    ofVideoGrabber vid;

private:
    ofVideoDevice device;

    ofParameter<bool> freeze;
};

//--------------------------------------------------------------
class ossiaPlayer: public ossiaVid, protected ossiaPix
{
public:
    ossiaPlayer(string path);
    void setup();
    void update();
    void draw();
    void close();
    ofVideoPlayer vid;

private:
    string path;

    ofParameter<bool> play;
    void setPlay(bool &toPlay);

    ofParameter<bool> loop;
    void setLoop(bool &toLoop);

    ofParameter<float> seek;
    void setFrame(float &toSeek);

    ofParameter<float> volume;
    void setVolume(float &toAmp);
};

//--------------------------------------------------------------
#ifdef ofxKinect
class ossiaKinect
{
public:
    ossiaKinect(int device);
    void setup();
    void update();
    void draw();
    void close();
    ofxKinect vid;

private:
    int device;

    ofParameter<bool> freeze;
};
#endif

#endif // OSSIAVID_H
