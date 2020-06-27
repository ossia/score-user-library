#include "ossiaUtils.h"

namespace ossiaUtils
{


ofVec4f placeCanvas(const unsigned int* wAndH, const float& s, const ofVec3f& p)
{
    float width{wAndH[0] * s};
    float height{wAndH[1] * s};

    float wOfset{width / 2};
    float hOfset{height / 2};

    int ofWidth{ofGetWidth()};
    int ofHeight{ofGetHeight()};

    int ofHalfW{ofWidth / 2};
    int ofHalfH{ofHeight / 2};

    float xOfset{ofHalfW + (ofHalfW * p[0])};
    float yOfset{ofHalfH + (ofHalfH * p[1])};

    return ofVec4f{(xOfset - wOfset),
                (yOfset - hOfset),
                width,
                height};
}

//--------------------------------------------------------------
void setBaseAtributes(ofxOscQueryServer& device, ofParameterGroup& params) // using neamsapce ossiaVids still leav this function ambiguous
{
    // draw_video
    device[params[0]].setCritical(true).setDescription("display the video");
    // size
    device[params[1]].setDescription("set the display scale factor, 1 is the original size");
    // placement
    device[params[2]].setUnit("position.opengl")
            .setDescription("the placement of the video, [0, 0, 0] is centered");
    // draw_color
        device[params[3]].setClipMode("both").setUnit("color.argb8");
}

void setMatrixAtributes(ofxOscQueryServer& device, ofParameterGroup& params) // using neamsapce ossiaVids still leav this function ambiguous
{
    // look_up
    device[params[0]].setCritical(true).setRangeValues(vector<int>{0, 1, 2, 3, 4})
            .setDescription("light, dark, red, green, blue");
    // get
    device[params[1]].setCritical(true).setDescription("go through the video's pixel array to get ligthness value end average color");
    // horizontal points
    device[params[2]].setCritical(true).setClipMode("both").setDescription("number of points along the video's width");
    // vertical points
    device[params[3]].setCritical(true).setClipMode("both").setDescription("number of points along the video's height");
    // threshold
    device[params[4]].setClipMode("both").setDescription("minimum value to register in the matrix, 0 if under");
    // matrix/columms_*/row_*
    device[params[5]].setClipMode("both").setUnit("color.hsb.b").setDescription("brightnessa at a given point"); // not working
    // average_color
    device[params[6]].setClipMode("both").setUnit("color.argb8").setDescription("get the video's average color");
    // barycenter
    device[params[7]].setUnit("position.opengl").setDescription("center of brightness");
    // draw_matrix
    device[params[8]].setCritical(true).setDescription("draw cicles at each points of the matrix");
    // draw_barysenter
    device[params[9]].setCritical(true).setDescription("draw a cicle at the brightness center");
    // circle_size
    device[params[10]].setClipMode("both").setDescription("size factor for each circles");
    // circle_size
    device[params[11]].setClipMode("both").setDescription("number of 'sides' per circle");
    // circle_color
    device[params[12]].setClipMode("both").setUnit("color.argb8").setDescription("color of evry circle");
}

//--------------------------------------------------------------
void player::setup(string directory)
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

void player::setAtributes(ofxOscQueryServer& device)
{
    for (ossiaPlayer& vid : vids)
    {
        setBaseAtributes(device, vid.params); // get the matrix parameter group
        // play
        device[vid.params[4]].setCritical(true).setDescription("play or pause the video");
        // loop
        device[vid.params[5]].setCritical(true).setDescription("repeat the video indefinatly");
        // seek
        device[vid.params[6]].setClipMode("both").setDescription("jump to a specific position in the video");
        // volume
        device[vid.params[7]].setClipMode("both").setUnit("gain.linear")
                .setDescription("set the volume of the video, if it contains audio");

        setMatrixAtributes(device, vid.params.getGroup(8)); // get the matrix parameter group
    }
}

void player::update()
{
    for (ossiaPlayer& vid : vids) vid.update();
}

void player::draw()
{
    for (ossiaPlayer& vid : vids) vid.draw();
}

void player::resize()
{
    for (ossiaPlayer& vid : vids)
    {
        vid.canvas = placeCanvas(vid.vidWandH, vid.size, vid.placement);
    }
}

void player::close()
{
    for (ossiaPlayer& vid : vids) vid.close();
}

//--------------------------------------------------------------
void grabber::setup(unsigned int width, unsigned int height)
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

void grabber::setup(int exclude, unsigned int width, unsigned int height)
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

void grabber::setAtributes(ofxOscQueryServer& device)
{
    for (ossiaGrabber& vid : vids)
    {
        setBaseAtributes(device, vid.params); // get the matrix parameter group
        // play
        device[vid.params[4]].setCritical(true).setDescription("play or pause the video");

        setMatrixAtributes(device, vid.params.getGroup(5)); // get the matrix parameter group
    }
}

void grabber::update()
{
    for (ossiaGrabber& vid : vids) vid.update();
}

void grabber::draw()
{
    for (ossiaGrabber& vid : vids) vid.draw();
}

void grabber::resize()
{
    for (ossiaGrabber& vid : vids)
    {
        vid.canvas = placeCanvas(vid.vidWandH, vid.size, vid.placement);
    }
}

void grabber::close()
{
    for (ossiaGrabber& vid : vids) vid.close();
}

}
