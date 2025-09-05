/*{
  "DESCRIPTION": "K Machine exposed shader2  - K Machine exposed shader2, not so smiling",
  "CREDIT": "kolargon (ported from https://www.vertexshaderart.com/art/NfQPZoWHTBFY7AKy5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 490,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1493741405271
    }
  }
}*/


//KDrawmode=GL_TRIANGLES
#define parameter0 1.//KParameter0 0.>>5.
#define parameter1 0.4//KParameter1 0.>>5.
#define parameter2 1.//KParameter2 0.>>1.
#define parameter3 1.//KParameter3 -0.5>>1.
#define parameter4 1.//KParameter4 0.>>2.
#define parameter5 1.//KParameter5 0.>>2.
#define parameter6 0.3//KParameter6 0.1>>0.4
#define parameter7 1.//KParameter7 0.>>1.

#define HPI 1.570796326795
#define PI 3.1415926535898

vec3 hashv3(vec3 _v) {
    return fract(sin(_v * vec3(43758.5453123, 12345.6789012,76543.2109876)));
}

vec3 rotX(vec3 _v, float _rad) {
    vec2 f = sin(vec2(_rad, _rad + HPI));
    vec3 r = _v;
    r.y = _v.y * f.y + _v.z * -f.x;
    r.z = _v.y * f.x + _v.z * f.y;
    return r;
}

vec3 rotY(vec3 _v, float _rad) {
    vec2 f = sin(vec2(_rad, _rad + HPI));
    vec3 r = _v;
    r.x = _v.x * f.y + _v.z * f.x;
    r.z = _v.x * -f.x + _v.z * f.y;
    return r;
}

vec3 rotZ(vec3 _v, float _rad) {
    vec2 f = sin(vec2(_rad, _rad + HPI));
    vec3 r = _v;
    r.x = _v.x * f.x + _v.y * f.y;
    r.y = _v.x * -f.y + _v.y * f.x;
    return r;
}

vec4 perspective(vec3 _v, float _fov, float _near, float _far, vec2 _res) {
    vec4 r = vec4(_v, -_v.z);
    r.xy *= vec2(_res.y / _res.x, 1.0) / tan(radians(_fov * 0.5));
    r.z = (-_v.z * (_far + _near) - 2.0 * _far * _near) / (_far - _near);
    return r;
}

vec3 lookAt(vec3 _v, vec3 _eye, vec3 _look, vec3 _up) {
    vec3 z = normalize(_eye - _look);
    vec3 x = normalize(cross(_up, z));
    vec3 y = cross(z, x);
    vec4 r = mat4(x.x, y.x, z.x, 0.0, x.y, y.y, z.y, 0.0, x.z, y.z, z.z, 0.0, 0.0, 0.0, 0.0, 1.0) *mat4(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -_eye.x, -_eye.y, -_eye.z, 1.0)* vec4(_v, 1.0);
    return r.xyz;
}

#define kCubeVertexCount 36.0

vec3 shapeVertex(float _vid, out vec4 _ni, float _factor) {
    float faceId = floor(_vid / 6.0);
    float vtxId = mod(_vid, 6.0);
    vec2 fp;
    vec3 p;

    if(vtxId <= 1.0) {
        fp = vec2(1.0, 1.0);
    }
    else if(vtxId == 2.0) {
        fp = vec2(-1.0, 1.0);
    }
    else if(vtxId == 3.0) {
        fp = vec2(1.0, -1.0);
    }
    else {
        fp = vec2(-1.0, -1.0);
    }

    if(faceId == 0.0) {
        // front
        p = vec3(fp.x, fp.y, _factor);
        _ni = vec4(0.0, 0.0, 1.0, faceId);
    }
    else if(faceId == 1.0) {
        // back
        p = vec3(-fp.x, fp.y, -1.0);
        _ni = vec4(0.0, 0.0, -1.0, faceId);
    }
    else if(faceId == 2.0) {
        // top
        p = vec3(fp.x, 1.0, -fp.y);
        _ni = vec4(0.0, 1.0, 0.0, faceId);
    }
    else if(faceId == 3.0) {
        // bottom
        p = vec3(fp.x, -1.0, fp.y);
        _ni = vec4(0.0, 0.0, -1.0, faceId);
    }
    else if(faceId == 4.0) {
        // right
        p = vec3(-1.0, fp.y, -fp.x);
        _ni = vec4(-1.0, 0.0, 0.0, faceId);
    }
    else {
        // left
        p = vec3(1.0, fp.y, fp.x);
        _ni = vec4(1.0, 0.0, 0.0, faceId);
    }

    return p;
}

