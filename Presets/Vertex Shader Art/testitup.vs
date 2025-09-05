/*{
  "DESCRIPTION": "testitup",
  "CREDIT": "lilhomiedowntown (ported from https://www.vertexshaderart.com/art/btdHcA68nwnRPi6G5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1669,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.20392156862745098,
    0.396078431372549,
    0.6431372549019608,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1654324833808
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {

  float pointSize=mix(10.,0.,sin(time)*0.5+0.5);
  float pointSeparation=20.;
  float countX=40.;
  float countY=40.;
  float id=floor(vertexId/countY);
  float mox=mod(vertexId,countX);
  float inPosX=((mox/(countX-1.))-0.5)*2.;
  float inPosY=((id/(countY-1.))-0.5)*2.;

  pointSize*=pow(abs(inPosY+inPosX),.4)*1.3;

  vec2 pos=vec2(inPosX,inPosY);

  gl_Position=vec4(pos.x,pos.y,-1,1);
  gl_PointSize=pointSize;
  vec3 col=hsv2rgb(vec3(gl_Position.xy,1));
  v_color = vec4(col,1);
}