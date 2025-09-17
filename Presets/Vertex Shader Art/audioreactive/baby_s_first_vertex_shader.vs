/*{
  "DESCRIPTION": "baby's first vertex shader",
  "CREDIT": "chemlo (ported from https://www.vertexshaderart.com/art/2cL3kfaKBExkWc5Le)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Particles"
  ],
  "POINT_COUNT": 240,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.07450980392156863,
    0.8431372549019608,
    0.8431372549019608,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 197,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1493456585326
    }
  }
}*/

#define PI radians(180.)
#define GAMMA 0.454545

float soundIntensity(float frq){
 return texture(sound, vec2(frq, 0)).r;
}

float meanIntensity(){
   const float samples = 50.;
  float intensity;
  for(float i = 0.; i < samples; i+=1./samples){
     intensity += soundIntensity(i);
  }
 return intensity/samples;
}

vec3 getVertexColor(){
 float ratio = vertexId/vertexCount;
   float intensity = soundIntensity(ratio);
   return vec3(0.5, 0., 0.5);
}

void main(){
   float aspect = resolution.x / resolution.y;
 float vertexRatio = vertexId/vertexCount;
    float vertexRadians = vertexRatio * PI * 2.;

    float x = cos(vertexRadians);
    float y = sin(vertexRadians);
    float z = vertexRatio;

    gl_Position = vec4(
      x,
      y*aspect,
      1. - z,
      3. - meanIntensity()
    );

   v_color = vec4(getVertexColor(), 0.5);

   float frequencyScale = 6.;
   gl_PointSize = pow(soundIntensity(0.075*pow(vertexRatio+0.5,frequencyScale))+1.1, 7.);

}