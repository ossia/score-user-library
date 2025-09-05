/*{
  "DESCRIPTION": "It's So In Vogue To Be Dead - Bust a move.",
  "CREDIT": "daniel.shenkutie (ported from https://www.vertexshaderart.com/art/GDrWuySq3yExsoNqR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.08235294117647059,
    0.0784313725490196,
    0.0784313725490196,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1605319186466
    }
  }
}*/



void main(){
  float down = floor(sqrt(vertexCount));

  float accros =floor(vertexCount/ down);
  float x = mod(vertexId,accros);
  float y = floor(vertexId/accros);
  float u = x/(accros -1.0);
  float v = y/(accros -1.0);

  float ux = 2.0*u -1.0;
  float vy = 2.0*v - 1.0;

  gl_Position = vec4(ux,vy,0,1);
    gl_PointSize = 10.0;
  gl_PointSize *= 20./ accros;
  v_color=vec4(1,1,1,1);

}