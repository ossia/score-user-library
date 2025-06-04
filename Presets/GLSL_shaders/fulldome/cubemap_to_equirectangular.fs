/*{
    "DESCRIPTION": "Converts a cubemap atlas (strip or cross layout) to an equirectangular image. Requires knowing the layout and any rotations applied to faces in the atlas.",
    "CREDIT": "Edu Meneses + AI Assistant (Gemini)",
    "CATEGORIES": [
        "UTILITY",
        "FORMAT-CONVERTER",
        "3D"
    ],
    "INPUTS": [
        { "NAME": "cubemapAtlas", "TYPE": "image", "LABEL": "Cubemap Atlas Texture" },
        {
            "NAME": "layoutType",
            "LABEL": "Input Atlas Layout",
            "TYPE": "long",
            "VALUES": [0, 1, 2],
            "LABELS": ["Horizontal Strip (6w x 1h)", "Vertical Cross (3w x 4h)", "Horizontal Cross (4w x 3h)"],
            "DEFAULT": 0
        },
        { "NAME": "atlasRotFacePosX", "LABEL": "Atlas +X Original Rotation", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Atlas Face Original Rotations" },
        { "NAME": "atlasRotFaceNegX", "LABEL": "Atlas -X Original Rotation", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Atlas Face Original Rotations" },
        { "NAME": "atlasRotFacePosY", "LABEL": "Atlas +Y Original Rotation", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Atlas Face Original Rotations" },
        { "NAME": "atlasRotFaceNegY", "LABEL": "Atlas -Y Original Rotation", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Atlas Face Original Rotations" },
        { "NAME": "atlasRotFacePosZ", "LABEL": "Atlas +Z Original Rotation", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Atlas Face Original Rotations" },
        { "NAME": "atlasRotFaceNegZ", "LABEL": "Atlas -Z Original Rotation", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Atlas Face Original Rotations" }
    ]
}*/

// Constants for spherical to Cartesian conversion
const float PI = 3.141592653589793;
const float TWO_PI = 2.0 * PI;

// Helper function to "un-rotate" UV coordinates.
// This applies the inverse of the rotation originally applied to the face.
// originalRotationType: 0=0deg, 1=90deg CW, 2=180deg, 3=270deg CW (as in the first shader)
vec2 unrotateUV(vec2 uv, int originalRotationType) {
    vec2 centered_uv = uv - vec2(0.5); // Center UV coordinates
    vec2 unrotated_uv = centered_uv;

    if (originalRotationType == 1) {      // Original was 90 CW, so unrotate by 270 CW (or 90 CCW)
        unrotated_uv.x = -centered_uv.y;
        unrotated_uv.y = centered_uv.x;
    } else if (originalRotationType == 2) { // Original was 180, so unrotate by 180
        unrotated_uv.x = -centered_uv.x;
        unrotated_uv.y = -centered_uv.y;
    } else if (originalRotationType == 3) { // Original was 270 CW, so unrotate by 90 CW
        unrotated_uv.x = centered_uv.y;
        unrotated_uv.y = -centered_uv.x;
    }
    // No unrotation for originalRotationType == 0

    return unrotated_uv + vec2(0.5); // Translate back
}

// Helper to get atlas cell info: vec4(normalized_offsetX, normalized_offsetY, normalized_cellWidth, normalized_cellHeight)
// This defines where each face is located within the input cubemapAtlas.
// Face IDs used internally: 0=+X, 1=-X, 2=+Y, 3=-Y, 4=+Z, 5=-Z
vec4 getCellInfoForFace(int faceID, int atlasLayoutType, float cellW_norm, float cellH_norm) {
    if (atlasLayoutType == 0) { // Horizontal Strip (6w x 1h)
        if (faceID == 0) return vec4(0.0 * cellW_norm, 0.0, cellW_norm, cellH_norm); // +X
        if (faceID == 1) return vec4(1.0 * cellW_norm, 0.0, cellW_norm, cellH_norm); // -X
        if (faceID == 2) return vec4(2.0 * cellW_norm, 0.0, cellW_norm, cellH_norm); // +Y
        if (faceID == 3) return vec4(3.0 * cellW_norm, 0.0, cellW_norm, cellH_norm); // -Y
        if (faceID == 4) return vec4(4.0 * cellW_norm, 0.0, cellW_norm, cellH_norm); // +Z
        if (faceID == 5) return vec4(5.0 * cellW_norm, 0.0, cellW_norm, cellH_norm); // -Z
    } else if (atlasLayoutType == 1) { // Vertical Cross (3w x 4h)
        if (faceID == 0) return vec4(2.0 * cellW_norm, 2.0 * cellH_norm, cellW_norm, cellH_norm); // +X
        if (faceID == 1) return vec4(0.0 * cellW_norm, 2.0 * cellH_norm, cellW_norm, cellH_norm); // -X
        if (faceID == 2) return vec4(1.0 * cellW_norm, 3.0 * cellH_norm, cellW_norm, cellH_norm); // +Y
        if (faceID == 3) return vec4(1.0 * cellW_norm, 1.0 * cellH_norm, cellW_norm, cellH_norm); // -Y
        if (faceID == 4) return vec4(1.0 * cellW_norm, 2.0 * cellH_norm, cellW_norm, cellH_norm); // +Z
        if (faceID == 5) return vec4(1.0 * cellW_norm, 0.0 * cellH_norm, cellW_norm, cellH_norm); // -Z
    } else if (atlasLayoutType == 2) { // Horizontal Cross (4w x 3h)
        if (faceID == 0) return vec4(2.0 * cellW_norm, 1.0 * cellH_norm, cellW_norm, cellH_norm); // +X
        if (faceID == 1) return vec4(0.0 * cellW_norm, 1.0 * cellH_norm, cellW_norm, cellH_norm); // -X
        if (faceID == 2) return vec4(1.0 * cellW_norm, 2.0 * cellH_norm, cellW_norm, cellH_norm); // +Y
        if (faceID == 3) return vec4(1.0 * cellW_norm, 0.0 * cellH_norm, cellW_norm, cellH_norm); // -Y
        if (faceID == 4) return vec4(1.0 * cellW_norm, 1.0 * cellH_norm, cellW_norm, cellH_norm); // +Z
        if (faceID == 5) return vec4(3.0 * cellW_norm, 1.0 * cellH_norm, cellW_norm, cellH_norm); // -Z
    }
    return vec4(0.0, 0.0, 0.0, 0.0); // Should not be reached
}

