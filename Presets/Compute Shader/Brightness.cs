/*{
  "DESCRIPTION": "Adjusts image brightness using compute shader",
  "CREDIT": "ossia score", 
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": ["COLOR"],
  "RESOURCES": [
    {
      "NAME": "inputImage",
      "TYPE": "IMAGE",
      "ACCESS": "read_only",
      "FORMAT": "RGBA8"
    },
    {
      "NAME": "outputImage",
      "TYPE": "IMAGE", 
      "ACCESS": "write_only",
      "FORMAT": "RGBA8",
      "WIDTH": "$WIDTH_inputImage",
      "HEIGHT": "$HEIGHT_inputImage"
    },
    {
      "NAME": "brightness",
      "TYPE": "float",
      "LABEL": "Brightness",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 2.0
    },
    {
      "NAME": "contrast", 
      "TYPE": "float",
      "LABEL": "Contrast",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 2.0
    },
    {
      "NAME": "applyEffect",
      "TYPE": "bool",
      "LABEL": "Apply Effect",
      "DEFAULT": true
    }
  ],
  "PASSES": [{
    "LOCAL_SIZE": [16, 16, 1],
    "EXECUTION_MODEL": { "TYPE": "2D_IMAGE", "TARGET": "outputImage" }
  }]
}*/

void main() {
    ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
    
    vec4 color = imageLoad(inputImage, coord);
    
    if (applyEffect) {
        // Apply brightness and contrast
        color.rgb = (color.rgb - 0.5) * contrast + 0.5;
        color.rgb *= brightness;
        color.rgb = clamp(color.rgb, 0.0, 1.0);
    }
    
    imageStore(outputImage, coord, color);
}
