/*{
  "DESCRIPTION": "circles",
  "CREDIT": "andris (ported from https://www.vertexshaderart.com/art/Q9DLLK5ZfccWG9Shv)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 35646,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 11,
    "ORIGINAL_DATE": {
      "$date": 1583426478726
    }
  }
}*/

#define PI radians(180.)
#define P 180.
#define I 5.
#define L (P*I*I)
float expo(float t) { return t*(t*(4.*t - 6.) + 3.); }

vec2 circle(float eid, float start, float arclen, float N) {
    float angle = start + (mod(floor(eid/2.)+floor(mod(eid,2.)), N*2.)/N*2.*arclen);
   return vec2(cos(angle*PI*2.),sin(angle*PI*2.));
}

void main() {
 float lv = mod(vertexId,L), l = floor(vertexId/L),
   i = floor(lv / P), iv = mod(lv,P), e = mod(i,2.);
 vec2 pos = vec2( mod(i,I)-2.2, floor(i/I)-2. )*vec2(.4,.39), xy;
 if (l == 1.) {
  xy = pos+circle(iv,0.,1.,P) * (0.2 + e*0.04);
     v_color = vec4(vec3(.5)*floor(mod(iv,4.)/2.),1);
 } else if (l == 0.) {
     float a = mod((time + i*6.)*.2*(1.+e)+.3*e+.8,1.), s = mod(a,.25);
     a = expo(s/.25)*.25 + a - s;
     xy = pos+circle(iv,a,.25,P) * (.2 + e*.04);
     v_color = vec4(0.,0.2+clamp(e*cos(7.*a-.5),0.,1.) + clamp((1.-e)*sin(7.*a+0.25),0.,1.),0,.5);
   } else if (l <=3.) {
      float scale = (l-2.)*0.03;
      xy = pos+circle(mod(iv,P-1.),.75,0.5,P)*vec2(.03+scale,.03+scale*.6)+vec2(scale*-.4-.05,-0.09);
        v_color = vec4(1,1,1,1);
   } else if (l <= 5.) {
   // float lx = 0.;//(l-4.);
   // float part =floor(iv/P*2.);
   // xy = vec2(lx*0.03*-.4+.05,lx*-0.01-0.09) + pos+circle(P-iv+1.,mix(0.2,0.27,part),mix(0.53,0.46,part),P/2.)*vec2(1.,1.-part*2.)*0.05+vec2(0,part*-.1);
   // xy = pos+circle(mod(iv,P-1.),.75,0.5)*vec2(.03+scale,.03+scale*.6)+vec2(scale*-.4+.05,-0.09);
        v_color = vec4(1,1,1,1);
   }
 gl_Position = vec4(xy * vec2(1, resolution.x / resolution.y)*0.9, 0, 1);
}

