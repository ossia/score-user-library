/*{
  "DESCRIPTION": "Crosshatch FX",
  "CREDIT": "by IMIMOT (ported from https://github.com/BradLarson/GPUImage)",
  "CATEGORIES": [
    "Halftone Effect"
  ],
  "INPUTS": [
    {
      "NAME": "inputImage",
      "TYPE": "image"
    },
    {
      "NAME": "crossHatchSpacing",
      "TYPE": "float",
      "DEFAULT": 0.02,
      "MIN": 0.004,
      "MAX": 1
    },
    {
      "NAME": "crossHatchlineWidth",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.001,
      "MAX": 1
    }
  ]
}*/

const vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main()
{
	float lineWidth = crossHatchlineWidth*crossHatchSpacing;
	
	vec2 textureCoordinate = isf_FragNormCoord;
	
     float luminance = dot(IMG_THIS_PIXEL(inputImage).rgb, W);
     
     vec4 colorToDisplay = vec4(1.0, 1.0, 1.0, 1.0);
     if (luminance < 1.00)
     {
         if (mod(textureCoordinate.x + textureCoordinate.y, crossHatchSpacing) <= lineWidth)
         {
             colorToDisplay = vec4(0.0, 0.0, 0.0, 1.0);
         }
     }
     if (luminance < 0.75)
     {
         if (mod(textureCoordinate.x - textureCoordinate.y, crossHatchSpacing) <= lineWidth)
         {
             colorToDisplay = vec4(0.0, 0.0, 0.0, 1.0);
         }
     }
     if (luminance < 0.50)
     {
         if (mod(textureCoordinate.x + textureCoordinate.y - (crossHatchSpacing / 2.0), crossHatchSpacing) <= lineWidth)
         {
             colorToDisplay = vec4(0.0, 0.0, 0.0, 1.0);
         }
     }
     if (luminance < 0.3)
     {
         if (mod(textureCoordinate.x - textureCoordinate.y - (crossHatchSpacing / 2.0), crossHatchSpacing) <= lineWidth)
         {
             colorToDisplay = vec4(0.0, 0.0, 0.0, 1.0);
         }
     }
     
     gl_FragColor = colorToDisplay;
  
}
