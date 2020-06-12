#include "ossiaVid.h"

//--------------------------------------------------------------
ossiaVid::ossiaVid()
{
    params.add(drawVid.set("draw_video", false));

    params.add(size.set("size", 1., 0., 10.));
    prevSize = size;

    params.add(placement.set("placement",
                            ofVec2f(0, 0),
                            ofVec2f(-1, -1),
                            ofVec2f(1, 1)));
    prevPlace = placement;
}

void ossiaVid::placeCanvas()
{
    float width{vidWandH[0] * size};
    float height{vidWandH[1] * size};

    float wOfset{width / 2};
    float hOfset{height / 2};

    int ofWidth{ofGetWidth()};
    int ofHeight{ofGetHeight()};

    int ofHalfW{ofWidth / 2};
    int ofHalfH{ofHeight / 2};

    float xOfset{ofHalfW + (ofHalfW * placement->x)};
    float yOfset{ofHalfH + (ofHalfH * placement->y)};

    canvas[0] = (xOfset - wOfset);
    canvas[1] = (yOfset - hOfset);
    canvas[2] = placement->z;
    canvas[3] = width;
    canvas[4] = height;
}

void ossiaVid::checkResize()
{
    if (prevSize != size || prevPlace != placement)
    {
        placeCanvas();
        prevSize = size;
        prevPlace = placement;
    }
}

void ossiaVid::setMatrix()
{
    pixMatrix.setName("matrix");

    int i{1};
    int j{1};

    for (ofParameter<float>& p: pixVal)
    {
        p.set("columms_" + to_string(i) + "/row_" + to_string(j), 0);
        pixMatrix.add(p);

        j++;

        if (j > MATRIX_SIZE)
        {
            i++;
            j = 1;
        }
    }

    pixControl.setName("pixels");
    pixControl.add(getPixels.set("get", false));
    pixControl.add(averageColor.set("average_color",
                                    ofVec4f(0, 0, 0, 255),
                                    ofVec4f(0, 0, 0, 0),
                                    ofVec4f(255, 255, 255, 255)));
    pixControl.add(hPoints.set("horizontal_points", MATRIX_SIZE / 2, 1, MATRIX_SIZE));
    pixControl.add(vPoints.set("vertical_points", MATRIX_SIZE / 2, 1, MATRIX_SIZE));
    pixControl.add(pixMatrix);
    pixControl.add(drawCircles.set("draw_circles", false));
    params.add(pixControl);
}

void ossiaVid::processPix(const ofPixels& px, ofParameter<float> *pv, ofParameterGroup& gr)
{
    size_t vidWidth = px.getWidth();
    size_t vidHeight = px.getHeight();
    size_t widthSpread = vidWidth / gr.getInt(2);
    unsigned int verticalStep = MATRIX_SIZE - gr.getInt(3);
    size_t heightSpread = vidHeight / gr.getInt(3);
    size_t widthMargin = widthSpread / 2;
    size_t heightMargin = heightSpread / 2;
    unsigned int widthRemainder = vidWidth - (vidWidth % gr.getInt(2)) + widthMargin;
    unsigned int heightRemainder = vidHeight - (vidHeight % gr.getInt(3)) + heightMargin;

    unsigned int averageColor[4]{0, 0, 0, 0};
    unsigned int iter{0};

    for (size_t i = widthMargin; i < widthRemainder; i+= widthSpread)
    {
        for (size_t j = heightMargin; j < heightRemainder; j+= heightSpread)
        {
            ofColor pxColor = px.getColor(i, j);
            averageColor[0] += pxColor.r;
            averageColor[1] += pxColor.g;
            averageColor[2] += pxColor.b;
            averageColor[3] += pxColor.a;
            iter++;

            float lightness = pxColor.getLightness() / 255;
            pv->set(lightness);
            pv++;

            if (gr.getBool(5))
            {
                checkResize();

                ofDrawCircle(canvas[0] + i * size,
                    canvas[1] + j * size,
                    canvas[2],
                    10 * lightness);
            }
        }
        pv+= verticalStep;
    }

    gr.getVec4f(1).set(ofVec4f(averageColor[0] / iter,
            averageColor[1] / iter,
            averageColor[2] / iter,
            averageColor[3] / iter));
}

//--------------------------------------------------------------
ossiaPlayer::ossiaPlayer(string folder)
    :path{folder}
{
}

void ossiaPlayer::setup()
{
    vid.load(path);           // initialize video path
    vid.setLoopState(OF_LOOP_NONE);
    vid.play();
    vid.setPaused(true);

    params.setName(ofFile(path).getBaseName());    // set parameters

    play.addListener(this, &ossiaPlayer::setPlay);
    params.add(play.set("play", false));

    loop.addListener(this, &ossiaPlayer::setLoop);
    params.add(loop.set("loop", false));

    params.add(seek.set("seek", 0., 0., 1.));
    seek.addListener(this, &ossiaPlayer::setFrame);

    setMatrix();

    vidWandH[0] = vid.getWidth(); // get the video's original size
    vidWandH[1] = vid.getHeight();

    placeCanvas();
}

void ossiaPlayer::update()
{
    vid.update();
}

void ossiaPlayer::setPlay(bool &toPlay)
{
    vid.setPaused(!toPlay);
}

void ossiaPlayer::setLoop(bool &toLoop)
{
    if (toLoop)
    {
        vid.setLoopState(OF_LOOP_NORMAL);
        if (vid.getPosition() >= 1) vid.setPosition(0);
    } else
    {
        vid.setLoopState(OF_LOOP_NONE);
    }
}

void ossiaPlayer::setFrame(float &toSeek)
{
    vid.setPosition(toSeek);
}

void ossiaPlayer::draw()
{
    if (drawVid)
    {
        checkResize();

        vid.getTexture().draw(canvas[0], // getTexture allows the use of the Z axis to mange overlaping videos
                   canvas[1],
                   canvas[2],
                   canvas[3],
                   canvas[4]);
    }

    if (getPixels) processPix(vid.getPixels(), pixVal, pixControl);
}

void ossiaPlayer::close()
{
    vid.stop();
    vid.closeMovie();
}

//--------------------------------------------------------------
ossiaGrabber::ossiaGrabber(ofVideoDevice dev)
    :device{dev}
{
}

void ossiaGrabber::setup(unsigned int width, unsigned int height)
{
    vid.setDeviceID(device.id);
    vid.initGrabber(width, height);

    params.setName(device.deviceName);    // set parameters

    vidWandH[0] = vid.getWidth();
    vidWandH[1] = vid.getHeight();

    params.add(freeze.set("freeze", false));

    setMatrix();

    placeCanvas();
}

void ossiaGrabber::update()
{
    if (!freeze) vid.update();
}

void ossiaGrabber::draw()
{
    if (drawVid)
    {
        checkResize();

        vid.getTexture().draw(canvas[0], // getTexture allows the use of the Z axis to mange overlaping videos
                   canvas[1],
                   canvas[2],
                   canvas[3],
                   canvas[4]);
    }

    if (getPixels) processPix(vid.getPixels(), pixVal, pixControl);
}

void ossiaGrabber::close()
{
    vid.close();
}
