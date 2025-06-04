/*{
    "DESCRIPTION": "Arranges six input cube face images into a selectable layout (Horizontal Strip, Vertical Cross, or Horizontal Cross). Each face can be individually rotated by 0, 90, 180, or 270 degrees clockwise. Defines standard cell mappings for each layout type. Empty cells in cross layouts are transparent black. Assumes input faces are standard 2D views.",
    "CREDIT": "Edu Meneses + AI Assistant (Gemini)",
    "CATEGORIES": [
        "UTILITY",
        "FORMAT-CONVERTER",
        "3D"
    ],
    "INPUTS": [
        { "NAME": "facePosX", "TYPE": "image", "LABEL": "Face +X (Right)" },
        { "NAME": "faceNegX", "TYPE": "image", "LABEL": "Face -X (Left)" },
        { "NAME": "facePosY", "TYPE": "image", "LABEL": "Face +Y (Top)" },
        { "NAME": "faceNegY", "TYPE": "image", "LABEL": "Face -Y (Bottom)" },
        { "NAME": "facePosZ", "TYPE": "image", "LABEL": "Face +Z (Front)" },
        { "NAME": "faceNegZ", "TYPE": "image", "LABEL": "Face -Z (Back)" },
        {
            "NAME": "layoutType",
            "LABEL": "Output Layout",
            "TYPE": "long",
            "VALUES": [0, 1, 2],
            "LABELS": ["Horizontal Strip (6w x 1h)", "Vertical Cross (3w x 4h)", "Horizontal Cross (4w x 3h)"],
            "DEFAULT": 0
        },
        { "NAME": "rotateFacePosX", "LABEL": "Rotate +X (Right)", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Face Rotations" },
        { "NAME": "rotateFaceNegX", "LABEL": "Rotate -X (Left)",  "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Face Rotations" },
        { "NAME": "rotateFacePosY", "LABEL": "Rotate +Y (Top)",   "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Face Rotations" },
        { "NAME": "rotateFaceNegY", "LABEL": "Rotate -Y (Bottom)","TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Face Rotations" },
        { "NAME": "rotateFacePosZ", "LABEL": "Rotate +Z (Front)", "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Face Rotations" },
        { "NAME": "rotateFaceNegZ", "LABEL": "Rotate -Z (Back)",  "TYPE": "long", "VALUES": [0,1,2,3], "LABELS": ["0 deg", "90 deg CW", "180 deg", "270 deg CW"], "DEFAULT": 0, "GROUP": "Face Rotations" }
    ]
}*/

// Helper function to rotate UV coordinates around their center (0.5, 0.5)
// rotationType: 0=0deg, 1=90deg CW, 2=180deg, 3=270deg CW
vec2 rotateUV(vec2 uv, int rotationType) {
    vec2 centered_uv = uv - vec2(0.5); // Center UV coordinates
    vec2 rotated_uv = centered_uv;

    if (rotationType == 1) { // 90 degrees clockwise: (x,y) -> (y,-x)
        rotated_uv.x = centered_uv.y;
        rotated_uv.y = -centered_uv.x;
    } else if (rotationType == 2) { // 180 degrees: (x,y) -> (-x,-y)
        rotated_uv.x = -centered_uv.x;
        rotated_uv.y = -centered_uv.y;
    } else if (rotationType == 3) { // 270 degrees clockwise (or 90 deg CCW): (x,y) -> (-y,x)
        rotated_uv.x = -centered_uv.y;
        rotated_uv.y = centered_uv.x;
    }
    // No rotation for rotationType == 0 or any other undefined values

    return rotated_uv + vec2(0.5); // Translate back to original UV space
}

