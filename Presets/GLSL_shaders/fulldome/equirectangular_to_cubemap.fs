/*{
    "DESCRIPTION": "Converts an equirectangular image to a cubemap atlas (strip or cross layout). Allows for applying rotations to each face.",
    "CREDIT": "Edu Meneses + AI Assistant (Gemini)",
    "CATEGORIES": [
        "UTILITY",
        "FORMAT-CONVERTER",
        "3D"
    ],
    "INPUTS": [
        { "NAME": "equirectangularImage", "TYPE": "image", "LABEL": "Equirectangular Image" },
        {
            "NAME": "layoutType",
            "LABEL": "Output Atlas Layout",
            "TYPE": "long",
            "VALUES": [0, 1, 2],
            "LABELS": ["Horizontal Strip (6w x 1h)", "Vertical Cross (3w x 4h)", "Horizontal Cross (4w x 3h)"],
            "DEFAULT": 0
        },
        { "NAME": "atlasRotFacePosX", "LABEL": "Apply Rotation to +X Face", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Apply Face Rotations" },
        { "NAME": "atlasRotFaceNegX", "LABEL": "Apply Rotation to -X Face", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Apply Face Rotations" },
        { "NAME": "atlasRotFacePosY", "LABEL": "Apply Rotation to +Y Face", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Apply Face Rotations" },
        { "NAME": "atlasRotFaceNegY", "LABEL": "Apply Rotation to -Y Face", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Apply Face Rotations" },
        { "NAME": "atlasRotFacePosZ", "LABEL": "Apply Rotation to +Z Face", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Apply Face Rotations" },
        { "NAME": "atlasRotFaceNegZ", "LABEL": "Apply Rotation to -Z Face", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Apply Face Rotations" }
    ]
}*/

// Constants for Cartesian to spherical conversion
const float PI = 3.141592653589793;
const float TWO_PI = 2.0 * PI;

// Helper function to rotate UV coordinates.
// This applies the desired rotation to the face.
// rotationType: 0=0deg, 1=90deg CW, 2=180deg, 3=270deg CW
vec2 rotateUV(vec2 uv, int rotationType) {
    vec2 centered_uv = uv - vec2(0.5);
    vec2 rotated_uv = centered_uv;

    if (rotationType == 1) {      // 90 deg CW
        rotated_uv.x = centered_uv.y;
        rotated_uv.y = -centered_uv.x;
    } else if (rotationType == 2) { // 180 deg
        rotated_uv.x = -centered_uv.x;
        rotated_uv.y = -centered_uv.y;
    } else if (rotationType == 3) { // 270 deg CW (90 CCW)
        rotated_uv.x = -centered_uv.y;
        rotated_uv.y = centered_uv.x;
    }
    // No rotation for rotationType == 0

    return rotated_uv + vec2(0.5);
}

