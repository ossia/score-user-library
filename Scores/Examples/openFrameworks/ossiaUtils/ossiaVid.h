#ifndef OSSIAVID_H
#define OSSIAVID_H

#include "ofMain.h"

#define MATRIX_SIZE 32

#ifdef KINECT
#include "ofxKinect.h"
#endif

#ifdef CV
#include "ofxOpenCv.h"
#endif

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
#ifdef CV
class ossiaCv
{
protected:
    ofParameterGroup cvControl;

    ofxCvColorImage colorImg;

    ofxCvGrayscaleImage grayImage; // grayscale depth image
    ofxCvGrayscaleImage grayMin; // the near thresholded image
    ofxCvGrayscaleImage grayMax; // the far thresholded image

    void allocateCvImg(const unsigned int* wAndH);
    void cvUpdate();

    ofxCvContourFinder contourFinder;

    int minThreshold;
    int maxThreshold;

    // blob size
    int minArea;
    int maxArea;
};
#endif

//--------------------------------------------------------------
class ossiaPlayer: public ossiaVid
        #ifdef CV
        , protected ossiaCv
        #endif
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
class ossiaGrabber: public ossiaVid
        #ifdef CV
        , protected ossiaCv
        #endif
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
#ifdef KINECT
class ossiaKinect: public ossiaVid
        #ifdef CV
        , protected ossiaCv
        #endif
{
public:
    ossiaKinect(int dev);
    void setup(bool infrared);
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
