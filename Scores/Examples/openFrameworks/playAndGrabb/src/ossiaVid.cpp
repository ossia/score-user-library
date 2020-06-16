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

    params.add(color.set("draw_color",
                   ofVec4f(255, 255, 255, 255),
                   ofVec4f(0, 0, 0, 0),
                   ofVec4f(255, 255, 255, 255)));
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
        p.set("columms_" + to_string(i) + "/row_" + to_string(j), 0, 0, 255);
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
    pixControl.add(hPoints.set("horizontal_points", MATRIX_SIZE / 2, 1, MATRIX_SIZE));
    pixControl.add(vPoints.set("vertical_points", MATRIX_SIZE / 2, 1, MATRIX_SIZE));
    pixControl.add(pixMatrix);
    pixControl.add(averageColor.set("average_color",
                                    ofVec4f(255, 0, 0, 0),
                                    ofVec4f(0, 0, 0, 0),
                                    ofVec4f(255, 255, 255, 255)));
    pixControl.add(centroid.set("barycenter", ofVec3f(0, 0, 0)));
    pixControl.add(drawCircles.set("draw_matrix", false));
    pixControl.add(drawCenter.set("draw_barycenter", false));
    pixControl.add(circleSize.set("circles_size", 0.1, 0, 1));
    pixControl.add(circleResolution.set("circle_resolution", 22, 3, 100));
    pixControl.add(circleColor.set("circles_color",
                                    ofVec4f(255, 255, 255, 255),
                                    ofVec4f(0, 0, 0, 0),
                                    ofVec4f(255, 255, 255, 255)));
    params.add(pixControl);
}

void ossiaVid::processPix(const ofPixels& px, ofParameter<float> *pv, ofParameterGroup& gr)
{
    size_t vidWidth = px.getWidth();
    size_t vidHeight = px.getHeight();
    size_t widthSpread = vidWidth / gr.getInt(1); // horizontal points
    unsigned int verticalStep = MATRIX_SIZE - gr.getInt(2); // vertical points
    size_t heightSpread = vidHeight / gr.getInt(2); // neumber of pixels between each points
    size_t widthMargin = widthSpread / 2; // minimum number of pixels from the left
    size_t heightMargin = heightSpread / 2; // minimum number of pixels from the top
    // number of skiped pixels before starting a new line
    unsigned int widthRemainder = vidWidth - (vidWidth % gr.getInt(1)) + widthMargin;
    unsigned int heightRemainder = vidHeight - (vidHeight % gr.getInt(2)) + heightMargin;

    ofVec4f averageColor{0, 0, 0, 0};
    float lightSum{0};
    ofVec2f baryCenter{0, 0};
    unsigned int iter{0};

    ofSetCircleResolution(circleResolution);

    ofSetColor(circleColor->y,
               circleColor->z,
               circleColor->w,
               circleColor->x);

    for (size_t i = widthMargin; i < widthRemainder; i+= widthSpread)
    {
        for (size_t j = heightMargin; j < heightRemainder; j+= heightSpread)
        {
            ofColor pxColor = px.getColor(i, j);
            averageColor[0] += pxColor.a;
            averageColor[1] += pxColor.r;
            averageColor[2] += pxColor.g;
            averageColor[3] += pxColor.b;
            iter++;

            float lightness = pxColor.getLightness();
            pv->set(lightness);
            pv++;

            baryCenter += ofVec2f(i, j) * lightness;
            lightSum += lightness;

            if (gr.getBool(6)) // draw_matrix
            {
                checkResize();

                ofDrawCircle(canvas[0] + i * size,
                    canvas[1] + j * size,
                    canvas[2],
                    gr.getFloat(8) * lightness); // cicle size
            }
        }
        pv+= verticalStep;
    }

    averageColor /= iter;
    gr.getVec4f(4).set(averageColor); // average_color

    baryCenter /= lightSum;

    if (gr.getBool(7)) // draw_barycenter
    {
        checkResize();

        ofDrawCircle((canvas[0] + baryCenter[0]) * size,
                (canvas[1] + baryCenter[1]) * size,
                canvas[2],
                gr.getFloat(8) * size * 255); // cicle size
    }

    baryCenter[0] /= vidWidth / 2;
    baryCenter[0] -= 1;
    baryCenter[1] /= vidHeight / 2;
    baryCenter[1] -= 1;

    gr.getVec3f(5).set(ofVec3f(baryCenter[0], baryCenter[1], 0)); // average_color
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

    params.add(volume.set("volume", 1., 0., 1.));
    volume.addListener(this, &ossiaPlayer::setVolume);

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
        if (vid.getIsMovieDone()) vid.setPosition(0);
    } else
    {
        vid.setLoopState(OF_LOOP_NONE);
    }
}

void ossiaPlayer::setFrame(float &toSeek)
{
    vid.setPosition(toSeek);
}

void ossiaPlayer::setVolume(float &toAmp)
{
    vid.setVolume(toAmp);
}

void ossiaPlayer::draw()
{
    ofSetColor(color->y,
               color->z,
               color->w,
               color->x);

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

        ofSetColor(color->y,
                   color->z,
                   color->w,
                   color->x);

        vid.getTexture().draw(canvas[0], // getTexture allows the use of the Z axis to mange overlaping videos
                   canvas[1],
                   canvas[2],
                   canvas[3],
                   canvas[4]);
    }

    if (getPixels)
    {
        processPix(vid.getPixels(), pixVal, pixControl);
    }
}

void ossiaGrabber::close()
{
    vid.close();
}
