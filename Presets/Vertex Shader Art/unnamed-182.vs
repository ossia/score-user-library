/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/wfSM5cyoAJHAg6od5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 23936,
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
    "ORIGINAL_VIEWS": 72,
    "ORIGINAL_DATE": {
      "$date": 1571791001825
    }
  }
}*/


//KDrawmode=GL_TRIANGLES

#define radiusParam0 0.10//KParameter 0.03>>0.3
#define radiusParam1 0.82//KParameter 0.>>1.
#define angleParam0 0.02//KParameter 0.>>1.
#define sndFactor 0.8//KParameter 0.>>1.
#define PointSizeFactor 0.18//KParameter 0.>>1.
#define kpx -5.0//KParameter 0.>>4.

#define HPI 1.570796326795
#define PI 3.1415926535898

//KverticesNumber=233333
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

#define elementPerTriangleShape 3.
vec3 getTriangle(float _vertexId, vec2 _center, float _radius, float _angle)
{
    vec3 result = vec3(0., 0.,-1.);

    float localAngle = _vertexId*2.*PI/elementPerTriangleShape;
    result.xy = _radius*vec2(cos(localAngle),sin(localAngle));
    result = rotZ(result,_angle);
    result.xy+=_center.xy;
    return result;
}

void main() {

    //fix a maximum vertexId
    float localVertexId = vertexId;
    float maxShapeCount = floor(vertexCount / elementPerTriangleShape);

    float relVertexId = vertexId/vertexCount-kpx;

    maxShapeCount = floor(maxShapeCount/2.);

    float maxVerticesNumber = maxShapeCount*elementPerTriangleShape;

    if(localVertexId>=maxVerticesNumber)
        localVertexId = maxVerticesNumber-1.5;

    float shapeId = floor(localVertexId / elementPerTriangleShape);
    float shapeVertexId = mod(localVertexId, elementPerTriangleShape);
    float relShapeId = shapeId/maxShapeCount;

    float aspect = resolution.x / resolution.y;

    vec2 center=vec2(0., 0.);

    if(localVertexId>=(maxVerticesNumber/2.))
    {
        localVertexId = localVertexId - (maxVerticesNumber/2.);
    }

    float localShapeId = floor(localVertexId/elementPerTriangleShape);
    float localRelShapeId =localShapeId/(maxShapeCount/2.);

    //float snd = texture(soundBuffer, vec2(localRelShapeId,0.) ).a* sndFactor;
        float snd = texture(sound, vec2(localRelShapeId,0.4) ).r* sndFactor;
    float radius = (1.- localRelShapeId)*radiusParam0+(radiusParam1/10.*cos(1.*2.*PI+localShapeId) );
    float angle = 2.*PI*time+angleParam0*50.*shapeId/500.+snd;

    vec3 shapep = getTriangle(localVertexId, center, radius, angle)
    ;

    shapep.x/=aspect;
    vec4 m = texture(touch, vec2(0., localShapeId /(maxShapeCount/2.)));

    shapep += vec3( m.xy, shapep.z+2.);

    if(shapeId>maxShapeCount/2.)
    {
        shapep.x = -shapep.x;
    }

    gl_Position = vec4(shapep,1.);
    gl_PointSize = 3.*PointSizeFactor;

    v_color = vec4(vec3(-m.y*3.5,mod(-m.x,shapeId/2.3),.5), 1.0);

}