void main() {
    // 1. Determine which face and the local UV on that face this fragment corresponds to.
    vec2 atlasUV = vv_FragNormCoord;

    float cell_w_norm, cell_h_norm;
    if (layoutType == 0) { // Horizontal Strip (6w x 1h)
        cell_w_norm = 1.0 / 6.0; cell_h_norm = 1.0;
    } else if (layoutType == 1) { // Vertical Cross (3w x 4h)
        cell_w_norm = 1.0 / 3.0; cell_h_norm = 1.0 / 4.0;
    } else { // Horizontal Cross (4w x 3h)
        cell_w_norm = 1.0 / 4.0; cell_h_norm = 1.0 / 3.0;
    }

    // Face IDs used internally: 0=+X, 1=-X, 2=+Y, 3=-Y, 4=+Z, 5=-Z
    int faceID = -1; // -1 means this fragment is in a blank area
    int rotationForFace = 0;
    vec2 local_face_uv = vec2(0.0);

    // This is the inverse of the 'getCellInfoForFace' function from the other shader.
    // It maps a coordinate in the atlas back to a specific face and its local UV.
    if (layoutType == 0) { // Horizontal Strip
        faceID = int(floor(atlasUV.x / cell_w_norm));
        local_face_uv.x = fract(atlasUV.x / cell_w_norm);
        local_face_uv.y = atlasUV.y;
    } else if (layoutType == 1) { // Vertical Cross
        vec2 grid_pos = floor(atlasUV / vec2(cell_w_norm, cell_h_norm));
        if (grid_pos.x == 2.0 && grid_pos.y == 2.0) faceID = 0; // +X
        else if (grid_pos.x == 0.0 && grid_pos.y == 2.0) faceID = 1; // -X
        else if (grid_pos.x == 1.0 && grid_pos.y == 3.0) faceID = 2; // +Y
        else if (grid_pos.x == 1.0 && grid_pos.y == 1.0) faceID = 3; // -Y
        else if (grid_pos.x == 1.0 && grid_pos.y == 2.0) faceID = 4; // +Z
        else if (grid_pos.x == 1.0 && grid_pos.y == 0.0) faceID = 5; // -Z

        if (faceID != -1) {
             local_face_uv.x = (atlasUV.x - grid_pos.x * cell_w_norm) / cell_w_norm;
             local_face_uv.y = (atlasUV.y - grid_pos.y * cell_h_norm) / cell_h_norm;
        }
    } else { // Horizontal Cross
        vec2 grid_pos = floor(atlasUV / vec2(cell_w_norm, cell_h_norm));
        if (grid_pos.x == 2.0 && grid_pos.y == 1.0) faceID = 0; // +X
        else if (grid_pos.x == 0.0 && grid_pos.y == 1.0) faceID = 1; // -X
        else if (grid_pos.x == 1.0 && grid_pos.y == 2.0) faceID = 2; // +Y
        else if (grid_pos.x == 1.0 && grid_pos.y == 0.0) faceID = 3; // -Y
        else if (grid_pos.x == 1.0 && grid_pos.y == 1.0) faceID = 4; // +Z
        else if (grid_pos.x == 3.0 && grid_pos.y == 1.0) faceID = 5; // -Z

         if (faceID != -1) {
             local_face_uv.x = (atlasUV.x - grid_pos.x * cell_w_norm) / cell_w_norm;
             local_face_uv.y = (atlasUV.y - grid_pos.y * cell_h_norm) / cell_h_norm;
        }
    }
    
    // If we're in a blank area of the atlas, just output transparency.
    if (faceID == -1) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    // Get the correct rotation setting for the identified face
    if (faceID == 0) rotationForFace = atlasRotFacePosX;
    else if (faceID == 1) rotationForFace = atlasRotFaceNegX;
    else if (faceID == 2) rotationForFace = atlasRotFacePosY;
    else if (faceID == 3) rotationForFace = atlasRotFaceNegY;
    else if (faceID == 4) rotationForFace = atlasRotFacePosZ;
    else if (faceID == 5) rotationForFace = atlasRotFaceNegZ;
    
    // --- FIX: The y-coordinate needs to be flipped to match the coordinate system
    // used in the conversion to a 3D vector.
    local_face_uv.y = 1.0 - local_face_uv.y;
    
    // 2. Apply the desired rotation to the local face UVs
    vec2 rotated_uv = rotateUV(local_face_uv, rotationForFace);

    // Map the 0-1 range UV to a -1 to +1 range coordinate on the cube face
    vec2 face_coords_neg1_1 = rotated_uv * 2.0 - 1.0;

    // 3. Convert the 2D face coordinate into a 3D direction vector
    vec3 dir;
    if (faceID == 0)      dir = normalize(vec3( 1.0, -face_coords_neg1_1.y, -face_coords_neg1_1.x)); // +X
    else if (faceID == 1) dir = normalize(vec3(-1.0, -face_coords_neg1_1.y,  face_coords_neg1_1.x)); // -X
    else if (faceID == 2) dir = normalize(vec3( face_coords_neg1_1.x,  1.0,  face_coords_neg1_1.y)); // +Y
    else if (faceID == 3) dir = normalize(vec3( face_coords_neg1_1.x, -1.0, -face_coords_neg1_1.y)); // -Y
    else if (faceID == 4) dir = normalize(vec3( face_coords_neg1_1.x, -face_coords_neg1_1.y,  1.0)); // +Z
    else                  dir = normalize(vec3(-face_coords_neg1_1.x, -face_coords_neg1_1.y, -1.0)); // -Z

    // 4. Convert the 3D direction vector to spherical coordinates (longitude, latitude)
    // which map directly to the UVs of the equirectangular image.
    float lon = atan(dir.x, dir.z); // atan2 equivalent
    float lat = asin(dir.y);

    vec2 equirectUV;
    equirectUV.x = lon / TWO_PI + 0.5;
    equirectUV.y = lat / PI + 0.5;

    // 5. Sample the input equirectangular image at the calculated UV
    gl_FragColor = IMG_NORM_PIXEL(equirectangularImage, equirectUV);
}