/*{
  "DESCRIPTION": "Bubble Universe",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/CtXSFrywWri4egF7m)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 54,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1699048585647
    }
  }
}*/

// Bubble Universe GLSL implementation
// Original is here: https://stardot.org.uk/forums/viewtopic.php?t=25833

void main() {

  const int n=500;
  const float r=6.283185307179586/235.;
 float x=0., y=0., u=0.,v=0., t=0., sz=200.;
  int i = int(vertexId)/n;
  float fj = 0.;
    for (int j = 0; j < n; j++) {
    u=sin(float(i)+v)+sin(r*float(i)+x);
    v=cos(float(i)+v)+cos(r*float(i)+x);
    x=u+time*.01;
      fj = float(j);
      if (j+i*n == int(vertexId)) {
        break;
      }
  }
      v_color = vec4(vertexId/vertexCount, fj/float(n),0.4,1.);
        gl_PointSize = 1.3;
      gl_Position = vec4(u*.5*min(1.,resolution.y/resolution.x),v*.5*min(1.,resolution.x/resolution.y),0,1);
}