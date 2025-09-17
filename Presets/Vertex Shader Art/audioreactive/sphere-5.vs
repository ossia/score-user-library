/*{
  "DESCRIPTION": "sphere",
  "CREDIT": "samthrasher (ported from https://www.vertexshaderart.com/art/yxx6Qzd29foXStAvK)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 11,
    "ORIGINAL_DATE": {
      "$date": 1493615394623
    }
  }
}*/

#define PI radians(180.)
#define GAMMA 0.454545

float soundIntensity(float frq){
 return texture(sound, vec2(frq, 0)).r;
}

float meanIntensity(){
   const float samples = 0.;
  float intensity;
    for(float i = 0.; i < samples; i+=1./samples){
     intensity += soundIntensity(i);
    }
 return intensity/samples;
}

float maxIntensity(){
   const float samples = 50.;
  float intensity;
    for(float i = 0.; i < samples; i+=1./samples){
     intensity = max(intensity, soundIntensity(i));
    }
 return intensity;
}

vec3 getVertexColor(){
    float phase = mod(time / 2.0, 1.0);
 float vertexRatio = vertexId/vertexCount;
  float r = 0.5 * mod(0.24321 * vertexRatio + phase, 1.0);
 float g = 0.5 * mod(0.13433 * vertexRatio + phase, 1.0);
    float b = 0.5 * mod(0.09001 * vertexRatio + phase, 1.0);
    return vec3(r, g, b);
}

void main(){
   float aspect = resolution.x / resolution.y;
    float n_y = floor(sqrt(vertexCount));
    float n_phi = n_y;
    float rad = 0.6;
 float i_y = floor(vertexId/n_y);
   float i_phi = floor(vertexId - i_y);
    float theta = -PI * (-1.0 + 2.0 * i_y / (n_y - 1.0));
    float phi = 2.0 * PI * (-1.0 + 2.0 * i_phi / (n_phi - 1.0));

    float phase = mod(time + 0.01*i_phi, 2.0 * PI);

    phi = mod(phi + phase, 2.0 * PI);
   float y = cos(theta);
    float x = sin(theta) * cos(phi);
    float z = sin(theta) * sin(phi);

   float vertexRatio = vertexId/vertexCount;
    float vertexRadians = vertexRatio * PI * 2.;

    //float x = cos(vertexRadians);
    //float y = sin(vertexRadians);
    //float z = vertexRatio;

    vec4 position = vec4(
      x,
      y * aspect,
      z,
   1.0
    );

    gl_Position = vec4(
      x,
      y * aspect,
      z,
      1./soundIntensity(cos(theta)*cos(phi))
    );

   v_color = vec4(getVertexColor(), 0.5);

   float frequencyScale = 6.;
   //gl_PointSize = pow(soundIntensity(0.075*pow(vertexRatio+0.5,frequencyScale))+1.1, 7.);
    gl_PointSize = 8.0;
}