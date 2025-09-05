/*{
  "DESCRIPTION": "swift earthworm",
  "CREDIT": "kolargon (ported from https://www.vertexshaderart.com/art/vycmMsgS7e6fHw5tD)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Abstract"
  ],
  "POINT_COUNT": 7200,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 218,
    "ORIGINAL_DATE": {
      "$date": 1551818526375
    }
  }
}*/

//In progres. Based on gman's https://www.vertexshaderart.com/art/uPwKetxzwcL2PFZd6
//Should be 'K Machine' compliant. Not tested yet.

#define PI radians(180.0)

#define kShapeVertexCount 36.0
#define kVertexPerShape 6.0
#define numberOfShapesPerGroup 5.0
#define fakeVerticeNumber 72000.

const float dim = 120.;
const float off = 0.1;
const vec3 vAlb = vec3(0.5);

/////////////////////////////
//K Machine parameters
/////////////////////////////

//KDrawmode=GL_TRIANGLE_STRIP

#define tubeSpeedFactor 0.9 //KParameter 0.>>4.
#define cudeSpeedFactor 80. //KParameter 0.>>150.
#define SizeFactorX 100.1 //KParameter 1.>>10.
#define radiusSizeFactor 0.1 //KParameter 0.05>>0.2
#define cubeSizeFactor 1. //KParameter 0.5>>40.
#define cubeScaleFactorY 1. //KParameter 0.5>>40.
#define cubeScaleFactorZ 1. //KParameter 0.5>>40.

mat4 rotZ(float _radAngle) {
    float s = sin(_radAngle);
    float c = cos(_radAngle);

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1);
}

mat4 scale(vec3 _s) {
  return mat4(
    _s[0], 0, 0, 0,
    0, _s[1], 0, 0,
    0, 0, _s[2], 0,
    0, 0, 0, 1);
}

mat4 persp(float _fov, float _aspect, float _zNear, float _zFar) {
  float f = tan(PI * 0.5 - 0.5 * _fov);
  float rInv = 1.0 / (_zNear - _zFar);

  return mat4(
    f / _aspect, 0., 0., 0.,
    0., f, 0., 0.,
    0., 0., (_zNear + _zFar) * rInv, -1.,
    0., 0., _zNear * _zFar * rInv * 2., 0.);
}

mat4 lookAt(vec3 _eye, vec3 _targ, vec3 _up) {
  vec3 zAx = normalize(_eye - _targ);
  vec3 xAx = normalize(cross(_up, zAx));
  vec3 yAx = cross(zAx, xAx);

  return mat4(
    xAx, 0.,
    yAx, 0.,
    zAx, 0.,
    _eye, 1.);
}

vec3 getTrajPoint(const float _id) {
  return vec3(
    sin(_id * 0.99),
    sin(_id * 2.43),
    sin(_id * 1.57));
}

void getPosAndAxisMat(const float _rel, const float _delta, out mat3 _axis, out mat3 _pos)
{

  float pg = _rel + _delta;

  vec3 r0 = getTrajPoint(pg + off * 0.);
  vec3 r1 = getTrajPoint(pg + off * 1.);
  vec3 r2 = getTrajPoint(pg + off * 2.);

  _pos = mat3(
    getTrajPoint(pg + off * 0.),
    getTrajPoint(pg + off * 1.),
    getTrajPoint(pg + off * 2.));

  vec3 s0 = normalize(_pos[1] - _pos[0]);
  vec3 s1 = normalize(_pos[2] - _pos[1]);

  vec4 zaxis = vec4(normalize(s1 - s0),1.);
  vec4 xaxis = vec4(normalize(cross(s0, s1)),1.);
  vec4 yaxis = vec4(normalize(cross(zaxis.xyz, xaxis.xyz)),1.);

  _axis = mat3(
    xaxis,
    yaxis,
    zaxis);

}

void getTrajMat(float _shapeId, float _shapeCount, float _timeB, out mat4 _wmat, out mat4 _emat) {

  float prog = (_shapeId / _shapeCount)+_timeB;

  mat3 axis, mPos;

  getPosAndAxisMat((_shapeId / _shapeCount), _timeB, axis, mPos);

  //pos mtx
  _wmat = mat4(
    vec4(axis[0], 0),
    vec4(axis[1], 0),
    vec4(axis[2], 0),
    vec4(mPos[0] * dim, 1));

  //orient mtx
  vec3 eye = mPos[0] * dim + axis[2] * 1.;
  vec3 target = mPos[1] * dim + axis[2];
  vec3 up = axis[1];

  mat4 cmat = lookAt(eye, target, up);
  _emat = inverse(cmat);

}

#define kShapeVertexCount 36.0
#define kVertexPerShape 6.0

