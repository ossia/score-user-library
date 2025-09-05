/*{
  "DESCRIPTION": "Simple line music extended",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/Ykt3ZLD52Wnphvaak)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 800,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.2196078431372549,
    0.4549019607843137,
    0.5058823529411764,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 152,
    "ORIGINAL_DATE": {
      "$date": 1453125294700
    }
  }
}*/

// Simple Line which responds to music
// This is intended to be super simple, to learn how to use VertexShaderArt
// If you're just beginning please feel free to experiment with this or use as a starting point for your shaders

void main()
{
  // vertex_percent is vertexId mapped to [0..1]
  float nb_circles = 10.0;
  float nbpointspercircle = vertexCount/nb_circles;
  float vertex_percent = (vertexId) / (vertexCount-1.0); // We use -1.0 to ensure a point exists at the end
  float x = (vertex_percent*2.0-1.0)*0.7; // Mapping vertex_percent [0..1] to X screen range, which is [-1..1]

  // sound texture has (amplitude, history) for (u,v).
  // u range is [0..1]: 0 is lowest bass, 1 is highest treble
  // v range is [0..1]: 0 is right now, 1 is 4 seconds in the past
  // It is all in the alpha channel of the sound texture

  // Set y position to amplitude in [0..1] range.
  // Y will be 1.0 at peak amplitude (top of screen) and 0.0 for silence (middle of screen)
  float circ_num= mod(vertexId, nb_circles)/nb_circles;
  float y = -0.5+2.0*texture(sound,vec2(circ_num,0.0)).r*0.5;

  float r = 0.3;
  float posx = (0.01*sin(r*time)+r)*(circ_num+1.0) * cos(vertex_percent*2.0*3.14+0.05*time)*0.8*((y*2.0)-1.0);
  float posy = (0.01*sin(r*time)+r)*(circ_num+1.0) * sin(vertex_percent*2.0*3.14+0.0501*time)*0.8*((y*2.0)-1.0);

  gl_PointSize = 5.0; // Set point size in case want to render points instead of line, not used in line
  gl_Position = vec4(posx,posy,0,1); // simply plot onto screen space at z=0 with opacity=1, screen range is [-1..1] for both x and y
  v_color = vec4(sin(time)*sin(time), y+1.0, circ_num, 1.0);
  vec4 aa = background;
}

