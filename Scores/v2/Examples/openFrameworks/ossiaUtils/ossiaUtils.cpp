#include "ossiaUtils.h"

namespace ossiaUtils
{

//--------------------------------------------------------------
void players::setup(string directory)
{
    ofDirectory path(directory);
    path.allowExt("mov");
    path.allowExt("mp4");
    path.allowExt("avi");

    path.listDir();
    if (path.size() == 0) return;

    parameters.setName("Videos");

    for (const ofFile& mov : path)
    {
        vids.push_back(new ossiaPlayer(mov.getAbsolutePath()));
    }

    for (ossiaPlayer* p: vids)
    {
        p->setup();
        parameters.add(p->params);
    }
}

#ifdef OSCQUERY
void players::setAtributes(ofxOscQueryServer& device)
{
    for (ossiaPlayer* vid : vids)
    {
        int index{4};

        setBaseAtributes(device, vid->params); // get the matrix parameter group
        // play
        device[vid->params[index]].setCritical(true).setDescription("play or pause the video");
        // loop
        device[vid->params[++index]].setCritical(true).setDescription("repeat the video indefinatly");
        // seek
        device[vid->params[++index]].setClipMode("both").setDescription("jump to a specific position in the video");
        // volume
        device[vid->params[++index]].setClipMode("both").setUnit("gain.linear")
                .setDescription("set the volume of the video, if it contains audio");

#ifdef CV
        setCvAtributes(device, vid->params.getGroup(++index));
#endif

        setMatrixAtributes(device, vid->params.getGroup(++index)); // get the matrix parameter group
    }
}
#endif

void players::update()
{
    for (ossiaPlayer* vid : vids) vid->update();
}

void players::draw()
{
    for (ossiaPlayer* vid : vids) vid->draw();
}

void players::resize()
{
    for (ossiaPlayer* vid : vids) vid->checkResize();
}

void players::close()
{
    for (ossiaPlayer* vid : vids)
    {
        vid->close();
        delete vid;
    }
}

//--------------------------------------------------------------
void grabbers::setup(unsigned int width, unsigned int height)
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

            vids.push_back(new ossiaGrabber(dev));
        } else
        {
            //log the device and note it as unavailable
            ofLogNotice() << dev.id << ": " << dev.deviceName << " - unavailable ";
        }
    }

    for (ossiaGrabber* g: vids)
    {
        g->setup(width, height);
        parameters.add(g->params);
    }
}

void grabbers::setup(int exclude, unsigned int width, unsigned int height)
{
    parameters.setName("Cameras");

    //get back a list of devices.
    ofVideoGrabber grabber;
    vector<ofVideoDevice> devices = grabber.listDevices();

    for (ofVideoDevice& dev : devices)
    {
        if (dev.bAvailable && dev.id != exclude)
        {
            vids.push_back(new ossiaGrabber(dev));
        } else
        {
            //log the device and note it as unavailable
            cout << dev.id << ": " << dev.deviceName << " - unavailable \n";
        }
    }

    for (ossiaGrabber* g: vids)
    {
        g->setup(width, height);
        parameters.add(g->params);
    }
}

#ifdef OSCQUERY
void grabbers::setAtributes(ofxOscQueryServer& device)
{
    for (ossiaGrabber* vid : vids)
    {
        int index{4};

        setBaseAtributes(device, vid->params);
        // play
        device[vid->params[index]].setCritical(true).setDescription("play or pause the video");

#ifdef CV
        setCvAtributes(device, vid->params.getGroup(++index));
#endif

        setMatrixAtributes(device, vid->params.getGroup(++index)); // get the matrix parameter group
    }
}
#endif

void grabbers::update()
{
    for (ossiaGrabber* vid : vids) vid->update();
}

void grabbers::draw()
{
    for (ossiaGrabber* vid : vids) vid->draw();
}

void grabbers::resize()
{
    for (ossiaGrabber* vid : vids) vid->checkResize();
}

void grabbers::close()
{
    for (ossiaGrabber* vid : vids)
    {
        vid->close();
        delete vid;
    }
}

//--------------------------------------------------------------
#ifdef KINECT
void kinects::setup(bool infrared)
{
    parameters.setName("Kinects");

    //get back a list of devices.
    ofxKinect kin;
    int devices = kin.numAvailableDevices();

    for (int i = 0; i < devices; i++)
    {
        vids.push_back(new ossiaKinect(i));
    }

    for (ossiaKinect* g: vids)
    {
        g->setup(infrared);
        parameters.add(g->params);
    }
}

void kinects::setup(vector<bool> infrared)
{
    parameters.setName("Kinects");

    //get back a list of devices.
    ofxKinect kin;
    unsigned int devices = kin.numAvailableDevices();

    if (devices != infrared.size()) cerr << "infrared vector must contain as many booleans as conected kinects\n";

    for (unsigned int i = 0; i < devices; i++)
    {
        vids.push_back(new ossiaKinect(i));
        vids[i]->setup(infrared[i]);
        parameters.add(vids[i]->params);
    }
}

