/*{
	"DESCRIPTION": "17 The Diamond",
	"CREDIT": "Patricio Gonzalez Vivo ported by @colin_movecraft",
	"CATEGORIES": [
		"PIXELSPIRIT"
	],

	"INPUTS": [
	
		{
			"NAME": "shimmer",
			"TYPE": "float",
			"DEFAULT": 0.25,
			"MIN":0.0,
			"MAX":1.0
		},
		
			
		{
			"NAME": "count",
			"TYPE": "float",
			"DEFAULT": 4.0,
			"MIN":0.0,
			"MAX":20.0
		}

	]
}*/

//17 The Diamond. Shimmers...

//dependencies


float stroke(float x, float s, float w){
	float d = step(s, x+w * 0.5) - step(s, x - w * 0.5);
	return clamp(d,0.0,1.0);
}

float fill(float x, float size){
	return 1.0 - step(size, x);
}

float triSDF(vec2 st){
	st = (st * 2.0 - 1.0 ) * 2.0;
	return max(abs(st.x) * 0.866025 + st.y * 0.5 , - st.y * 0.5);
	
}

float rhombSDF(vec2 st){
	return max(triSDF(st),triSDF(vec2(st.x, 1.0-st.y)));
}


float map(float n, float i1, float i2, float o1, float o2){
	return o1 + (o2-o1) * (n-i1)/(i2-i1);
	
}

float t = TIME;

void main(){
	vec3 color = vec3(0.0);
	vec2 st = gl_FragCoord.xy/RENDERSIZE;
	
	float sdf = rhombSDF(st);
	

	color += fill(sdf, .425);
	for (int i = 0; i<int(count);i++){
		float i_float = float(i);	
		float expand = map ( (mod(t*shimmer + (i_float *.25) ,1.0)), 0.0, 1.0, 0.3, 0.8);
		float shrink = map ( (mod(t*shimmer + (i_float *.25) ,1.0)), 0.0, 1.0, 0.1, 0.0);
		color += stroke(sdf, expand, shrink);
	}

	
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



