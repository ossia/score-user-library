/*
{
  "CATEGORIES" : ["Generator"],
  "ISFVSN": "2",
  "DESCRIPTION" : "Audio Bars",
  "INPUTS" : [

    {
	"NAME" : "gain",
	"LABEL" : "Gain",
     "TYPE" : "float",
     "MAX" : 2,
     "DEFAULT" : 0.8,
     "MIN" : 0.1
    },
    {
      "NAME" : "decay",
      "LABEL" : "Time Smooth",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 0.2,
      "MIN" : 0
    },
    {
	"NAME" : "ypos",
	"LABEL" : "Y Position",
	"TYPE" : "float",
	"MAX" : 0.5,
	"DEFAULT" : 0,
	"MIN" : -0.5
	},
    {
    "NAME" : "vsize",
    "LABEL" : "Height",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 0.5,
      "MIN" : 0.1
    },
    {
    "NAME" : "hsize",
    "LABEL" : "Width",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 1,
      "MIN" : 0.1
    },
    {
    "NAME" : "percpective",
    "LABEL" : "Percpective",
     "TYPE" : "float",
     "MAX" : 1,
     "DEFAULT" : -0.25,
     "MIN" : -3
    },
    {
    "NAME" : "Vmirror",
    "LABEL" : "Vert Mirror",
    "DEFAULT": 1.0,
    "TYPE" : "bool"
    },
    {
    "NAME" : "Hmirror",
    "LABEL" : "Hoz Mirror",
    "DEFAULT": 1.0,
    "TYPE" : "bool"
    },
    {
    "NAME" : "segH",
    "LABEL" : "Hoz Segments",
      "TYPE" : "float",
      "MAX" : 128,
      "DEFAULT" : 32,
      "MIN" : 4
    },
    {
    "NAME" : "segV",
    "LABEL" : "Vert Segments",
      "TYPE" : "float",
      "MAX" : 32,
      "DEFAULT" : 16,
      "MIN" : 4
    },
    {
      "NAME" : "colin",
      "LABEL" : "Color",
      "TYPE" : "color",
      "DEFAULT" : [0,1,0,1]
    },
    {
      "NAME" : "hue",
      "LABEL" : "Hue Shift",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 0.55,
      "MIN" : 0
    },
    {
      "NAME" : "minRange",
      "LABEL" : "Freak MIN",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 0,
      "MIN" : 0
    },
    {
      "NAME" : "maxRange",
      "LABEL" : "Freak MAX",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 0.42,
      "MIN" : 0
    }
  ],
  "PASSES" : [
    {
      "TARGET" : "feedbackBuffer",
      "PERSISTENT" : true
    },
    {
    "DESCRIPTION": "empty pass`"
    }
  ],
  "CREDIT" : "howie.tv"
}
*/
// handmade by howie,tv
// inspiration and much remixed code from VIDVOX
// copied right 2019

/*
  -  TO MKAE IT AUDIO RESPONSIVE ( NOT SUPPORTED ONLINE )
  -  ADD THE "fftImage" ENTRY BELOW TO THE TOP OF JSON  ( @line7 )
  -  DELTE THE " rand " FUNCTION
  -  UPDATE THE COMMENTED LINE ( @ line 175 ) 
  -  enJOY
  
  {
	"NAME" : "fftImage",
	"TYPE" : "audioFFT"
  },


*/


// YOU CAN  DELETE THIS
float rand(float n){return fract(sin(n) * 43758.5453123);}
//

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float box (vec2 uv) {
	uv -= 0.5;
	return smoothstep(0.5,0.3,abs(uv.x)) - smoothstep(0.3,0.5,abs(uv.y));
}

void main() {
  if (PASSINDEX == 0)	{

    vec2		loc = isf_FragNormCoord;

    /// DELETE THE LINE BELOW AND UN COMMENT THE FLLOWING LINE
    vec4		inputPixelColor = vec4(rand(TIME+isf_FragNormCoord.x));
    // vec4		inputPixelColor = IMG_NORM_PIXEL(fftImage,loc);

  	vec4		feedbackPixelColor = vec4(0.0);


  	if ((loc.x < 0.0)||(loc.y < 0.0)||(loc.x > 1.0)||(loc.y > 1.0))	{ feedbackPixelColor = vec4(0.0);
  	} else	{ feedbackPixelColor = IMG_NORM_PIXEL(feedbackBuffer,loc); }
    inputPixelColor = inputPixelColor + decay * feedbackPixelColor;
  	gl_FragColor = inputPixelColor;

	} else	{

  	float divX = ceil(segH)*2.0;
	float divY = ceil(segV)*2.0;

	vec2 uv = vec2(isf_FragNormCoord.x -0.5, isf_FragNormCoord.y -0.5);
  uv.x = clamp(uv.x* (1.0-((uv.y+0.5)*percpective)) ,-0.5,0.5);

  if (Vmirror) {
      uv.y = clamp(uv.y -ypos, -1.0, 1.0);
    } else {
      uv.y = clamp(uv.y -ypos, 0.0, 1.0);
    }
  uv.y /= vsize;
  float iY = abs(floor(uv.y*divY));

  uv.x = clamp((uv.x/hsize), -0.5, 0.5);
  float iX;
  if (Hmirror) {
      iX = ceil( abs(uv.x*divX))*2.0;
    } else {
      iX = floor((uv.x+0.5)*divX);
    }
	uv = vec2 (fract(uv.x*divX), fract(uv.y*divY));

	vec3 hsv = rgb2hsv(colin.rgb);
	vec3 col = hsv2rgb(vec3 (hsv.x +(hue*(1.0/divY)*iY), hsv.y, hsv.z ));

  float x = ((1.0 * abs(maxRange - minRange) + minRange)/divX) *iX;
	vec4 fft = IMG_NORM_PIXEL(feedbackBuffer, vec2(x,0.5));

  float fftVal = clamp(pow(gain, 1.5) * fft.r, 0.001, 1.0);
  vec3 grid = vec3(box (uv)) *col *float(fftVal*divY > iY);

	gl_FragColor = vec4(grid,1.);
  }
}
