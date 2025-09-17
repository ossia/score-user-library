/*{
  "DESCRIPTION": "Cercle Tunnel - K Machine exposed",
  "CREDIT": "kolargon (ported from https://www.vertexshaderart.com/art/qB4krC8RnH5HEFLww)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
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
    "ORIGINAL_VIEWS": 311,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1494623497583
    }
  }
}*/

//KDrawmode=GL_TRIANGLES

//for the K Machine
#define parameter0 0.//KParameter0 0.>>8.
#define parameter1 3.//KParameter1 1.>>8.
#define parameter2 3.//KParameter2 0.>>40.
#define parameter3 20.//KParameter3 5>>100.
#define parameter4 0.02//KParameter4 0.01>>0.05
#define parameter5 30.//KParameter5 5.>>50.
#define parameter6 1.//KParameter6 0.>>1.
#define parameter7 1.//KParameter7 1.>>5.

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

mat4 uniformScale(float _s) {
    return mat4(
        _s, 0, 0, 0,
        0, _s, 0, 0,
        0, 0, _s, 0,
        0, 0, 0, 1);
}

vec3 NormalFromTriangleVertices(vec3 _triangleVertices0, vec3 _triangleVertices1, vec3 _triangleVertices2)
{
    vec3 u = _triangleVertices0 - _triangleVertices1;
    vec3 v = _triangleVertices1 - _triangleVertices2;
    return cross(v, u);
}

