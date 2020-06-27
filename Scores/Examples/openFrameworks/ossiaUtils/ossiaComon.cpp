#include "ossiaComon.h"

namespace ossiaComon
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

}