void main() {
    vec2 equirectUV = vv_FragNormCoord;
    float lon = (equirectUV.x - 0.5) * TWO_PI;
    float lat = (equirectUV.y - 0.5) * PI;

    vec3 dir;
    dir.y = sin(lat);
    float cosLat = cos(lat);
    dir.x = cosLat * sin(lon);
    dir.z = cosLat * cos(lon);

    vec3 absDir = abs(dir);
    vec2 faceUV_coords_neg1_1;
    int faceID = 0;
    int rotationForFace = 0;

    if (absDir.z >= absDir.x && absDir.z >= absDir.y) {
        if (dir.z > 0.0) {
            faceID = 4; rotationForFace = atlasRotFacePosZ;
            faceUV_coords_neg1_1 = vec2(dir.x, -dir.y) / abs(dir.z);
        } else {
            faceID = 5; rotationForFace = atlasRotFaceNegZ;
            faceUV_coords_neg1_1 = vec2(-dir.x, -dir.y) / abs(dir.z);
        }
    } else if (absDir.x >= absDir.y) {
        if (dir.x > 0.0) {
            faceID = 0; rotationForFace = atlasRotFacePosX;
            faceUV_coords_neg1_1 = vec2(-dir.z, -dir.y) / abs(dir.x);
        } else {
            faceID = 1; rotationForFace = atlasRotFaceNegX;
            faceUV_coords_neg1_1 = vec2(dir.z, -dir.y) / abs(dir.x);
        }
    } else {
        if (dir.y > 0.0) {
            faceID = 2; rotationForFace = atlasRotFacePosY;
            faceUV_coords_neg1_1 = vec2(dir.x, dir.z) / abs(dir.y);
        } else {
            faceID = 3; rotationForFace = atlasRotFaceNegY;
            faceUV_coords_neg1_1 = vec2(dir.x, -dir.z) / abs(dir.y);
        }
    }

    vec2 raw_face_uv = (faceUV_coords_neg1_1 + 1.0) * 0.5;
    vec2 final_sampling_uv_on_face = unrotateUV(raw_face_uv, rotationForFace);

    // --- FIX: If all faces appear vertically flipped, flip the V coordinate here. ---
    final_sampling_uv_on_face.y = 1.0 - final_sampling_uv_on_face.y;
    // --- END FIX ---

    float cell_w_norm, cell_h_norm;
    if (layoutType == 0) {
        cell_w_norm = 1.0 / 6.0; cell_h_norm = 1.0;
    } else if (layoutType == 1) {
        cell_w_norm = 1.0 / 3.0; cell_h_norm = 1.0 / 4.0;
    } else {
        cell_w_norm = 1.0 / 4.0; cell_h_norm = 1.0 / 3.0;
    }

    vec4 cellMetrics = getCellInfoForFace(faceID, layoutType, cell_w_norm, cell_h_norm);
    float cellOriginX = cellMetrics.x;
    float cellOriginY = cellMetrics.y;
    float actualCellW = cellMetrics.z;
    float actualCellH = cellMetrics.w;

    vec2 atlas_uv_to_sample;
    atlas_uv_to_sample.x = cellOriginX + final_sampling_uv_on_face.x * actualCellW;
    atlas_uv_to_sample.y = cellOriginY + final_sampling_uv_on_face.y * actualCellH;

    // For the debug check, it might be more intuitive to check the raw_face_uv or the
    // final_sampling_uv_on_face *before* the flip, to ensure the unrotation is correct.
    // Let's check raw_face_uv as it's simpler.
    vec2 uv_to_check_bounds = raw_face_uv; // Or final_sampling_uv_on_face *before* flip
                                            // If checking final_sampling_uv_on_face, do it before the flip line.

    if (uv_to_check_bounds.x < -0.001 || uv_to_check_bounds.x > 1.001 ||
        uv_to_check_bounds.y < -0.001 || uv_to_check_bounds.y > 1.001) {
        gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0); // Magenta for debug
    } else {
       gl_FragColor = IMG_NORM_PIXEL(cubemapAtlas, atlas_uv_to_sample);
    }
}