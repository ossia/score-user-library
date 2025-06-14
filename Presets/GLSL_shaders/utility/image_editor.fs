/*{
  "ISFVSN": "2.0",
  "DESCRIPTION": "Transforms an input image: scale, rotate (positive angle for CW image rotation), flip, and position.",
  "CREDIT": "Edu Meneses + AI Assistant (Gemini)",
  "CATEGORIES": [
    "Transform"
  ],
  "INPUTS": [
    {
      "NAME": "inputImage",
      "TYPE": "image"
    },
    {
      "NAME": "rotationAngle",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -360.0,
      "MAX": 360.0,
      "LABEL": "Rotation Angle (Degrees)"
    },
    {
      "NAME": "scaleFactor",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.01,
      "MAX": 10.0,
      "LABEL": "Scale Factor"
    },
    {
      "NAME": "flipHorizontal",
      "TYPE": "bool",
      "DEFAULT": false,
      "LABEL": "Flip Horizontal"
    },
    {
      "NAME": "flipVertical",
      "TYPE": "bool",
      "DEFAULT": false,
      "LABEL": "Flip Vertical"
    },
    {
	  "NAME" :"XYposition",
	  "TYPE" : "point2D",
	  "DEFAULT" : [0.0, 0.0],
	  "MAX" : [1.0, 1.0],
	  "MIN" : [-1.0, -1.0]
	}
  ]
}*/

void main() {
  vec2 uv = isf_FragNormCoord; // Texture coordinates from (0,0) bottom-left to (1,1) top-right
  vec2 center = vec2(0.5, 0.5);

  // 0. Translate to center for scale, rotation, and flip operations
  vec2 tex_coords = uv - center;

  // 1. Scale
  // Making scaleFactor smaller zooms out (image smaller), larger zooms in (image larger).
  // We divide texture coordinates by scaleFactor to achieve this visual effect.
  // Prevent division by zero or extremely small scales.
  float eff_scale = max(abs(scaleFactor), 0.01);
  if (scaleFactor < 0.0) { // Allow negative scale for mirroring as well, if desired, though flips are separate
      eff_scale *= -1.0;
  }
  tex_coords /= eff_scale;


  // 2. Rotation
  // Positive rotationAngle results in clockwise rotation of the image.
  // This is achieved by a counter-clockwise rotation of the texture coordinates.
  float angle_rad = radians(rotationAngle);
  float s_rot = sin(angle_rad);
  float c_rot = cos(angle_rad);

  // Counter-clockwise rotation matrix for coordinates:
  // | c  -s |   |x|   | x*c - y*s |
  // | s   c | * |y| = | x*s + y*c |
  // This is achieved by mat2(c_rot, s_rot, -s_rot, c_rot) applied as M * v;
  // where M = [[c_rot, -s_rot], [s_rot, c_rot]]
  // and GLSL mat2 constructor is mat2(col0_x, col0_y, col1_x, col1_y)
  // So, col0 = (c_rot, s_rot), col1 = (-s_rot, c_rot)
  mat2 rotation_matrix = mat2(c_rot, s_rot, -s_rot, c_rot);
  tex_coords = rotation_matrix * tex_coords;

  // 3. Flip
  if (flipHorizontal) {
    tex_coords.x = -tex_coords.x;
  }
  if (flipVertical) {
    tex_coords.y = -tex_coords.y;
  }

  // 4. Translate back from center
  tex_coords += center;

  // 5. Apply position offset
  // Positive positionX moves image right, positive positionY moves image up.
  // This means sampling texture coordinates to the left/down.
  tex_coords -= vec2(XYposition.x, XYposition.y);

  // Sample the input image
  vec4 outputColor = IMG_NORM_PIXEL(inputImage, tex_coords);
  gl_FragColor = outputColor;
}