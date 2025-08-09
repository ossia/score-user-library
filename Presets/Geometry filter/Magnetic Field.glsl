/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Magnetic field effects with dipoles, loops, and field lines",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Physics", "Magnetic" ],
  "INPUTS": [
    {
      "NAME": "field_type",
      "TYPE": "long",
      "VALUES": ["Dipole", "Current Loop", "Solenoid", "Parallel Wires", "Helmholtz Coil"],
      "DEFAULT": 0
    },
    {
      "NAME": "field_strength",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 5.0
    },
    {
      "NAME": "magnet_position",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 0.0, 0.0]
    },
    {
      "NAME": "magnet_orientation",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 1.0, 0.0]
    },
    {
      "NAME": "loop_radius",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 5.0
    },
    {
      "NAME": "current_strength",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": -3.0,
      "MAX": 3.0
    },
    {
      "NAME": "visualization_mode",
      "TYPE": "long",
      "VALUES": ["Field Lines", "Force Vectors", "Potential", "Particle Traces"],
      "DEFAULT": 0
    },
    {
      "NAME": "animation_speed",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 3.0
    },
    {
      "NAME": "field_falloff",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 1.0,
      "MAX": 4.0
    },
    {
      "NAME": "particle_charge",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": -2.0,
      "MAX": 2.0
    },
    {
      "NAME": "damping_factor",
      "TYPE": "float",
      "DEFAULT": 0.95,
      "MIN": 0.1,
      "MAX": 1.0
    }
  ]
}*/

#define PI 3.14159265359

// Magnetic field calculations
float mag_hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

vec3 mag_hash3(float n) {
    return fract(sin(vec3(n, n + 1.0, n + 2.0)) * vec3(43758.5453, 22578.1459, 19642.3490));
}

// Calculate magnetic dipole field
vec3 mag_dipole_field(vec3 position, vec3 dipole_pos, vec3 dipole_moment, float strength) {
    vec3 r = position - dipole_pos;
    float r_mag = length(r);
    
    if (r_mag < 0.001) return vec3(0.0);
    
    vec3 r_hat = r / r_mag;
    float r3 = r_mag * r_mag * r_mag;
    
    // Magnetic dipole field: B = (μ₀/4π) * [3(m·r̂)r̂ - m] / r³
    float m_dot_r = dot(dipole_moment, r_hat);
    vec3 field = strength * (3.0 * m_dot_r * r_hat - dipole_moment) / r3;
    
    return field;
}

// Calculate field from current loop (simplified)
vec3 mag_current_loop_field(vec3 position, vec3 loop_center, vec3 loop_normal, float radius, float current) {
    vec3 r = position - loop_center;
    float distance = length(r);
    
    if (distance < 0.001) return vec3(0.0);
    
    // Simplified approximation for current loop field
    vec3 field_direction = loop_normal;
    float field_strength = current * radius * radius / (distance * distance * distance + radius * radius);
    
    return field_direction * field_strength;
}