void main() {
    // Normalized coordinates for the current fragment across the entire output texture [0,1]
    vec2 p_norm_output = vv_FragNormCoord;
    // Initialize to transparent black. This will be the color for empty cells
    // or if no face is explicitly mapped to the current fragment.
    vec4 out_color = vec4(0.0, 0.0, 0.0, 0.0);

    // Variables to define the grid cell structure based on layoutType
    float cell_width_norm;
    float cell_height_norm;
    // Column and row index of the cell the current fragment falls into
    int col_idx;
    int row_idx;
    // UV coordinates within a cell, before rotation [0,1]
    vec2 raw_local_uv;
    // UV coordinates after rotation, used for final texture sampling
    vec2 final_uv;

    // --- Determine layout, cell dimensions, and identify face for the current fragment ---

    if (layoutType == 0) { // Horizontal Strip (6 wide x 1 tall)
        cell_width_norm = 1.0 / 6.0;
        // cell_height_norm is effectively 1.0 for this layout.
        col_idx = int(floor(p_norm_output.x / cell_width_norm));
        // row_idx is conceptually 0 for a single-row layout.

        // Calculate UVs local to the current cell
        raw_local_uv.x = (p_norm_output.x - float(col_idx) * cell_width_norm) / cell_width_norm;
        raw_local_uv.y = p_norm_output.y; // Vertical UV takes the full height of the output

        // Assign face and rotation based on column index
        if (col_idx == 0) { final_uv = rotateUV(raw_local_uv, rotateFacePosX); out_color = IMG_NORM_PIXEL(facePosX, final_uv); }
        else if (col_idx == 1) { final_uv = rotateUV(raw_local_uv, rotateFaceNegX); out_color = IMG_NORM_PIXEL(faceNegX, final_uv); }
        else if (col_idx == 2) { final_uv = rotateUV(raw_local_uv, rotateFacePosY); out_color = IMG_NORM_PIXEL(facePosY, final_uv); }
        else if (col_idx == 3) { final_uv = rotateUV(raw_local_uv, rotateFaceNegY); out_color = IMG_NORM_PIXEL(faceNegY, final_uv); }
        else if (col_idx == 4) { final_uv = rotateUV(raw_local_uv, rotateFacePosZ); out_color = IMG_NORM_PIXEL(facePosZ, final_uv); }
        else if (col_idx == 5) { final_uv = rotateUV(raw_local_uv, rotateFaceNegZ); out_color = IMG_NORM_PIXEL(faceNegZ, final_uv); }
        // If col_idx is out of bounds (e.g., due to precision at edges), out_color remains transparent black.

    } else if (layoutType == 1) { // Vertical Cross (3 wide x 4 tall)
        // Layout Visualization (col,row from bottom-left 0,0):
        //      [+Y (1,3)]
        // [-X (0,2)]  [+Z (1,2)]  [+X (2,2)]
        //      [-Y (1,1)]
        //      [-Z (1,0)]
        cell_width_norm = 1.0 / 3.0;
        cell_height_norm = 1.0 / 4.0;
        col_idx = int(floor(p_norm_output.x / cell_width_norm));
        row_idx = int(floor(p_norm_output.y / cell_height_norm));

        // Calculate UVs local to the current cell
        raw_local_uv.x = (p_norm_output.x - float(col_idx) * cell_width_norm) / cell_width_norm;
        raw_local_uv.y = (p_norm_output.y - float(row_idx) * cell_height_norm) / cell_height_norm;

        // Assign face and rotation based on cell's (col_idx, row_idx)
        if (row_idx == 3 && col_idx == 1) { final_uv = rotateUV(raw_local_uv, rotateFacePosY); out_color = IMG_NORM_PIXEL(facePosY, final_uv); } // +Y
        else if (row_idx == 2) { // Middle row of the cross
            if (col_idx == 0) { final_uv = rotateUV(raw_local_uv, rotateFaceNegX); out_color = IMG_NORM_PIXEL(faceNegX, final_uv); }      // -X
            else if (col_idx == 1) { final_uv = rotateUV(raw_local_uv, rotateFacePosZ); out_color = IMG_NORM_PIXEL(facePosZ, final_uv); }  // +Z
            else if (col_idx == 2) { final_uv = rotateUV(raw_local_uv, rotateFacePosX); out_color = IMG_NORM_PIXEL(facePosX, final_uv); }  // +X
        }
        else if (row_idx == 1 && col_idx == 1) { final_uv = rotateUV(raw_local_uv, rotateFaceNegY); out_color = IMG_NORM_PIXEL(faceNegY, final_uv); } // -Y
        else if (row_idx == 0 && col_idx == 1) { final_uv = rotateUV(raw_local_uv, rotateFaceNegZ); out_color = IMG_NORM_PIXEL(faceNegZ, final_uv); } // -Z
        // Other cells (corners of the 3x4 grid) remain transparent black.

    } else if (layoutType == 2) { // Horizontal Cross (4 wide x 3 tall)
        // Layout Visualization (col,row from bottom-left 0,0):
        //           [+Y (1,2)]
        // [-X (0,1)]  [+Z (1,1)]  [+X (2,1)]  [-Z (3,1)]
        //           [-Y (1,0)]
        cell_width_norm = 1.0 / 4.0;
        cell_height_norm = 1.0 / 3.0;
        col_idx = int(floor(p_norm_output.x / cell_width_norm));
        row_idx = int(floor(p_norm_output.y / cell_height_norm));

        // Calculate UVs local to the current cell
        raw_local_uv.x = (p_norm_output.x - float(col_idx) * cell_width_norm) / cell_width_norm;
        raw_local_uv.y = (p_norm_output.y - float(row_idx) * cell_height_norm) / cell_height_norm;

        // Assign face and rotation based on cell's (col_idx, row_idx)
        if (row_idx == 2 && col_idx == 1) { final_uv = rotateUV(raw_local_uv, rotateFacePosY); out_color = IMG_NORM_PIXEL(facePosY, final_uv); } // +Y
        else if (row_idx == 1) { // Middle row of the cross
            if (col_idx == 0) { final_uv = rotateUV(raw_local_uv, rotateFaceNegX); out_color = IMG_NORM_PIXEL(faceNegX, final_uv); }      // -X
            else if (col_idx == 1) { final_uv = rotateUV(raw_local_uv, rotateFacePosZ); out_color = IMG_NORM_PIXEL(facePosZ, final_uv); }  // +Z
            else if (col_idx == 2) { final_uv = rotateUV(raw_local_uv, rotateFacePosX); out_color = IMG_NORM_PIXEL(facePosX, final_uv); }  // +X
            else if (col_idx == 3) { final_uv = rotateUV(raw_local_uv, rotateFaceNegZ); out_color = IMG_NORM_PIXEL(faceNegZ, final_uv); }  // -Z
        }
        else if (row_idx == 0 && col_idx == 1) { final_uv = rotateUV(raw_local_uv, rotateFaceNegY); out_color = IMG_NORM_PIXEL(faceNegY, final_uv); } // -Y
        // Other cells (corners of the 4x3 grid) remain transparent black.
    }

    // Final output color for the fragment
    gl_FragColor = out_color;
}
