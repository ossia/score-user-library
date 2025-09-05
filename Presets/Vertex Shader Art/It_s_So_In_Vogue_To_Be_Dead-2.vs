/*{
  "DESCRIPTION": "It's So In Vogue To Be Dead - Bust a move.",
  "CREDIT": "daniel.shenkutie (ported from https://www.vertexshaderart.com/art/97zwxhJNAYAGKPST2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
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
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1605361294027
    }
  }
}*/

vec3 hsv2rgb(vec3 c)
{
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(){
  float down = floor(sqrt(vertexCount));

  float accros = down;
  float x = mod(vertexId,accros);
  float y = floor(vertexId/accros);
  float u = x/(accros -1.0);
  float v = y/(accros -1.0);

  float snd = texture(sound, vec2(u ,0)).r;

  float xoff = 0.0 ;//sin(time + y * 0.2) * 0.1;
    float yoff = 0.0;//sin(time + x * 0.2) * 0.1;

  float ux = 2.0*u -1.0 +xoff;
  //float vy = 2.0*v - 1.0 + yoff;

  vec2 xy = vec2(ux, 0);
  gl_Position = vec4(xy,0,1);

  float soff = 0.0;// sin(time + x * y * 0.02) * 5.0;
    gl_PointSize = snd * 30.0 + soff;
  gl_PointSize = 20.0;
   // gl_PointSize *= resolution.x/600.0;

  float mul = 10.* pow(snd, 5.0);

    float lum = float(mul * 10.0 + 1.9)/10.;

  float hue= lum * mul * 0.4;
  float sat = lum * 0.2;
  float val = lum;
  v_color=vec4(hsv2rgb(vec3(hue,sat,val)),1);

}