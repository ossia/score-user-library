#ifndef OSSIAVIDSPLAYER_H
#define OSSIAVIDSPLAYER_H

#include "ossiaVid.h"
#include "ofxOscQueryServer.h"

namespace ossiaVids
{

class player
{
public:
    void setup(string directory = ""); // default to the "data" directory inside "bin"
    void setAtributes(ofxOscQueryServer& device);
    void update();
    void draw();
    void resize();
    void close();
    ofParameterGroup parameters;

private:
    vector<ossiaPlayer> vids;
};

class grabber
{
public:
    // setup all available video devices
    void setup(unsigned int width = 320, unsigned int height = 240);
    // setup that alows to exclude one video device (ie. the laptop's cam) if needed
    void setup(int exclude, unsigned int width = 320, unsigned int height = 240);
    void setAtributes(ofxOscQueryServer& device);
    void update();
    void draw();
    void resize();
    void close();
    ofParameterGroup parameters;

private:
    vector<ossiaGrabber> vids;
};

void setBaseAtributes(ofxOscQueryServer& device, ofParameterGroup& params);
void setMatrixAtributes(ofxOscQueryServer& device, ofParameterGroup& params);

}

#endif // OSSIAVIDSPLAYER_H
