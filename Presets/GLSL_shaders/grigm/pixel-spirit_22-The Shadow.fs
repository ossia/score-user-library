/*{
	"DESCRIPTION": "22 The Shadow",
	"CREDIT": "Patricio Gonzalez Vivo ported by @colin_movecraft",
	"CATEGORIES": [
		"PIXELSPIRIT"
	],

	"INPUTS": [
	
		{
			"NAME": "orient",
			"TYPE": "float",
			"DEFAULT": 45.0,
			"MIN":0.0,
			"MAX":360.0
		},
			{
			"NAME": "offset",
			"TYPE": "float",
			"DEFAULT": 0.025,
			"MIN":0.00,
			"MAX":0.025
		},
		
		{
			"NAME": "inverse",
			"TYPE": "bool",
			"DEFAULT": 0.0
		}
		
	]
}*/

//22 The Shadow - The cross section of a shadow is a two-dimensional silhouette, or a reverse projection of the object blocking the light...

//dependencies

float fill(float x, float size){
	return 1.0 - step(size, x);
}

float rectSDF(vec2 st, vec2 s){
	st = st*2.0 -1.0;
	return max(abs(st.x/s.x),abs(st.y/s.y));	
	}
	
float flip(float v, float pct){
	return mix(v,1.0-v,pct);
	
	}

	
vec2 rotate(vec2 st, float a){
	st = mat2( cos(a) , -sin(a), sin(a), cos(a) ) * (st - 0.5);
	return st + 0.5;
}

float map(float n, float i1, float i2, float o1, float o2){
	return o1 + (o2-o1) * (n-i1)/(i2-i1);
	
}

float t = TIME;

void main(){
	vec3 color = vec3(0.0);
	vec2 st = isf_FragNormCoord;
	
	st = rotate(vec2(st.x,1.0-st.y), radians(orient));
	
	vec2 s = vec2(1.0);
	color += fill(rectSDF(st - offset,s), 0.4 );
	color += fill(rectSDF(st + offset,s), 0.4 );
	color *= step(0.38,rectSDF(st+offset,s));
	(inverse == true) ? color = 1.0-color  : color ;
    gl_FragColor = vec4(color,1.0);
}



/*
https://github.com/patriciogonzalezvivo/PixelSpiritDeck

 Copyright (c) 2017 Patricio Gonzalez Vivo ( http://www.pixelspiritdeck.com )
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
 
 Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

