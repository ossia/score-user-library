/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Physics-based particle system with gravity, collision, and forces",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Physics", "Particles" ],
  "INPUTS": [
    {
      "NAME": "gravity_strength",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": -2.0,
      "MAX": 2.0
    },
    {
      "NAME": "gravity_direction",
      "TYPE": "point3D",
      "DEFAULT": [0.0, -1.0, 0.0]
    },
    {
      "NAME": "bounce_factor",
      "TYPE": "float",
      "DEFAULT": 0.7,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "ground_height",
      "TYPE": "float",
      "DEFAULT": -1.0,
      "MIN": -5.0,
      "MAX": 2.0
    },
    {
      "NAME": "air_resistance",
      "TYPE": "float",
      "DEFAULT": 0.05,
      "MIN": 0.0,
      "MAX": 0.5
    },
    {
      "NAME": "initial_velocity_scale",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 5.0
    },
    {
      "NAME": "chaos_factor",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "attractor_strength",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": 0.0,
      "MAX": 3.0
    },
    {
      "NAME": "attractor_position",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 2.0, 0.0]
    },
    {
      "NAME": "collision_walls",
      "TYPE": "bool",
      "DEFAULT": true
    },
    {
      "NAME": "wall_distance",
      "TYPE": "float",
      "DEFAULT": 3.0,
      "MIN": 1.0,
      "MAX": 10.0
    },
    {
      "NAME": "reset_simulation",
      "TYPE": "bool",
      "DEFAULT": false
    }
  ]
}*/

// Physics simulation using vertex index as particle ID
float phys_hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

vec3 phys_hash3(float n) {
    return fract(sin(vec3(n, n + 1.0, n + 2.0)) * vec3(43758.5453, 22578.1459, 19642.3490));
}

// Simple noise for chaos
float phys_noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float n = i.x + i.y * 157.0 + 113.0 * i.z;
    return mix(mix(mix(phys_hash(n + 0.0), phys_hash(n + 1.0), f.x),
                   mix(phys_hash(n + 157.0), phys_hash(n + 158.0), f.x), f.y),
               mix(mix(phys_hash(n + 113.0), phys_hash(n + 114.0), f.x),
                   mix(phys_hash(n + 270.0), phys_hash(n + 271.0), f.x), f.y), f.z);
}

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    float particle_id = float(gl_VertexIndex);
    vec3 original_position = position;
    
    // Reset simulation if requested
    if (this_filter.reset_simulation) {
        position = phys_hash3(particle_id) * 4.0 - 2.0;
        return;
    }
    
    // Calculate unique properties per particle
    vec3 particle_seed = phys_hash3(particle_id);
    float particle_mass = 0.5 + particle_seed.x * 0.5; // Mass between 0.5 and 1.0
    
    // Calculate initial velocity based on position and some randomness
    vec3 initial_velocity = (particle_seed - 0.5) * this_filter.initial_velocity_scale;
    
    // Current velocity approximation (simplified - in real physics sim, this would be stored)
    vec3 velocity = initial_velocity * (1.0 - TIME * this_filter.air_resistance);
    
    // Apply gravity
    vec3 gravity_force = normalize(this_filter.gravity_direction) * this_filter.gravity_strength;
    
    // Apply physics over time
    float dt = 0.016; // Approximate 60fps delta time
    vec3 acceleration = gravity_force / particle_mass;
    
    // Add attractor force if enabled
    if (this_filter.attractor_strength > 0.0) {
        vec3 to_attractor = this_filter.attractor_position - position;
        float distance = length(to_attractor);
        
        if (distance > 0.001) {
            vec3 attractor_force = normalize(to_attractor) * this_filter.attractor_strength / (distance * distance + 1.0);
            acceleration += attractor_force / particle_mass;
        }
    }
    
    // Add some chaos/turbulence
    if (this_filter.chaos_factor > 0.0) {
        vec3 chaos = vec3(
            phys_noise(position + vec3(TIME * 0.5)),
            phys_noise(position + vec3(TIME * 0.5, 100.0, 0.0)),
            phys_noise(position + vec3(TIME * 0.5, 0.0, 100.0))
        ) - 0.5;
        acceleration += chaos * this_filter.chaos_factor;
    }
    
    // Apply air resistance
    velocity *= (1.0 - this_filter.air_resistance);
    
    // Simple physics integration
    velocity += acceleration * dt;
    vec3 new_position = position + velocity * dt * TIME;
    
    // Ground collision
    if (new_position.y <= this_filter.ground_height) {
        new_position.y = this_filter.ground_height;
        // Simulate bounce (simplified)
        if (velocity.y < 0.0) {
            velocity.y *= -this_filter.bounce_factor;
        }
    }
    
    // Wall collisions if enabled
    if (this_filter.collision_walls) {
        float wall_dist = this_filter.wall_distance;
        
        // X walls
        if (new_position.x > wall_dist) {
            new_position.x = wall_dist;
            velocity.x *= -this_filter.bounce_factor;
        }
        else if (new_position.x < -wall_dist) {
            new_position.x = -wall_dist;
            velocity.x *= -this_filter.bounce_factor;
        }
        
        // Z walls
        if (new_position.z > wall_dist) {
            new_position.z = wall_dist;
            velocity.z *= -this_filter.bounce_factor;
        }
        else if (new_position.z < -wall_dist) {
            new_position.z = -wall_dist;
            velocity.z *= -this_filter.bounce_factor;
        }
        
        // Ceiling
        if (new_position.y > wall_dist) {
            new_position.y = wall_dist;
            velocity.y *= -this_filter.bounce_factor;
        }
    }
    
    position = new_position;
    
    // Color particles based on velocity and height
    float speed = length(velocity);
    float height_factor = (position.y - this_filter.ground_height) / (this_filter.wall_distance - this_filter.ground_height);
    height_factor = clamp(height_factor, 0.0, 1.0);
    
    color.rgb = vec3(
        speed * 0.5 + 0.2,           // Red based on speed
        height_factor,               // Green based on height
        1.0 - speed * 0.3            // Blue inverse of speed
    );
    
    // Scale particles based on mass
    color.a = particle_mass;
}