// Calculate Lorentz force on a charged particle
vec3 mag_lorentz_force(vec3 velocity, vec3 magnetic_field, float charge) {
    return charge * cross(velocity, magnetic_field);
}

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    float particle_id = float(gl_VertexIndex);
    vec3 original_position = position;
    
    vec3 magnet_dir = normalize(this_filter.magnet_orientation);
    vec3 magnetic_field = vec3(0.0);
    
    // Calculate magnetic field based on type
    if (this_filter.field_type == 0) { // Dipole
        magnetic_field = mag_dipole_field(position, this_filter.magnet_position, 
                                        magnet_dir * this_filter.field_strength, 1.0);
    }
    else if (this_filter.field_type == 1) { // Current Loop
        magnetic_field = mag_current_loop_field(position, this_filter.magnet_position, 
                                              magnet_dir, this_filter.loop_radius, 
                                              this_filter.current_strength);
    }
    else if (this_filter.field_type == 2) { // Solenoid (simplified as multiple loops)
        vec3 solenoid_axis = magnet_dir;
        float solenoid_length = 2.0;
        int num_loops = 5;
        
        for (int i = 0; i < num_loops; i++) {
            float z_offset = (float(i) / float(num_loops - 1) - 0.5) * solenoid_length;
            vec3 loop_pos = this_filter.magnet_position + solenoid_axis * z_offset;
            
            vec3 loop_field = mag_current_loop_field(position, loop_pos, solenoid_axis, 
                                                   this_filter.loop_radius, this_filter.current_strength);
            magnetic_field += loop_field * 0.2; // Scale down for multiple loops
        }
    }
    else if (this_filter.field_type == 3) { // Parallel Wires
        vec3 wire1_pos = this_filter.magnet_position + vec3(0.5, 0.0, 0.0);
        vec3 wire2_pos = this_filter.magnet_position - vec3(0.5, 0.0, 0.0);
        
        // Simplified field from parallel current-carrying wires
        vec3 to_wire1 = position - wire1_pos;
        vec3 to_wire2 = position - wire2_pos;
        
        float dist1 = length(to_wire1);
        float dist2 = length(to_wire2);
        
        if (dist1 > 0.001) {
            vec3 field1 = cross(magnet_dir, normalize(to_wire1)) * this_filter.current_strength / (dist1 * dist1);
            magnetic_field += field1;
        }
        
        if (dist2 > 0.001) {
            vec3 field2 = cross(magnet_dir, normalize(to_wire2)) * (-this_filter.current_strength) / (dist2 * dist2);
            magnetic_field += field2;
        }
    }
    else if (this_filter.field_type == 4) { // Helmholtz Coil
        float coil_separation = this_filter.loop_radius;
        vec3 coil1_pos = this_filter.magnet_position + magnet_dir * coil_separation * 0.5;
        vec3 coil2_pos = this_filter.magnet_position - magnet_dir * coil_separation * 0.5;
        
        vec3 field1 = mag_current_loop_field(position, coil1_pos, magnet_dir, 
                                           this_filter.loop_radius, this_filter.current_strength);
        vec3 field2 = mag_current_loop_field(position, coil2_pos, magnet_dir, 
                                           this_filter.loop_radius, this_filter.current_strength);
        
        magnetic_field = field1 + field2;
    }
    
    // Apply field falloff
    float distance_to_magnet = length(position - this_filter.magnet_position);
    float falloff = 1.0 / pow(distance_to_magnet + 0.1, this_filter.field_falloff);
    magnetic_field *= falloff;
    
    // Different visualization modes
    if (this_filter.visualization_mode == 0) { // Field Lines
        // Align vertices along field lines
        float field_strength = length(magnetic_field);
        if (field_strength > 0.001) {
            vec3 field_direction = magnetic_field / field_strength;
            
            // Move along field line
            float step_size = 0.1;
            position += field_direction * step_size * this_filter.animation_speed * TIME * 0.1;
            
            // Color based on field strength
            color.rgb = vec3(field_strength, 0.5, 1.0 - field_strength * 0.5);
        }
    }
    else if (this_filter.visualization_mode == 1) { // Force Vectors
        // Show force vectors on charged particles
        vec3 particle_velocity = mag_hash3(particle_id) - 0.5; // Random initial velocity
        vec3 force = mag_lorentz_force(particle_velocity, magnetic_field, this_filter.particle_charge);
        
        // Displace vertex to show force direction
        position += normalize(force + vec3(0.001)) * length(force) * 0.2;
        
        color.rgb = vec3(abs(force.x), abs(force.y), abs(force.z));
    }
    else if (this_filter.visualization_mode == 2) { // Potential
        // Show magnetic potential (simplified)
        float potential = dot(magnetic_field, position - this_filter.magnet_position);
        
        // Displace based on potential
        position.y += potential * 0.1;
        
        // Color based on potential
        float normalized_potential = (potential + 1.0) * 0.5;
        color.rgb = vec3(normalized_potential, 0.3, 1.0 - normalized_potential);
    }
    else if (this_filter.visualization_mode == 3) { // Particle Traces
        // Simulate charged particle motion
        vec3 particle_seed = mag_hash3(particle_id);
        vec3 initial_velocity = (particle_seed - 0.5) * 2.0;
        
        // Simple particle motion under magnetic force
        vec3 velocity = initial_velocity;
        vec3 force = mag_lorentz_force(velocity, magnetic_field, this_filter.particle_charge);
        
        // Apply force (simplified integration)
        velocity += force * 0.01;
        velocity *= this_filter.damping_factor; // Damping
        
        // Update position
        position += velocity * TIME * this_filter.animation_speed * 0.1;
        
        // Color based on velocity
        float speed = length(velocity);
        color.rgb = vec3(speed, 1.0 - speed * 0.5, 0.5);
    }
    
    // Update normal to align with field (for field line visualization)
    if (this_filter.visualization_mode == 0 && length(magnetic_field) > 0.001) {
        normal = normalize(magnetic_field);
    }
}