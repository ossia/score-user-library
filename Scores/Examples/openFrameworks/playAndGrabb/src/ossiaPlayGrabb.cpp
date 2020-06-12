#include "ossiaPlayGrabb.h"

//--------------------------------------------------------------
void ossiaVidsPlayer::setup(string directory)
{
    ofDirectory path(directory);
    path.allowExt("mov");
    path.allowExt("mp4");
    path.allowExt("avi");
    path.listDir();

    parameters.setName("Videos");

    for (const ofFile& mov : path)
    {
        ossiaPlayer vid(mov.getAbsolutePath());
        vids.push_back(vid);
    }

    for (ossiaPlayer& p: vids)
    {
        p.setup();
        parameters.add(p.params);
    }
}

void ossiaVidsPlayer::update()
{
    for (ossiaPlayer& vid : vids) vid.update();
}

void ossiaVidsPlayer::draw()
{
    for (ossiaPlayer& vid : vids) vid.draw();
}

void ossiaVidsPlayer::close()
{
    for (ossiaPlayer& vid : vids) vid.close();
}

//--------------------------------------------------------------
void ossiaVidsGrabber::setup(unsigned int width, unsigned int height)
{
    parameters.setName("Cameras");

    //get back a list of devices.
    ofVideoGrabber grabber;
    vector<ofVideoDevice> devices = grabber.listDevices();

    for (ofVideoDevice& dev : devices)
    {
        if (dev.bAvailable)
        {
            //log the device
            ofLogNotice() << dev.id << ": " << dev.deviceName;

            ossiaGrabber vid(dev);
            vids.push_back(vid);
        } else
        {
            //log the device and note it as unavailable
            ofLogNotice() << dev.id << ": " << dev.deviceName << " - unavailable ";
        }
    }

    for (ossiaGrabber& g: vids)
    {
        g.setup(width, height);
        parameters.add(g.params);
    }
}

void ossiaVidsGrabber::setup(unsigned int width, unsigned int height, int exclude)
{
    parameters.setName("Cameras");

    //get back a list of devices.
    ofVideoGrabber grabber;
    vector<ofVideoDevice> devices = grabber.listDevices();

    for (ofVideoDevice& dev : devices)
    {
        if (dev.bAvailable && dev.id != exclude)
        {
            ossiaGrabber vid(dev);
            vids.push_back(vid);
        } else
        {
            //log the device and note it as unavailable
            ofLogNotice() << dev.id << ": " << dev.deviceName << " - unavailable ";
        }
    }

    for (ossiaGrabber& g: vids)
    {
        g.setup(width, height);
        parameters.add(g.params);
    }
}

void ossiaVidsGrabber::update()
{
    for (ossiaGrabber& vid : vids) vid.update();
}

void ossiaVidsGrabber::draw()
{
    for (ossiaGrabber& vid : vids) vid.draw();
}

void ossiaVidsGrabber::close()
{
    for (ossiaGrabber& vid : vids) vid.close();
}
