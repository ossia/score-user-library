/*{
	"DESCRIPTION": "24 The Oak",
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
			"NAME": "scale",
			"TYPE": "float",
			"DEFAULT": 0.325,
			"MIN":0.00,
			"MAX":0.325
		}

	]
}*/

//24 The Oak - grows from a seed..

//dependencies

float stroke(float x, float s, float w){
	float d = step(s, x+w * 0.5) - step(s, x - w * 0.5);
	return clamp(d,0.0,1.0);
	}
	

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
	
	st = rotate(st, radians(orient));
	
	float r1 = rectSDF(st,vec2(1.0));
	float r2 = rectSDF(st+0.15,vec2(1.0));
	color += stroke(r1,0.5,0.05);
	color *= step(scale,r2);
	color += stroke(r2,scale,0.05) * fill(r1,0.525);
	color += stroke(r2,scale*.625,0.05);
	
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




