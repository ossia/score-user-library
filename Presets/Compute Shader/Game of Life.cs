/*{
  "NAME": "Game of Life Compute",
  "VERSION": "1.0",
  "ISFVSN": "2",
  "MODE": "COMPUTE_SHADER",
  "DESCRIPTION": "Conway's Game of Life and variants using compute shader",
  "CREDIT": "ossia score",
  "CATEGORIES": ["GENERATOR", "SIMULATION", "CELLULAR_AUTOMATON"],
  "RESOURCES": [
    {
      "NAME": "outputImage",
      "TYPE": "IMAGE",
      "ACCESS": "write_only",
      "FORMAT": "RGBA8",
      "WIDTH": 1024,
      "HEIGHT": 1024
    },
    {
      "NAME": "algorithm",
      "TYPE": "long",
      "LABEL": "Algorithm",
      "DEFAULT": 0,
      "VALUES": ["Conway", "HighLife", "Seeds", "Day&Night", "Life34"]
    },
    {
      "NAME": "speed",
      "TYPE": "float",
      "LABEL": "Speed",
      "DEFAULT": 10.0,
      "MIN": 0.1,
      "MAX": 60.0
    },
    {
      "NAME": "cellSize",
      "TYPE": "float",
      "LABEL": "Cell Size",
      "DEFAULT": 4.0,
      "MIN": 1.0,
      "MAX": 16.0
    },
    {
      "NAME": "randomSeed",
      "TYPE": "float",
      "LABEL": "Random Seed",
      "DEFAULT": 0.0,
      "MIN": 0.0,
      "MAX": 1000.0
    },
    {
      "NAME": "density",
      "TYPE": "float",
      "LABEL": "Initial Density",
      "DEFAULT": 0.3,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "pattern",
      "TYPE": "long",
      "LABEL": "Initial Pattern",
      "DEFAULT": 0,
      "VALUES": ["Random", "Glider", "Pulsar", "Gosper Gun", "R-Pentomino", "Acorn"]
    },
    {
      "NAME": "aliveColor",
      "TYPE": "color",
      "LABEL": "Alive Color",
      "DEFAULT": [1.0, 1.0, 1.0, 1.0]
    },
    {
      "NAME": "deadColor",
      "TYPE": "color",
      "LABEL": "Dead Color",
      "DEFAULT": [0.0, 0.0, 0.0, 1.0]
    },
    {
      "NAME": "trailFade",
      "TYPE": "float",
      "LABEL": "Trail Fade",
      "DEFAULT": 0.0,
      "MIN": 0.0,
      "MAX": 0.99
    },
    {
      "NAME": "reset",
      "TYPE": "event",
      "LABEL": "Reset"
    },
    {
      "NAME": "pause",
      "TYPE": "bool",
      "LABEL": "Pause",
      "DEFAULT": false
    },
    {
      "NAME": "currentState",
      "TYPE": "IMAGE",
      "ACCESS": "read_write",
      "FORMAT": "RGBA8",
      "WIDTH": 256,
      "HEIGHT": 256,
      "PERSISTENT": true
    },
    {
      "NAME": "nextState",
      "TYPE": "IMAGE",
      "ACCESS": "read_write",
      "FORMAT": "RGBA8",
      "WIDTH": 256,
      "HEIGHT": 256,
      "PERSISTENT": true
    }
  ],
  "PASSES": [{
    "LOCAL_SIZE": [16, 16, 1],
    "EXECUTION_MODEL": { "TYPE": "2D_IMAGE", "TARGET": "currentState" }
  }]
}*/

// Hash function for pseudo-random generation
float hash(vec2 p, float seed) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031 + seed);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// Check if a pattern cell should be alive
bool isPatternCell(ivec2 pos, ivec2 center, int patternType) {
    ivec2 rel = pos - center;
    
    if (patternType == 1) { // Glider
        return (rel == ivec2(0, -1)) || (rel == ivec2(1, 0)) || 
               (rel == ivec2(-1, 1)) || (rel == ivec2(0, 1)) || (rel == ivec2(1, 1));
    }
    else if (patternType == 2) { // Pulsar (simplified center part)
        int x = abs(rel.x);
        int y = abs(rel.y);
        return ((x == 2 || x == 3 || x == 4) && (y == 1 || y == 6)) ||
               ((y == 2 || y == 3 || y == 4) && (x == 1 || x == 6));
    }
    else if (patternType == 3) { // Gosper Glider Gun (simplified part)
        // Left square
        if (rel.x >= 0 && rel.x <= 1 && rel.y >= 0 && rel.y <= 1) return true;
        // Right part
        if (rel == ivec2(10, 0) || rel == ivec2(10, -1) || rel == ivec2(10, 1)) return true;
        if (rel == ivec2(11, -2) || rel == ivec2(11, 2)) return true;
        if (rel == ivec2(12, -3) || rel == ivec2(12, 3)) return true;
        if (rel == ivec2(13, -3) || rel == ivec2(13, 3)) return true;
        if (rel == ivec2(14, 0)) return true;
        if (rel == ivec2(15, -2) || rel == ivec2(15, 2)) return true;
        if (rel == ivec2(16, -1) || rel == ivec2(16, 0) || rel == ivec2(16, 1)) return true;
        if (rel == ivec2(17, 0)) return true;
        // Far right square
        if (rel.x >= 34 && rel.x <= 35 && rel.y >= -1 && rel.y <= 0) return true;
    }
    else if (patternType == 4) { // R-Pentomino
        return (rel == ivec2(0, 0)) || (rel == ivec2(-1, 0)) || 
               (rel == ivec2(0, -1)) || (rel == ivec2(0, 1)) || (rel == ivec2(1, -1));
    }
    else if (patternType == 5) { // Acorn
        return (rel == ivec2(-3, 0)) || (rel == ivec2(-2, -1)) || 
               (rel == ivec2(-2, 1)) || (rel == ivec2(0, 0)) || 
               (rel == ivec2(1, 0)) || (rel == ivec2(2, 0)) || (rel == ivec2(3, 0));
    }
    
    return false;
}