vec3 shapeVertex(float _vId, out vec4 _nI)
{
    float faceId = floor(_vId / kVertexPerShape);
    float vtxId = mod(_vId, kVertexPerShape);
    vec2 fp;
    vec3 v;

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

        v = vec3(fp.x, fp.y, 1.0);
        _nI = vec4(0.0, 0.0, 1.0, faceId);
    }
    else if(faceId == 1.0) {

        v = vec3(-fp.x, fp.y, -1.0);
        _nI = vec4(0.0, 0.0, -1.0, faceId);
    }
    else if(faceId == 2.0) {

        v = vec3(fp.x, 1.0, -fp.y);
        _nI = vec4(0.0, 1.0, 0.0, faceId);
    }
    else if(faceId == 3.0) {

        v = vec3(fp.x, -1.0, fp.y);
        _nI = vec4(0.0, -1.0, 0.0, faceId);
    }
    else if(faceId == 4.0) {

        v = vec3(-1.0, fp.y, -fp.x);
        _nI = vec4(-1.0, 0.0, 0.0, faceId);
    }
    else {

        v = vec3(1.0, fp.y, fp.x);
        _nI = vec4(1.0, 0.0, 0.0, faceId);
    }

    return v;
}

mat4 rotMatx(vec3 _axis, float _angle)
{
    _axis = normalize(_axis);
    float s = sin(_angle);
    float c = cos(_angle);
    float oc = 1.0 - c;

    return mat4(oc * _axis.x * _axis.x + c, oc * _axis.x * _axis.y - _axis.z * s, oc * _axis.z * _axis.x + _axis.y * s, 0.0,
        oc * _axis.x * _axis.y + _axis.z * s, oc * _axis.y * _axis.y + c, oc * _axis.y * _axis.z - _axis.x * s, 0.0,
        oc * _axis.z * _axis.x - _axis.y * s, oc * _axis.y * _axis.z + _axis.x * s, oc * _axis.z * _axis.z + c, 0.0,
        0.0, 0.0, 0.0, 1.0);
}

vec3 shade(vec3 _eye, vec3 _p, vec3 _n, vec3 _dfscol, float _amb, vec2 _spec)
{
    vec3 rgb;
    vec3 lit = normalize(vec3(1.0, 1.0, 4.0));

    float diffuse = max(0.0, dot(_n, lit)) * (1.0 - _amb) + _amb;

    vec3 h = normalize(normalize(_eye - _p) + lit);
    float specular = 1.0;
    if(diffuse > 0.0) {
        specular = max(0.,dot(_n, h));
    }

    rgb = diffuse * _dfscol + specular * _spec.y;

    return rgb;
}

void addPtLight( vec3 vLightPos, vec3 vLightColor, in vec3 _pos, in vec3 _norm, inout vec3 vDiffuse, inout vec3 vSpecular )
{
  vec3 vLightDir = normalize(vLightPos - _pos);
  vec3 vViewDir = normalize(-_pos);

  float NdotL = max( 0.0, dot( vLightDir, _norm ) );

  vec3 vHalfAngle = normalize( vViewDir + vLightDir );

  float NdotH = max( 0.0, dot( vHalfAngle, _norm ) );

  vDiffuse += NdotL * vLightColor;

  float fPower = 80.0;
  vSpecular += pow( NdotH, fPower ) * (fPower * 8.0 * PI) * NdotL * vLightColor;
}

void addDirLight( vec3 _vLDir, vec3 _vLColor, in vec3 _pos, in vec3 _norm, inout vec3 _vDiff, inout vec3 _vSpec )
{
  vec3 vViewDir = normalize(-_pos);

  float NdotL = max( 0.0, dot( _vLDir, _norm ) );

  vec3 vHalfAngle = normalize( vViewDir + _vLDir );

  float NdotH = max( 0.0, dot( vHalfAngle, _norm ) );

  _vDiff += NdotL * _vLColor;

  float fPower = 80.0;
  _vSpec += pow( NdotH, fPower ) * (fPower * 8.0 * PI) * NdotL * _vLColor;
}

vec3 lightget(const vec3 vAlbedo, const vec3 _pos, const vec3 _eyePos, const vec3 _norm )
{
  vec3 vDiffuseLight = vec3(0.0);
  vec3 vSpecLight = vec3(0.0);

  vec3 vAmbient = vec3(1., 1., 1.);
  vDiffuseLight += vAmbient;
  vSpecLight += vAmbient;

  addPtLight( vec3(3.0, 2.0, 30.0), vec3( 0.2, 0.2,0.2),_pos, _norm, vDiffuseLight, vSpecLight );

  addDirLight( normalize(vec3(0.0, -1.0, 0.0)), vAmbient * 0.1, _pos, _norm, vDiffuseLight, vSpecLight );

  vec3 vViewDir = normalize(-_eyePos);

  float fNdotD = clamp(dot(_norm, vViewDir), 0.0, 1.0);
  vec3 vR0 = vec3(0.04);
  vec3 vFresnel = vR0 + (1.0 - vR0) * pow(1.0 - fNdotD, 5.0);

  vec3 vColor = mix( vDiffuseLight * vAlbedo, vSpecLight, vFresnel );

  return vColor;
}

