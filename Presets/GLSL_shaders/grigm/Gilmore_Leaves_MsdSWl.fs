/*
{
  "IMPORTED" : [

  ],
  "CATEGORIES" : [
    "circles",
    "grid",
    "tiles",
    "Automatically Converted"
  ],
  "DESCRIPTION" : "Automatically converted from https:\/\/www.shadertoy.com\/view\/MsdSWl by airtight.  Some nice shapes. good at fullscreen.",
  "INPUTS" : [

  ]
}
*/


const float PI = 3.1415926535;
const float flipTime  = 2.;

float circEdge  =  20.0 / RENDERSIZE.x;
vec2 tileDims = vec2(3.0,3.0); //number of rows ,columns

float random (vec2 st) { 
    return fract(sin(dot(st.xy, vec2(12.9898,78.233)))* 43758.5453123);
}

float randomRange (in vec2 seed, in float min, in float max) {
		return min + random(seed) * (max - min);
}

vec2 rotate2D(vec2 position, float theta)
{
    mat2 m = mat2( cos(theta), -sin(theta), sin(theta), cos(theta) );
    return m * position;
}

vec3 hsv2rgb(vec3 c){
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

//returns 1 for inside circ, 0 for outside
float circle(in vec2 _st, in vec2 pos, in float _radius){
    vec2 dist = _st - pos;    
	return 1. - smoothstep(_radius-(_radius*circEdge),
                         _radius+(_radius*circEdge),
                         dot(dist,dist)*4.0);
}

vec3 gilmoreCol(float x){    
    //offset hue to put red in middle
    float hue = fract((1.0 - x) - 0.45);    
    //saturation is higher for warmer colors
    float sat = 0.3 + sin(x*PI)*0.5;    
    //brightness higher in middle
    float bri = (smoothstep(0.,0.6, x) - smoothstep(0.6,1.0,x))*.6 + 0.3;  
    return vec3(hue, sat,bri);    
}

void main()
{
	
     //0-1 on both axes
    vec2 uv = gl_FragCoord.xy / RENDERSIZE.xy;
    
    //square aspect ratio, centered
    vec2 uvs = vec2( gl_FragCoord.xy - 0.5*RENDERSIZE.xy ) / min(RENDERSIZE.x,RENDERSIZE.y);
    
    //switch tileDims every 2 seconds
    float rndTime = randomRange(vec2(floor(TIME/flipTime), 79834.345),3.,16.);
    //number of rows ,columns
    tileDims = vec2(floor(rndTime),floor(rndTime));
    
    //rotate
    uvs = rotate2D(uvs,cos(TIME/10.));
    
    //warp
    //uvs.x = uvs.x + sin(uvs.x*4.+TIME*6.)*0.005;
    
    //zoomer
    //uvs *= (cos(TIME/2.) *0.2 + 1.);
    
    //slide columns down separately
    //tile H coord 
    float colId = floor(uvs.x * tileDims.x);   
    //rand per column
    float rndColumn = random(vec2(colId, 687.890));
    uvs.y += TIME * (rndColumn ) /30.;
    
    //bounce
    //uvs.y += cos(TIME*PI * rndColumn)/10.;
    
	//rnd per tile   
    float rnd = random(floor(uvs.xy * tileDims) +  floor(TIME/flipTime));
    
    //mostly green w/ some reds
    vec3 tileHSV;
    if(rnd < 0.9){        
       tileHSV = gilmoreCol(rnd/2.6);       
    }else{
        tileHSV = gilmoreCol(rnd - 0.4);      
    }
             
    //get random int 0 - 3 per tile
    float tileRnd = random(floor(uvs.xy * tileDims ) * 88.89 );
    tileRnd = floor(tileRnd * 4.);
    
    //st is 0-1 coords within tile 
    vec2 st = fract(uvs * tileDims);
    
    //flip tiles
    if (tileRnd == 1.) {
    	st.y = 1.0 - st.y;    
    }else if (tileRnd == 2.) {
       st.x = 1.0 - st.x;       
    } else if (tileRnd == 3.) {        
        st.x = 1.0 - st.x;    
        st.y = 1.0 - st.y;    
    }
    
    //draw circles
    float circ = circle(st,vec2(0),4.);
	tileHSV.z *= circ;
  
    //column shadows
    float hShadow = smoothstep(0.4, 0., fract(-uvs.x*tileDims.x)) * 0.12;
   	tileHSV.z -= hShadow;
    
    //slight vertical hue shift
    float vShift = smoothstep(0.9, 0., st.y) * 0.03;
   	tileHSV.x -= vShift;
    
    //screen vertical brightness gradient
    tileHSV.z -= fract( 1.0 - uv.y  ) * 0.3;
    
    gl_FragColor = vec4(hsv2rgb(tileHSV),1.0);
    
}