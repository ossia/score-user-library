/*{
  "DESCRIPTION": "raster - just learning...",
  "CREDIT": "palazzol (ported from https://www.vertexshaderart.com/art/SZgEYFYSHKMqWSBCo)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 52720,
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
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1514250140672
    }
  }
}*/

void main()
{
  // vertex_percent is vertexId mapped to [0..1]
  float vertex_percent = vertexId / (vertexCount-1.0); // We use -1.0 to ensure a point exists at the end
  float x = vertex_percent*2.0 - 1.0; // Mapping vertex_percent [0..1] to X screen range, which is [-1..1]

  // sound texture has (amplitude, history) for (u,v).
  // u range is [0..1]: 0 is lowest bass, 1 is highest treble
  // v range is [0..1]: 0 is right now, 1 is 4 seconds in the past
  // It is all in the alpha channel of the sound texture

  // Set y position to amplitude in [0..1] range.
  // Y will be 1.0 at peak amplitude (top of screen) and 0.0 for silence (middle of screen)
  float y = texture(sound,vec2(vertex_percent,0.0)).r;

  float q = floor(sqrt(vertexCount));
  float x_percent = (mod(vertexId, q)) / q;
  float y_percent = (floor(vertexId / q)) / q;

  x = (x_percent*2.0 - 1.0)*0.5;
  y = -(y_percent*2.0 - 1.0)*0.5;

  x = x + x * 0.2*sin(vertex_percent*20.0+time*15.0);
  y = y + y * 0.2*cos(vertex_percent*30.0+time*15.0);

  gl_PointSize = 10.0; // Set point size in case want to render points instead of line, not used in line
  gl_Position = vec4(x,y,0,1); // simply plot onto screen space at z=0 with opacity=1, screen range is [-1..1] for both x and y
  v_color = vec4(1.0-x_percent, y_percent, x_percent, 1.0); // Just setting to the color white with opacity=1

}
