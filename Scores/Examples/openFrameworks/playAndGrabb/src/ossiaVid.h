#ifndef OSSIAVID_H
#define OSSIAVID_H

#include "ofMain.h"

#define MATRIX_SIZE 32

class ossiaVid
{
public:
    ossiaVid();
    ofParameterGroup params;
    void placeCanvas();

protected:
    ofParameter<float> size;
    float prevSize;
    ofParameter<ofVec3f> placement;
    ofVec3f prevPlace;
    void checkResize();

    ofParameter<bool> drawVid;
    unsigned int vidWandH[2];
    float canvas[5];

    ofParameterGroup pixControl;
    ofParameter<bool> getPixels;
    ofParameter<ofVec4f> averageColor;
    ofParameter<int> hPoints;
    ofParameter<int> vPoints;
    ofParameter<float> pixVal[MATRIX_SIZE * MATRIX_SIZE];
    ofParameter<bool> drawCircles;
    ofParameterGroup pixMatrix;

    void setMatrix();
    void processPix(const ofPixels& px, ofParameter<float>* pv, ofParameterGroup& gr);
};

class ossiaPlayer: public ossiaVid
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
};

class ossiaGrabber: public ossiaVid
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

#endif // OSSIAVID_H