vec3 lightPost( vec3 _vColor )
{
  float exposure = 1.0;
  _vColor = vec3(1.0) - exp2( _vColor * -exposure );

  _vColor = pow( _vColor, vec3(1.0 / 2.2) );

  return _vColor;
}

//#define EYE_STATIC true
//#define STOP_TRAJ true
#define DYN_GROUPID true
#define SOUND_REACT true

void main() {

    float finalVertexId = mod(vertexId,fakeVerticeNumber);
    float finalVertexCount = min(vertexCount,fakeVerticeNumber);
    //shape
    float shapeCount = floor(finalVertexCount / kShapeVertexCount);
    float shapeId = floor(finalVertexId / kShapeVertexCount);
    float shapeVertexId = mod(finalVertexId, kShapeVertexCount);
    float shapeRelId = shapeId/shapeCount;

    //group
    float groupId = floor(shapeId/numberOfShapesPerGroup);
    float groupCount = floor(shapeCount/numberOfShapesPerGroup);
    float shapeIdInGroup = mod(shapeId,numberOfShapesPerGroup);
    float relShapeGroupId = shapeIdInGroup/numberOfShapesPerGroup;
    float relGroupId = groupId/groupCount;

   #ifdef SOUND_REACT
   float snd = 2.*texture(sound, vec2(0., (1.-relGroupId))).r;
   #else
   float snd = 1.;
   #endif

  #ifdef STOP_TRAJ
  float timeB = 14.;
  #else
  float timeB = time * tubeSpeedFactor;
  #endif

  //Static eye
  #ifdef EYE_STATIC
  vec3 eye = vec3(0.5, 0.5, 2.5)*dim;
  vec3 target = vec3(0.5, 0.5, 0.)*dim;
  vec3 up = vec3(0.5, 0.5, 1.5);
  #else
   //Following eye
  mat3 axis, sPos;// = getAxisMat(0., timeB);
  getPosAndAxisMat(0., timeB, axis, sPos);
  vec3 eye = sPos[0] * dim + axis[0].xyz * 1.;
  vec3 target = sPos[2] * dim + axis[2];
  vec3 up = axis[1];
  #endif

 //rotation around eye z axis
  //mat4 rotMat = rotationMatrix(zaxis, time*PI);
  //xaxis = (rotMat*vec4(xaxis,1.)).xyz;
  //yaxis = (rotMat*vec4(yaxis,1.)).xyz;

  //

  mat4 vmat = inverse(lookAt(eye, target, up));

    vec4 cNorm;

    vec3 cubep = shapeVertex(shapeVertexId, cNorm);;

    mat4 scaleMat = scale(vec3(cubeSizeFactor,cubeScaleFactorY*cubeSizeFactor*snd,cubeScaleFactorZ*cubeSizeFactor));

    cubep = (scaleMat*vec4(cubep,1.)).xyz;

    mat4 zrot = rotZ(relShapeGroupId*2.*PI);//shape orientation
    cubep = (zrot*vec4(cubep,1.)).xyz;

    cNorm *= zrot;
     //create the circle group
    float radius =100.*radiusSizeFactor;
    cubep.x+= radius*sin(2.*PI*relShapeGroupId);
    cubep.y+= radius*cos(2.*PI*relShapeGroupId);
  //cubep.z = mod(time*2.,3.);
  //cubep = vec3(cubep.x , cubep.y+sndFactor*snd, cubep.z+lineId*patternSize +mod(time*speedFactor,patternSize));//position

  vec3 pos;

  //shapeId = mod(shapeId+time, shapeCount);

  mat4 posmat, rotmat;

  #ifdef DYN_GROUPID
  getTrajMat(mod(groupId-time*cudeSpeedFactor,groupCount), groupCount, timeB, posmat, rotmat);
  #else
   getTrajMat(groupId, groupCount, timeB, posmat, rotmat);
  #endif

  //shape orientation
  cubep = (vec4(cubep.xyz,1.)*rotmat).xyz;
  cNorm *= rotmat;

  //shape position
  cubep+= (posmat * vec4(0.,0.,0., 1)).xyz;

  //vec3 finalColor = shade(eye, cubep, cNorm.xyz, vec3(1.), 0.6, vec2(64.0, .8));

  //vec3 LightSurface(const vec3 vAlbedo, const vec3 _eyePos, const vec3 _norm )
  vec3 finalColor = lightget(vAlb, cubep, eye, cNorm.xyz);
  lightPost(finalColor);

  gl_PointSize = 2.;
  mat4 pmat = persp(radians(60.0), resolution.x / resolution.y, .1, 1000.0);
  gl_Position = pmat * vmat * vec4(cubep, 1);

  v_color = vec4(finalColor,1.);
}

// Removed built-in GLSL functions: inverse