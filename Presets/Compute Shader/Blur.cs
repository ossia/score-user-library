/*{
  "NAME": "Gaussian Blur Compute",
  "VERSION": "1.0",
  "ISFVSN": "2",
  "MODE": "COMPUTE_SHADER",
  "DESCRIPTION": "Separable Gaussian blur using compute shader",
  "CREDIT": "ossia score",
  "CATEGORIES": ["BLUR", "IMAGE_EFFECT"],
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
      "NAME": "radius",
      "TYPE": "float",
      "LABEL": "Radius",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 50.0
    },
    {
      "NAME": "sigma",
      "TYPE": "float",
      "LABEL": "Sigma",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 1.0
    },
    {
      "NAME": "direction",
      "TYPE": "point2D",
      "LABEL": "Direction"
    }
  ],
  "PASSES": [{
    "LOCAL_SIZE": [16, 16, 1],
    "EXECUTION_MODEL": { "TYPE": "2D_IMAGE", "TARGET": "outputImage" }
  }]
}*/

/* automatically generated:
 * #version 450
 * 
 * layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;
 * 
 * layout(binding = 0) uniform BlurParams {
 *     int radius;
 *     vec2 direction;
 *     float sigma;
 * } params;
 * 
 * layout(binding = 1, rgba8) readonly image2D inputImage;
 * layout(binding = 2, rgba8) writeonly image2D outputImage;
*/ 

void main() {
    ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
    ivec2 size = imageSize(outputImage);
    
    if (coord.x >= size.x || coord.y >= size.y)
        return;

    vec4 color = vec4(0.0);
    float totalWeight = 0.0;
    
    for (float i = -radius; i <= radius; i++) {
        ivec2 sampleCoord = coord + ivec2( i * direction.x, i * direction.y );
        sampleCoord = clamp(sampleCoord, ivec2(0), size - 1);
        if(radius < -0.001 || radius > 0.001) 
        {
            float weight = exp(-float(i * i) / (2.0 * (sigma * sigma * radius)));
            color += imageLoad(inputImage, sampleCoord) * weight;
            totalWeight += weight;
        } 
        else 
        {
            color += imageLoad(inputImage, sampleCoord);
            totalWeight += 1.0;
        }
    }
    
    imageStore(outputImage, coord, color / totalWeight);
}