#ifdef OSCQUERY
void kinects::setAtributes(ofxOscQueryServer& device)
{
    for (ossiaKinect* vid : vids)
    {
        int index{4};

        setBaseAtributes(device, vid->params); // get the matrix parameter group
        // play
        device[vid->params[index]].setCritical(true).setDescription("play or pause the video");
        device[vid->params[++index]].setDescription("camera angle").setClipMode("both").setUnit("angle.degrees");

#ifdef CV
        setCvAtributes(device, vid->params.getGroup(++index));
#endif

        setMatrixAtributes(device, vid->params.getGroup(++index)); // get the matrix parameter group
    }
}
#endif

void kinects::update()
{
    for (ossiaKinect* vid : vids) vid->update();
}

void kinects::draw()
{
    for (ossiaKinect* vid : vids) vid->draw();
}

void kinects::resize()
{
    for (ossiaKinect* vid : vids) vid->checkResize();
}

void kinects::close()
{
    for (ossiaKinect* vid : vids)
    {
        vid->close();
        delete vid;
    }
}
#endif

//--------------------------------------------------------------
#ifdef OSCQUERY
void setBaseAtributes(ofxOscQueryServer& device, ofParameterGroup& params) // using neamsapce ossiaVids still leav this function ambiguous
{
    int index{0};

    // draw_video
    device[params[index]].setCritical(true).setDescription("display the video");
    // size
    device[params[++index]].setDescription("set the display scale factor, 1 is the original size");
    // placement
    device[params[++index]].setUnit("position.opengl")
            .setDescription("the placement of the video, [0, 0, 0] is centered");
    // draw_color
        device[params[++index]].setClipMode("both").setUnit("color.argb8");
}

#ifdef CV
void setCvAtributes(ofxOscQueryServer& device, ofParameterGroup& params) // using neamsapce ossiaVids still leav this function ambiguous
{
    int index{0};

    // threshold
    device[params[index]].setClipMode("both")
            .setDescription("minimum grayscale value");
    // hold Background
    device[params[++index]].setCritical(true)
            .setDescription("snapshot and remove curent background");
    // draw greyscale
    device[params[++index]].setCritical(true)
            .setClipMode("both").setDescription("draw cv image");

    setBlobsAtributes(device, params.getGroup(++index)); // get the matrix parameter group
}

void setBlobsAtributes(ofxOscQueryServer& device, ofParameterGroup& params) // using neamsapce ossiaVids still leav this function ambiguous
{
    int index{0};

    // get contours
    device[params[++index]].setCritical(true)
            .setClipMode("both").setDescription("draw contours");
    // min area
    device[params[index]].setClipMode("both")
            .setDescription("minimum blob size");
    // max area
    device[params[++index]].setClipMode("both")
            .setDescription("maximum blob size");
    // draw contours
    device[params[++index]].setCritical(true)
            .setClipMode("both").setDescription("draw contours");

    index++;

    for (int i = 0; i < 5; i++)
    {
        device[params[index + (i * 2)]].setClipMode("both").setUnit("position.opengl");
        device[params[index + (i * 2) + 1]];
    }
}
#endif

void setMatrixAtributes(ofxOscQueryServer& device, ofParameterGroup& params) // using neamsapce ossiaVids still leav this function ambiguous
{
    int index{0};

    // get
    device[params[index]].setCritical(true)
            .setDescription("go through the video's pixel array to get ligthness value end average color");
    // invert
    device[params[++index]].setCritical(true)
            .setDescription("invert ligt and dark matrix values");
    // horizontal points
    device[params[++index]].setCritical(true)
            .setClipMode("both").setDescription("number of points along the video's width");
    // vertical points
    device[params[++index]].setCritical(true)
            .setClipMode("both").setDescription("number of points along the video's height");

    // threshold
    device[params[++index]].setClipMode("both")
            .setDescription("minimum value to register in the matrix, 0 if under");

    // matrix/columms_*/row_*
    device[params[++index]].setClipMode("both").setUnit("color.hsb.b")
            .setDescription("brightnessa at a given point"); // not working
    // average_color
    device[params[++index]].setClipMode("both").setUnit("color.argb8")
            .setDescription("get the video's average color");

    // barycenter
    device[params[++index]].setUnit("position.opengl")
            .setDescription("center of brightness");

    // draw_matrix
    device[params[++index]].setCritical(true)
            .setDescription("draw cicles at each points of the matrix");
    // draw_barysenter
    device[params[++index]].setCritical(true)
            .setDescription("draw a cicle at the brightness center");
    // circle_size
    device[params[++index]].setClipMode("both")
            .setDescription("size factor for each circles");
    // circle_size
    device[params[++index]].setClipMode("both")
            .setDescription("number of 'sides' per circle");
    // circle_color
    device[params[++index]].setClipMode("both").setUnit("color.argb8")
            .setDescription("color of evry circle");
}

#endif

}
