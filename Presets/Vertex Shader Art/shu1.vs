/*{
  "DESCRIPTION": "shu1",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/kTER7eQ7zASKMtkpo)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 2000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1485763057738
    }
  }
}*/

vec3 hsl2rgb(vec3 c) {
  c = vec3(fract(c.x), clamp(c.yz, 0.0, 1.0));
  vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
  return c.z + c.y * (rgb - 0.5) * (1.0 - abs(2.0 * c.z - 1.0));
}

// ---- start here ----

// original
// <body onload=setInterval("f()",t=16)><script>
//function f(){
// g=c.getContext('2d');
// for(t+=.1,i=300,h=150,c.height=i;i>0;--i){
// g.fillStyle='hsla('+360/(i%9)+t+',100%,50%,0.3)';
// g.fillRect(i,h,9,h*Math.sin(i/h+i%9*2+t))
// }
//}</script><canvas id=c>

void main() {
  // 2 points per line
  float lineId = floor(vertexId / 2.);
  float numLines = floor(vertexCount / 2.);
  float i = lineId / numLines * 3.;
  float odd = mod(vertexId, 2.);

  // g.fillStyle='hsla('+360/(i%9)+t+',100%,50%,0.3)';
  float h = mod(i, 300.) + time;
  float s = 1.;
  float l = .5;
  v_color.rgb = hsl2rgb(vec3(h,s,l));
  v_color.a = 0.3;
  v_color.rgb *= v_color.a;

  float lineOffset = floor(lineId / (numLines / 3.));
  gl_Position.x = fract(i + lineOffset * 0.331) * 2. - 1.;
  gl_Position.y = mix(0., sin(i + i * 5. + time * 10.), odd);
  gl_Position.z = 0.;
  gl_Position.w = 1.;
}