vec3 shade(vec3 _eye, vec3 _p, vec3 _n, vec3 _dfscol, float _amb, vec2 _spec)
{
    vec3 rgb;
    vec3 lit = normalize(vec3(1.0, 1.0, 4.0));

    float diffuse = max(0.0, dot(_n, lit)) * (1.0 - _amb) + _amb;

    vec3 h = normalize(normalize(_eye - _p) + lit);
    float specular = 1.0;
    if(diffuse > 0.0) {
        specular = max(0.1,dot(_n, h));//specular = max(0.0, pow(dot(_n, h), _spec.x));
    }

    rgb = diffuse * _dfscol + specular * _spec.y;

    return rgb;
}

#define elementPerShape 12.

vec3 getShapeKVector(float _vertexId, float _junctionY, float _secondVertY, float _barWidth)
{
    vec3 result = vec3(0., 0.,-1.);

    if(_vertexId<1.)
    {
        result.xy = vec2(0.,0.);
    }
    else

        if(_vertexId<2.)
        {
        result.xy = vec2(0.,1.);
        }

        else
        if(_vertexId<3.)
        {
        result.xy = vec2(_barWidth,1.);
        }
        else //2nd triangle
        if(vertexId<4.)
        {
        result.xy = vec2(0.,0.0);
        }
        else
        if(_vertexId<5.)
        {
        result.xy = vec2(_barWidth,1.);
        }
        else
        if(_vertexId<6.)
        {
        result.xy = vec2(_barWidth,0.);//PROBLEM !!
        }
        else
        if(_vertexId<7.)//3 eme triangle
        {
        result.xy = vec2(_barWidth,_junctionY);
        }
        else
        if(_vertexId<8.)
        {
        result.xy = vec2((_secondVertY+_barWidth),1.);
        }
        else
        if(_vertexId<9.)
        {
        result.xy = vec2(_secondVertY,1.);

        }

        else
        if(_vertexId<10.)//4eme triangle
        {
        result.xy = vec2(_barWidth,_junctionY);

        }
        else
        if(_vertexId<11.)
        {
        result.xy = vec2((_secondVertY+_barWidth),0.);

        }

        else
        if(_vertexId<12.)
        {
        result.xy = vec2(_secondVertY,0.);

        }

    return result;
}

#define elementPerTriangleShape 3.
vec3 getTriangle(float _vertexId, vec2 _center, float _radius, float _angle)
{
    vec3 result = vec3(0., 0.,-1.);

    float localVertexId = mod(_vertexId, elementPerTriangleShape);

    float localAngle = localVertexId*2.*PI/elementPerTriangleShape;
    //result.xy = _center+_radius*vec2(cos(localAngle),sin(localAngle));
    result.xy = _radius*vec2(cos(localAngle),sin(localAngle));
    result = rotZ(result,_angle);
    result.xy+=_center.xy;
    return result;
}

vec3 getTriangleCircle(float _vertexId, vec2 _center, float _radius, float _numberOfElements, float _triangleSize, float _rotationAngleRad, float _cosFactor, float _sinFactor)
{
    vec3 result = vec3(0., 0.,-1.);

    //triangle index
    float shapeId = floor(_vertexId/elementPerTriangleShape);

    //index of the vertex in the triangle
    float localVertexId = mod(_vertexId, elementPerTriangleShape);

    float relShapeId = shapeId/_numberOfElements;

    float trianglePosAngle = relShapeId*(2.*PI)+_rotationAngleRad;

    vec2 trianglePos = vec2(_center.x+_radius*_cosFactor*cos(trianglePosAngle), _center.y+_radius*_sinFactor*sin(trianglePosAngle));

     result = getTriangle(localVertexId, trianglePos, _triangleSize, trianglePosAngle);

    return result;
}

vec3 getTriangleLimitedCircle(float _vertexId, vec2 _center, float _radius, float _numberOfElements, float _triangleSize, float _rotationAngleRad, float _startAngle, float _endAngle, float _cosFactor, float _sinFactor)
{
    vec3 result = vec3(0., 0.,-1.);

    //triangle index
    float shapeId = floor(_vertexId/elementPerTriangleShape);

    //index of the vertex in the triangle
    float localVertexId = mod(_vertexId, elementPerTriangleShape);

    float relShapeId = shapeId/_numberOfElements;

    //float trianglePosAngle = relShapeId*(2.*PI)+_rotationAngleRad;

    //angle must be between _startAngle and _endAngle
    float trianglePosAngle = _startAngle+relShapeId*(_endAngle-_startAngle)+_rotationAngleRad;

    vec2 trianglePos = vec2(_center.x+_radius*_cosFactor*cos(trianglePosAngle), _center.y+_radius*_sinFactor*1.*sin(trianglePosAngle));

    //vec2 trianglePos = vec2(relShapeId*10.,0.);
    //result.xy = trianglePos;//getTriangle(localVertexId, trianglePos, 0.02, trianglePosAngle);
    result = getTriangle(localVertexId, trianglePos, _triangleSize, trianglePosAngle+PI/2.);

    return result;
}