// Count living neighbors
int countNeighbors(ivec2 coord, ivec2 size) {
    int count = 0;
    for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
            if (dx == 0 && dy == 0) continue;
            
            // Wrap around edges (toroidal topology)
            ivec2 neighborCoord = coord + ivec2(dx, dy);
            neighborCoord.x = (neighborCoord.x + size.x) % size.x;
            neighborCoord.y = (neighborCoord.y + size.y) % size.y;
            
            vec4 state = imageLoad(currentState, neighborCoord);
            if (state.r > 0.5) count++;
        }
    }
    return count;
}

// Apply rules based on algorithm type
bool applyRules(bool alive, int neighbors, int algo) {
    if (algo == 0) { // Conway's Game of Life (B3/S23)
        if (alive) {
            return neighbors == 2 || neighbors == 3;
        } else {
            return neighbors == 3;
        }
    }
    else if (algo == 1) { // HighLife (B36/S23)
        if (alive) {
            return neighbors == 2 || neighbors == 3;
        } else {
            return neighbors == 3 || neighbors == 6;
        }
    }
    else if (algo == 2) { // Seeds (B2/S)
        if (alive) {
            return false; // Seeds always die
        } else {
            return neighbors == 2;
        }
    }
    else if (algo == 3) { // Day & Night (B3678/S34678)
        if (alive) {
            return neighbors == 3 || neighbors == 4 || neighbors == 6 || 
                   neighbors == 7 || neighbors == 8;
        } else {
            return neighbors == 3 || neighbors == 6 || neighbors == 7 || neighbors == 8;
        }
    }
    else if (algo == 4) { // Life 3-4 (B34/S34)
        return neighbors == 3 || neighbors == 4;
    }
    
    return false;
}

void main() {
    ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
    ivec2 stateSize = imageSize(currentState);
    ivec2 outputSize = imageSize(outputImage);
    
    if (coord.x >= stateSize.x || coord.y >= stateSize.y)
        return;
    
    // Initialize or reset if needed
    if (reset || FRAMEINDEX == 0) {
        vec4 newState = vec4(0.0);
        
        if (pattern == 0) { // Random
            float rand = hash(vec2(coord), randomSeed);
            newState.r = (rand < density) ? 1.0 : 0.0;
        } else {
            // Place pattern in center
            ivec2 center = stateSize / 2;
            newState.r = isPatternCell(coord, center, pattern) ? 1.0 : 0.0;
        }
        
        imageStore(currentState, coord, newState);
        imageStore(nextState, coord, newState);
    }
    else if (!pause && mod(TIME, 1.0 / speed) < TIME) {
        // Update simulation
        vec4 current = imageLoad(currentState, coord);
        bool alive = current.r > 0.5;
        
        int neighbors = countNeighbors(coord, stateSize);
        bool nextAlive = applyRules(alive, neighbors, algorithm);
        
        vec4 next = vec4(nextAlive ? 1.0 : 0.0);
        
        // Apply trail fade if enabled
        if (trailFade > 0.0 && !nextAlive && current.g > 0.0) {
            next.g = current.g * (1.0 - trailFade);
            next.b = current.b * (1.0 - trailFade);
        } else if (nextAlive) {
            next.g = 1.0;
            next.b = 1.0;
        }
        
        imageStore(nextState, coord, next);
        
        // Swap states at end of frame
        if (coord == ivec2(0, 0)) {
            barrier();
            // Copy nextState to currentState for next iteration
            for (int x = 0; x < stateSize.x; x++) {
                for (int y = 0; y < stateSize.y; y++) {
                    ivec2 p = ivec2(x, y);
                    imageStore(currentState, p, imageLoad(nextState, p));
                }
            }
        }
    }
    
    // Render to output with cell size scaling
    vec4 state = imageLoad(currentState, coord);
    vec4 color = mix(deadColor, aliveColor, state.r);
    
    // Add trail coloring if enabled
    if (trailFade > 0.0 && state.r < 0.5 && state.g > 0.0) {
        color = mix(deadColor, aliveColor * vec4(0.3, 0.5, 0.8, 1.0), state.g);
    }
    
    // Write to scaled output
    int cs = int(cellSize);
    ivec2 baseCoord = coord * cs;
    for (int dx = 0; dx < cs; dx++) {
        for (int dy = 0; dy < cs; dy++) {
            ivec2 outCoord = baseCoord + ivec2(dx, dy);
            if (outCoord.x < outputSize.x && outCoord.y < outputSize.y) {
                imageStore(outputImage, outCoord, color);
            }
        }
    }
}
