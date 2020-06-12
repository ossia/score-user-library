#ifndef OSSIAVIDSPLAYER_H
#define OSSIAVIDSPLAYER_H

#include "ossiaVid.h"

class ossiaVidsPlayer
{
public:
    void setup(string directory);
    void update();
    void draw();
    void close();
    ofParameterGroup parameters;

private:
    vector<ossiaPlayer> vids;
};

class ossiaVidsGrabber
{
public:
    void setup(unsigned int width, unsigned int height);
    void setup(unsigned int width, unsigned int height, int exclude);
    void update();
    void draw();
    void close();
    ofParameterGroup parameters;

private:
    vector<ossiaGrabber> vids;
};

#endif // OSSIAVIDSPLAYER_H