#define shapeNumForEye 20.
#define shapeNumForMouth 20.
#define shapeNumForHead 40.
#define shapeNumForPupil 1.
#define shapeNumForEar 30.

void main() {

    vec3 color = vec3(1.);
    float vertu = (vertexId/vertexCount);

    float sndFactor = texture(sound, vec2(0.01, 0.)).r;

    float eyesY = 0.3;
    float eye1X = 0.35;

    float earsY = 0.4;
    float ear1X = 0.85;

    float mouthY = -0.3;
    vec2 center = vec2(-0.5,eyesY);

    vec3 _v = vec3(0.,0.,0.);

    float vertexCount = 0.;

    float stopVerticesForEye1 = shapeNumForEye*elementPerTriangleShape;
    float stopVerticesForEye2 = stopVerticesForEye1+shapeNumForEye*elementPerTriangleShape;
    float stopVerticesForMouth = stopVerticesForEye2+shapeNumForMouth*elementPerTriangleShape;
    float stopVerticesForHead = stopVerticesForMouth+shapeNumForHead*elementPerTriangleShape;
    float stopVerticesForPupil1 = stopVerticesForHead+shapeNumForPupil*elementPerTriangleShape;
    float stopVerticesForPupil2 = stopVerticesForPupil1+shapeNumForPupil*elementPerTriangleShape;

    float stopVerticesForEar1 = stopVerticesForPupil2+shapeNumForEar*elementPerTriangleShape;
    float stopVerticesForEar2 = stopVerticesForEar1+shapeNumForEar*elementPerTriangleShape;

    float numberOfTriangles = 20.;
    if(vertexId< stopVerticesForEye1)//1 eye
    {
        center = vec2(-eye1X,eyesY);
        _v = getTriangleCircle(vertexId, center, 0.15, shapeNumForEye, 0.05+sndFactor/50., time, parameter4*cos(time), parameter4*cos(time));

    }
    else//2nd eye
        if(vertexId< stopVerticesForEye2)
        {
        center = vec2(eye1X,eyesY);
        _v = getTriangleCircle(vertexId, center, 0.15, shapeNumForEye, 0.05+sndFactor/50., -time, parameter5*sin(time), parameter5*sin(time));

        }
        else//mouth
        if(vertexId< stopVerticesForMouth)
        {
        //mouth
        center = vec2(0.,mouthY);
        //numberOfTriangles = 20.;
        //_v = getTriangleLimitedCircle(vertexId-stopVerticesForEye2, center, 0.4, shapeNumForMouth, 0.02+sndFactor/10., 0., PI, 2.*PI, parameter2, parameter3);
        _v = getTriangleCircle(vertexId, center, 0.25, shapeNumForMouth, 0.05+sndFactor/50., 7.*time, parameter0, parameter1*cos(time));
        }

        else
        if(vertexId< stopVerticesForHead)
        {

        center = vec2(0.,0.);
        //numberOfTriangles = 100.;
        _v = getTriangleLimitedCircle(vertexId, center, 0.8, shapeNumForEye, 0.01+sndFactor/10., time, PI, 2.*PI, 1.,1.);
        }
        else
        if(vertexId< stopVerticesForPupil1)
        {

        center = vec2(eye1X,eyesY);
        //numberOfTriangles = 100.;
        //_v = getTriangleLimitedCircle(vertexId, center, 0., shapeNumForPupil, 0.02, time, PI, 2.*PI, parameter6, parameter7);
        _v = getTriangleCircle(vertexId, center, 0.0, shapeNumForEye, 0.03+sndFactor/50., 7.*time, 1., parameter5);
        }
        else
        if(vertexId< stopVerticesForPupil2)
        {

        center = vec2(-eye1X,eyesY);
        //numberOfTriangles = 100.;
        //_v = getTriangleLimitedCircle(vertexId, center, 0., shapeNumForPupil, 0.02, time, PI, 2.*PI, parameter6, parameter7);
        _v = getTriangleCircle(vertexId, center, 0.0, shapeNumForEye, 0.03+sndFactor/50., -5.*time, 1., parameter5);
        }
        else
        if(vertexId< stopVerticesForEar1)
        {

        center = vec2(ear1X+parameter6/2.,earsY);
        _v = getTriangleCircle(vertexId, center, parameter6, shapeNumForEar, 0.05+sndFactor/50., 5.*time, 1., parameter7);
        }
        else
        if(vertexId< stopVerticesForEar2)
        {

        center = vec2(-ear1X-parameter6/2.,earsY);
        _v = getTriangleCircle(vertexId, center, parameter6, shapeNumForEar, 0.05+sndFactor/50., -5.*time, 1., parameter7);
        }
    _v.x*=resolution.y/resolution.x;
    gl_Position = vec4(_v, 1.);
    gl_PointSize = 10.;
    v_color = vec4(color, 1.);

}

