#ifndef OSSIAVIDSPLAYER_H
#define OSSIAVIDSPLAYER_H

#include "ossiaVid.h"

#ifdef OSCQUERY
#include "ofxOscQueryServer.h"
#endif

namespace ossiaUtils
{

//--------------------------------------------------------------
class players
{
public:
    void setup(string directory = ""); // default to the "data" directory inside "bin"

#ifdef OSCQUERY
    void setAtributes(ofxOscQueryServer& device);
#endif

    void update();
    void draw();
    void resize();
    void close();
    ofParameterGroup parameters;

private:
    vector<ossiaPlayer*> vids;
};

//--------------------------------------------------------------
class grabbers
{
public:
    // setup all available video devices
    void setup(unsigned int width = 640, unsigned int height = 480);
    // setup that alows to exclude one video device (ie. the laptop's cam) if needed
    void setup(int exclude, unsigned int width = 640, unsigned int height = 480);

#ifdef OSCQUERY
    void setAtributes(ofxOscQueryServer& device);
#endif

    void update();
    void draw();
    void resize();
    void close();
    ofParameterGroup parameters;

private:
    vector<ossiaGrabber*> vids;
};

//--------------------------------------------------------------
#ifdef KINECT
class kinects
{
public:
    // setup all available kinects
    void setup(bool infrared = false);
    // setup all available kinects
    void setup(vector<bool> infrared);

#ifdef OSCQUERY
    void setAtributes(ofxOscQueryServer& device);
#endif
    void update();
    void draw();
    void resize();
    void close();
    ofParameterGroup parameters;

private:
    vector<ossiaKinect*> vids;
};
#endif

#ifdef OSCQUERY
void setBaseAtributes(ofxOscQueryServer& device, ofParameterGroup& params);
#ifdef CV
void setCvAtributes(ofxOscQueryServer& device, ofParameterGroup& params);
void setBlobsAtributes(ofxOscQueryServer& device, ofParameterGroup& params);
#endif
void setMatrixAtributes(ofxOscQueryServer& device, ofParameterGroup& params);
#endif

}

#endif // OSSIAVIDSPLAYER_H
