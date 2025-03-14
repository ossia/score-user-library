/*{
    "CATEGORIES": [
        "General"
    ],
    "CREDIT": "Jean-Michaël Celerier",
    "DESCRIPTION": "Layer videos on top of each other. First texture is at the bottom.",
    "INPUTS": [
        { "NAME": "t1", "LABEL" : "Texture 1", "TYPE": "image" },
        { "NAME": "t2", "LABEL" : "Texture 2", "TYPE": "image" },
        { "NAME": "t3", "LABEL" : "Texture 3", "TYPE": "image" },
        { "NAME": "t4", "LABEL" : "Texture 4", "TYPE": "image" },
        { "NAME": "t5", "LABEL" : "Texture 5", "TYPE": "image" },
        { "NAME": "t6", "LABEL" : "Texture 6", "TYPE": "image" },
        { "NAME": "t7", "LABEL" : "Texture 7", "TYPE": "image" },
        { "NAME": "t8", "LABEL" : "Texture 8", "TYPE": "image" }
    ],
    "ISFVSN": "2"
}
*/


void main()	{
  vec4 p1 = IMG_THIS_NORM_PIXEL(t1);
  vec4 p2 = IMG_THIS_NORM_PIXEL(t2);
  vec4 p3 = IMG_THIS_NORM_PIXEL(t3);
  vec4 p4 = IMG_THIS_NORM_PIXEL(t4);
  vec4 p5 = IMG_THIS_NORM_PIXEL(t5);
  vec4 p6 = IMG_THIS_NORM_PIXEL(t6);
  vec4 p7 = IMG_THIS_NORM_PIXEL(t7);
  vec4 p8 = IMG_THIS_NORM_PIXEL(t8);
  
  vec3 rgb_mix = p8.rgb;
  float max_a = p8.a;

  rgb_mix = mix(p7.rgb, rgb_mix , max_a);
  max_a = max(p7.a, max_a);

  rgb_mix = mix(p6.rgb, rgb_mix, max_a);
  max_a = max(p6.a, max_a);
  
  rgb_mix = mix(p5.rgb, rgb_mix, max_a);
  max_a = max(p5.a, max_a);

  rgb_mix = mix(p4.rgb, rgb_mix, max_a);
  max_a = max(p4.a, max_a);
  
  rgb_mix = mix(p3.rgb, rgb_mix, max_a);
  max_a = max(p3.a, max_a);

  rgb_mix = mix(p2.rgb, rgb_mix, max_a);
  max_a = max(p2.a, max_a);
  
  gl_FragColor.rgb = mix(p1.rgb, rgb_mix, max_a);
  gl_FragColor.a = max(p1.a, max_a);
}