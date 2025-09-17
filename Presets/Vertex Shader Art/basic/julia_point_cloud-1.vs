/*{
  "DESCRIPTION": "julia point cloud",
  "CREDIT": "kabuto (ported from https://www.vertexshaderart.com/art/uZ4ELyQ7j8J8X5xJg)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Nature"
  ],
  "POINT_COUNT": 56478,
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
    "ORIGINAL_VIEWS": 960,
    "ORIGINAL_LIKES": 6,
    "ORIGINAL_DATE": {
      "$date": 1446637718221
    }
  }
}*/

#define MAXITER 1000

void main() {
  // more or less random start position
  vec2 v = vec2(cos(vertexId*23.), cos(vertexId*545.))*3.;

  // collect ljapunov exponent (derivative) for colouring
  float dv = 0.;

  float rnd = vertexId;

  // Follow a path just along the edge of the mandelbrot set's 2 biggest blobs
  const float PI = 3.141592653589;
  float t = fract(time*.06)*2.-1.;
  t = pow(abs(t),0.7)*sign(t);
  t = fract(t*.5+.6);
  t = t*2.5*PI-0.5*PI;
  vec2 ofs = t < 0.
    ? vec2(-1,0)+vec2(cos(t*4.),sin(t*4.))*.25
    : vec2(.25,0)-vec2(cos(t),-sin(t))*(1.+cos(t))*.5;

  //
  vec2 norm = t < 0.
    ? vec2(cos(t*4.),sin(t*4.))*sin(-t*2.)
    : -vec2(cos(t*1.5),-sin(t*1.5))*sin(t);
  ofs += norm*(sin(time*.3)+sin(time*.33413)+cos(time*.335)+cos(time*.4534)+1.)*.2;

  for (int i = 0; i < MAXITER; i++) {
    // random number update
    rnd = sin(rnd*1337.+vertexId*.2+sin(time)+float(i));

    // inverse julia iteration step - subtract offset, then extract square root
 v -= ofs;
   v = vec2(sqrt((length(v) + v.x)*.5), sign(v.y)*sqrt((length(v) - v.x)*.5));

    // The complex square root is ambiguous, so both the value just computed and its inverse are valid.
    // The most simple approach of just randomly picking a point does not work so well -
    // it tends to collect points in certain spots (mostly tips of the fractal) while neglecting coves.
    // Mathematically speaking, coves appear because the square root of near-zero values is computed
    // and the square root tends to make a big difference around such values.
    // At the same time point density is decreased too...
    // To combat this we look ahead to the next step and prefer values that are closer to zero.
    // This doesn't fix everything - for that we would have to look ahead further,
    //but complexity would increase too much. So it might not really be feasible for this approach.
    v *= sign(rnd-(length(v-ofs)-length(-v-ofs))*vertexId/vertexCount*1.3*(1.-exp((float(i-1)-float(MAXITER))*.5)));

    dv += log(length(v))+.2;
  }

   vec2 aspect = vec2(1, resolution.x / resolution.y);
  gl_Position = vec4(v*aspect*.5, 1.-vertexId*.00001, 1);

  gl_PointSize = min(3.,sqrt(max(1.,-dv*.1)));
  v_color = vec4(dv,dv*.005+1.,1,1)*.3/gl_PointSize;
}