void drawShapeFromVerticesList(const vec3 _vt[12],const vec3 _cl[4], const float _vtn, const float _vId, const vec3 _pos, const vec3 _rot, out vec3 _n, out vec3 _v, out vec3 _color, float _scale)
{
  float localVid = mod(_vId,_vtn);

  if(localVid< 1.)
    {

        _v = _vt[0];
        _n = NormalFromTriangleVertices(_vt[0], _vt[1],_vt[2]);
        _color = _cl[0];

    }
  else
    if(localVid< 2.)
    {
        _v = _vt[1];
       _n = NormalFromTriangleVertices(_vt[0], _vt[1],_vt[2]);
      _color = _cl[0];
    }
  else
    if(localVid< 3.)
    {
        _v = _vt[2];
       _n = NormalFromTriangleVertices(_vt[0], _vt[1],_vt[2]);
      _color = _cl[0];
    }
  else
    if(localVid< 4.)
    {
        _v = _vt[3];
       _n = NormalFromTriangleVertices(_vt[3], _vt[4],_vt[5]);
      _color = _cl[1];
    }
  else
    if(localVid< 5.)
    {
        _v = _vt[4];
       _n = NormalFromTriangleVertices(_vt[3], _vt[4],_vt[5]);
      _color = _cl[1];
    }
  else
    if(localVid< 6.)
    {
        _v = _vt[5];
       _n = NormalFromTriangleVertices(_vt[3], _vt[4],_vt[5]);
      _color = _cl[1];
    }
  else
    if(localVid< 7.)
    {
        _v = _vt[6];
       _n = NormalFromTriangleVertices(_vt[6], _vt[7],_vt[8]);
      _color = _cl[2];
    }
  else
    if(localVid< 8.)
    {
        _v = _vt[7];
       _n = NormalFromTriangleVertices(_vt[6], _vt[7],_vt[8]);
      _color = _cl[2];
    }
  else
    if(localVid< 9.)
    {
        _v = _vt[8];
       _n = NormalFromTriangleVertices(_vt[6], _vt[7],_vt[8]);
      _color = _cl[2];
    }
  else
    if(localVid< 10.)
    {
        _v = _vt[9];
       _n = NormalFromTriangleVertices(_vt[9], _vt[10],_vt[11]);
      _color = _cl[3];
    }
  else
    if(localVid< 11.)
    {
        _v = _vt[10];
       _n = NormalFromTriangleVertices(_vt[9], _vt[10],_vt[11]);
      _color = _cl[3];
    }
  else
    if(localVid< 12.)
    {
        _v = _vt[11];
       _n = NormalFromTriangleVertices(_vt[9], _vt[10],_vt[11]);
      _color = _cl[3];
    }

  _v = (vec4(_v,1.)*uniformScale(_scale)).xyz;
  //_n = (vec4(_n,1.)*uniformScale(_scale)).xyz;

  _v = rotY(_v,_rot.y);
  _n = rotY(_n,_rot.y);

  _v = rotX(_v,_rot.x);
  _n = rotX(_n,_rot.x);

  _v = rotZ(_v,_rot.z);
  _n = rotZ(_n,_rot.z);

  _v += _pos;
  //_n += _pos;
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

vec3 shade(vec3 _eye, vec3 _p, vec3 _n, vec3 _dfscol, float _amb, vec2 _spec) {
    vec3 rgb;
    vec3 lit = normalize(vec3(1.0, 1.0, 4.0));
    float NDotLit = clamp(dot(_n, lit), 0.0, 1.0);
    float diffuse = max(0.0, NDotLit) * (1.0 - _amb) + _amb;

    vec3 h = normalize(normalize(_eye - _p) + lit);
    float specular = 0.0;
    if(diffuse > 0.0) {
        float NDoth = clamp(dot(_n, h), 0.0, 1.0);
        specular = max(0.0, pow(NDoth, _spec.x));
    }

    rgb = diffuse * _dfscol + specular * _spec.y;

    return rgb;
}

void main() {

  vec3 color = vec3(1.);

    //KVsa
    float loopDurationMs = 4000.;
    float timeProgress = mod(time*1000.,loopDurationMs);
    float relLoopProgress = timeProgress/loopDurationMs;
    //KVsa

    float finalRelLoopProgress = relLoopProgress;//mod(relLoopProgress,(1./factor));
    float numberOfSubLoops = floor(parameter1);
    float subLoopLength = 1./numberOfSubLoops;
    finalRelLoopProgress = mod(relLoopProgress,subLoopLength)/subLoopLength;

  float finalRelLoopProgress2 = relLoopProgress;//mod(relLoopProgress,(1./factor));
    float numberOfSubLoops2 = floor(1.);
    float subLoopLength2 = 1./numberOfSubLoops2;
    finalRelLoopProgress2 = mod(relLoopProgress,subLoopLength2)/subLoopLength2;

  vec3 _v = vec3(0.,0.,0.);
  vec3 _n = vec3(0.,0.,0.);

  vec3 shapeVertices[12];
  float shapeSize = 12.;

  float maxShapeCount = floor(vertexCount/shapeSize);
  float finalVertexId = min(vertexId,maxShapeCount*shapeSize);
  float shapeId = floor(finalVertexId/shapeSize);
  float relShapeId = shapeId/maxShapeCount;
  float scale = parameter4;

  float numberOfShape = floor(parameter3);//floor(0.03*((vertexCount/shapeSize)/5.));
  float localShapeId = mod(shapeId,numberOfShape);
  float localRelShapeId = localShapeId/numberOfShape;

  float sf = 0.;//texture(sound, vec2(0.23, localRelShapeId)).r ;

  float radius = 0.1+sf*0.09;//+0.1*floor(shapeId/numberOfShape);

  vec3 shapePos = vec3(radius*cos(2.*PI*localRelShapeId),radius*sin(2.*PI*localRelShapeId),0.);

  float factor = parameter0*abs(cos(PI*finalRelLoopProgress+floor(shapeId/numberOfShape)));
  float factor1 = 1.;

  shapeVertices[0] = vec3(-0.5,0.,-0.5);
  shapeVertices[1] = vec3(0.5,0.,-0.5);
  shapeVertices[2] = vec3(0.,factor1,0.-factor);
  shapeVertices[3] = vec3(0.5,0.,-0.5);
  shapeVertices[4] = vec3(0.5,0.,0.5);
  shapeVertices[5] = vec3(0.+factor,factor1,0.);
  shapeVertices[6] =vec3(0.5,0.,0.5);
  shapeVertices[7] =vec3(-0.5,0.,0.5);
  shapeVertices[8] =vec3(0.,factor1,0.+factor);
  shapeVertices[9] =vec3(-0.5,0.,0.5);
  shapeVertices[10] =vec3(-0.5,0.,-0.5);
  shapeVertices[11] =vec3(0.-factor,factor1,0.);

  vec3 shapeColors[4];

  shapeColors[0] = vec3(1.,0.,0.);
  shapeColors[1] = vec3(0.,1.,1.);
  shapeColors[2] = vec3(1.,0.,0.);
  shapeColors[3] = vec3(1.,1.,0.);

  vec3 rot = vec3(PI/2.,0.,(time*2.*PI/10.)*parameter2+ (localRelShapeId*PI*2.));
  drawShapeFromVerticesList(shapeVertices, shapeColors, shapeSize, finalVertexId, shapePos, rot, _n, _v, color, scale);

  //create the big circle
  float masterCircleRadius = 0.4;
  float numberOfCirclesInMasterCircle = floor(parameter5);
  float vertexPerSmallCircle = numberOfShape*shapeSize;
  float masterCircleId = floor(finalVertexId/vertexPerSmallCircle);
  float relMasterCircleId = masterCircleId/numberOfCirclesInMasterCircle;

  _v.y-=masterCircleRadius;

  _v = rotX(_v,-(relMasterCircleId*2.*PI+time*parameter7));
  _n = rotX(_v,-(relMasterCircleId*2.*PI+time*parameter7));
  _v.z-=0.58;

  vec3 eye = vec3(0., 0., -1.);
  color = shade(eye, _v, _n, color, 0.8, vec2(64.0, 3.8));

  vec3 p = lookAt(_v, eye, vec3(0.,1.7,0.0), vec3(0.0, 1.0, 0.0));
  gl_Position = perspective(p, 60.0, 0.1, 10.0, resolution);

  _v.x*=resolution.y/resolution.x;

  gl_PointSize = 10.;
  v_color = vec4(color, 1.);

}

