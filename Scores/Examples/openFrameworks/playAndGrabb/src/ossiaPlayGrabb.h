#ifndef OSSIAVIDSPLAYER_H
#define OSSIAVIDSPLAYER_H

#include "ossiaVid.h"
#include "ofxOscQueryServer.h"

namespace ossiaVids
{

class player
{
public:
    void setup(string directory);
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
    // setup all available vidéo devices
    void setup(unsigned int width, unsigned int height);
    // setup that alows to exclude one vidéo device (ie. the laptop's cam) if needed
    void setup(unsigned int width, unsigned int height, int exclude);
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
