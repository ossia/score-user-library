/*{
  "DESCRIPTION": "Chroma Key",
  "CREDIT": "by IMIMOT (ported from http://www.memo.tv/)",
  "CATEGORIES": [
    "Masking"
  ],
  "INPUTS": [
    {
      "NAME": "inputImage",
      "TYPE": "image"
    },
    {
      "NAME": "thresholdSensitivity",
      "TYPE": "float",
      "DEFAULT": 0.4,
      "MIN": 0,
      "MAX": 1
    },
    {
      "NAME": "smoothing",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0,
      "MAX": 1
    },
    {
      "NAME": "colorToReplace",
      "TYPE": "color",
      "DEFAULT": [
        0,
        1,
        0,
        1
      ]
    }
  ]
}*/

void main()
{
     
    vec4 textureColor = IMG_THIS_NORM_PIXEL(inputImage);
     
     float maskY = 0.2989 * colorToReplace.r + 0.5866 * colorToReplace.g + 0.1145 * colorToReplace.b;
     float maskCr = 0.7132 * (colorToReplace.r - maskY);
     float maskCb = 0.5647 * (colorToReplace.b - maskY);
     
     float Y = 0.2989 * textureColor.r + 0.5866 * textureColor.g + 0.1145 * textureColor.b;
     float Cr = 0.7132 * (textureColor.r - Y);
     float Cb = 0.5647 * (textureColor.b - Y);
     
     float blendValue = smoothstep(thresholdSensitivity, thresholdSensitivity + smoothing, distance(vec2(Cr, Cb), vec2(maskCr, maskCb)));
     vec4 blendImage = vec4(textureColor.rgb, textureColor.a * blendValue);
  
      // final mix needed to make alpha working
    gl_FragColor = mix(vec4(0.0),blendImage,blendImage.a);

}
