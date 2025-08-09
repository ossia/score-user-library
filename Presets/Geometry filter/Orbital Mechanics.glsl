/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Orbital mechanics simulation with multiple celestial bodies",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Physics", "Orbital" ],
  "INPUTS": [
    {
      "NAME": "central_mass",
      "TYPE": "float",
      "DEFAULT": 10.0,
      "MIN": 0.1,
      "MAX": 50.0
    },
    {
      "NAME": "central_position",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 0.0, 0.0]
    },
    {
      "NAME": "orbital_system",
      "TYPE": "long",
      "VALUES": ["Single Star", "Binary Star", "Planetary System", "Galaxy Arms", "Three Body"],
      "DEFAULT": 2
    },
    {
      "NAME": "time_scale",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 10.0
    },
    {
      "NAME": "eccentricity",
      "TYPE": "float",
      "DEFAULT": 0.2,
      "MIN": 0.0,
      "MAX": 0.9
    },
    {
      "NAME": "inclination_variation",
      "TYPE": "float",
      "DEFAULT": 0.3,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "secondary_mass",
      "TYPE": "float",
      "DEFAULT": 3.0,
      "MIN": 0.1,
      "MAX": 20.0
    },
    {
      "NAME": "secondary_distance",
      "TYPE": "float",
      "DEFAULT": 4.0,
      "MIN": 1.0,
      "MAX": 10.0
    },
    {
      "NAME": "show_trails",
      "TYPE": "bool",
      "DEFAULT": false
    },
    {
      "NAME": "gravitational_constant",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 5.0
    },
    {
      "NAME": "perturbation_strength",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": 0.0,
      "MAX": 1.0
    }
  ]
}*/

#define PI 3.14159265359
#define TAU 6.28318530718

// Orbital mechanics functions
float orbit_hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

vec3 orbit_hash3(float n) {
    return fract(sin(vec3(n, n + 1.0, n + 2.0)) * vec3(43758.5453, 22578.1459, 19642.3490));
}

// Calculate gravitational force
vec3 orbit_gravitational_force(vec3 pos1, vec3 pos2, float mass1, float mass2, float G) {
    vec3 r = pos2 - pos1;
    float r_mag = length(r);
    
    if (r_mag < 0.01) return vec3(0.0); // Avoid singularity
    
    float force_magnitude = G * mass1 * mass2 / (r_mag * r_mag);
    vec3 force_direction = r / r_mag;
    
    return force_direction * force_magnitude;
}

// Convert orbital elements to Cartesian coordinates
vec3 orbit_kepler_to_cartesian(float semi_major_axis, float eccentricity, float mean_anomaly, 
                              float inclination, float arg_periapsis, float longitude_ascending) {
    // Solve Kepler's equation iteratively (simplified)
    float eccentric_anomaly = mean_anomaly;
    for (int i = 0; i < 3; i++) {
        eccentric_anomaly = mean_anomaly + eccentricity * sin(eccentric_anomaly);
    }
    
    // True anomaly
    float true_anomaly = 2.0 * atan(sqrt((1.0 + eccentricity) / (1.0 - eccentricity)) * 
                                   tan(eccentric_anomaly * 0.5));
    
    // Distance from focus
    float radius = semi_major_axis * (1.0 - eccentricity * cos(eccentric_anomaly));
    
    // Position in orbital plane
    vec3 pos_orbital = vec3(
        radius * cos(true_anomaly),
        radius * sin(true_anomaly),
        0.0
    );
    
    // Rotation matrices to transform to 3D space
    float cos_i = cos(inclination);
    float sin_i = sin(inclination);
    float cos_w = cos(arg_periapsis);
    float sin_w = sin(arg_periapsis);
    float cos_o = cos(longitude_ascending);
    float sin_o = sin(longitude_ascending);
    
    // Transform to 3D coordinates
    vec3 pos_3d = vec3(
        (cos_o * cos_w - sin_o * sin_w * cos_i) * pos_orbital.x + 
        (-cos_o * sin_w - sin_o * cos_w * cos_i) * pos_orbital.y,
        
        (sin_o * cos_w + cos_o * sin_w * cos_i) * pos_orbital.x + 
        (-sin_o * sin_w + cos_o * cos_w * cos_i) * pos_orbital.y,
        
        sin_w * sin_i * pos_orbital.x + cos_w * sin_i * pos_orbital.y
    );
    
    return pos_3d;
}

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    float particle_id = float(gl_VertexIndex);
    vec3 particle_seed = orbit_hash3(particle_id);
    
    float animated_time = TIME * this_filter.time_scale;
    
    if (this_filter.orbital_system == 0) { // Single Star
        // Simple circular/elliptical orbits around central mass
        float orbital_radius = 1.0 + particle_seed.x * 3.0;
        float orbital_speed = sqrt(this_filter.gravitational_constant * this_filter.central_mass / orbital_radius);
        
        float mean_anomaly = animated_time * orbital_speed + particle_seed.y * TAU;
        float inclination = particle_seed.z * this_filter.inclination_variation * PI * 0.25;
        
        position = this_filter.central_position + orbit_kepler_to_cartesian(
            orbital_radius, this_filter.eccentricity, mean_anomaly, 
            inclination, particle_seed.x * TAU, particle_seed.y * TAU
        );
        
        // Color based on orbital radius
        float radius_factor = orbital_radius / 4.0;
        color.rgb = vec3(1.0 - radius_factor, radius_factor, 0.5);
    }
    else if (this_filter.orbital_system == 1) { // Binary Star
        // Two massive objects orbiting each other
        vec3 star1_pos = this_filter.central_position + vec3(cos(animated_time * 0.5), 0.0, sin(animated_time * 0.5)) * this_filter.secondary_distance * 0.5;
        vec3 star2_pos = this_filter.central_position - vec3(cos(animated_time * 0.5), 0.0, sin(animated_time * 0.5)) * this_filter.secondary_distance * 0.5;
        
        // Particles orbit around one of the two stars or the barycenter
        vec3 primary_pos;
        float primary_mass;
        
        if (particle_seed.x < 0.4) {
            primary_pos = star1_pos;
            primary_mass = this_filter.central_mass;
        } else if (particle_seed.x < 0.8) {
            primary_pos = star2_pos;
            primary_mass = this_filter.secondary_mass;
        } else {
            // Orbit around barycenter
            primary_pos = (star1_pos * this_filter.central_mass + star2_pos * this_filter.secondary_mass) / 
                         (this_filter.central_mass + this_filter.secondary_mass);
            primary_mass = this_filter.central_mass + this_filter.secondary_mass;
        }
        
        float orbital_radius = 0.5 + particle_seed.y * 1.5;
        float orbital_speed = sqrt(this_filter.gravitational_constant * primary_mass / orbital_radius);
        
        float mean_anomaly = animated_time * orbital_speed + particle_seed.z * TAU;
        position = primary_pos + orbit_kepler_to_cartesian(
            orbital_radius, this_filter.eccentricity * 0.5, mean_anomaly, 
            particle_seed.x * this_filter.inclination_variation * PI * 0.1, 
            particle_seed.y * TAU, particle_seed.z * TAU
        );
        
        // Color based on which star they orbit
        if (particle_seed.x < 0.4) color.rgb = vec3(1.0, 0.3, 0.3);
        else if (particle_seed.x < 0.8) color.rgb = vec3(0.3, 0.3, 1.0);
        else color.rgb = vec3(0.8, 0.8, 0.3);
    }
    else if (this_filter.orbital_system == 2) { // Planetary System
        // Multiple planetary orbits with different characteristics
        int planet_index = int(particle_seed.x * 5.0);
        float base_radius = 1.0 + float(planet_index) * 0.8;
        float orbital_radius = base_radius + (particle_seed.y - 0.5) * 0.3;
        
        // Different orbital periods (Kepler's third law approximation)
        float orbital_period = pow(orbital_radius / base_radius, 1.5);
        float orbital_speed = TAU / (orbital_period + 1.0);
        
        float mean_anomaly = animated_time * orbital_speed + particle_seed.z * TAU;
        float inclination = particle_seed.x * this_filter.inclination_variation * PI * 0.1;
        
        position = this_filter.central_position + orbit_kepler_to_cartesian(
            orbital_radius, this_filter.eccentricity, mean_anomaly, 
            inclination, particle_seed.y * TAU, particle_seed.z * TAU
        );
        
        // Color based on planet
        vec3 planet_colors[5];
        planet_colors[0] = vec3(1.0, 0.8, 0.6); // Mercury-like
        planet_colors[1] = vec3(1.0, 0.9, 0.3); // Venus-like
        planet_colors[2] = vec3(0.3, 0.7, 1.0); // Earth-like
        planet_colors[3] = vec3(1.0, 0.4, 0.2); // Mars-like
        planet_colors[4] = vec3(0.8, 0.7, 0.5); // Jupiter-like
        
        color.rgb = planet_colors[planet_index];
    }
    else if (this_filter.orbital_system == 3) { // Galaxy Arms
        // Spiral galaxy arm structure
        float radius = 1.0 + particle_seed.x * 4.0;
        float spiral_angle = log(radius) * 0.3 + animated_time * 0.1;
        
        // Add spiral arm structure
        float arm_number = floor(particle_seed.y * 4.0);
        spiral_angle += arm_number * PI * 0.5;
        
        // Some random variation
        spiral_angle += (particle_seed.z - 0.5) * 0.5;
        
        float height = (particle_seed.z - 0.5) * 0.2 * radius;
        
        position = this_filter.central_position + vec3(
            cos(spiral_angle) * radius,
            height,
            sin(spiral_angle) * radius
        );
        
        // Color based on distance from center
        float distance_factor = radius / 5.0;
        color.rgb = vec3(1.0 - distance_factor * 0.5, distance_factor, 1.0 - distance_factor);
    }
    else if (this_filter.orbital_system == 4) { // Three Body Problem
        // Lagrange points and chaotic orbits
        float L = this_filter.secondary_distance;
        vec3 body1_pos = this_filter.central_position + vec3(-L * 0.3, 0.0, 0.0);
        vec3 body2_pos = this_filter.central_position + vec3(L * 0.7, 0.0, 0.0);
        vec3 body3_pos = this_filter.central_position + vec3(L * 0.2, L * 0.866, 0.0); // Triangular Lagrange point
        
        // Rotate the system
        float system_rotation = animated_time * 0.2;
        mat3 rotation_matrix = mat3(
            cos(system_rotation), 0.0, sin(system_rotation),
            0.0, 1.0, 0.0,
            -sin(system_rotation), 0.0, cos(system_rotation)
        );
        
        body1_pos = this_filter.central_position + rotation_matrix * (body1_pos - this_filter.central_position);
        body2_pos = this_filter.central_position + rotation_matrix * (body2_pos - this_filter.central_position);
        body3_pos = this_filter.central_position + rotation_matrix * (body3_pos - this_filter.central_position);
        
        // Particles attracted to all three bodies
        vec3 total_force = vec3(0.0);
        
        vec3 to_body1 = body1_pos - position;
        vec3 to_body2 = body2_pos - position;
        vec3 to_body3 = body3_pos - position;
        
        float dist1 = length(to_body1);
        float dist2 = length(to_body2);
        float dist3 = length(to_body3);
        
        if (dist1 > 0.1) total_force += normalize(to_body1) * this_filter.central_mass / (dist1 * dist1);
        if (dist2 > 0.1) total_force += normalize(to_body2) * this_filter.secondary_mass / (dist2 * dist2);
        if (dist3 > 0.1) total_force += normalize(to_body3) * (this_filter.central_mass * 0.5) / (dist3 * dist3);
        
        // Apply force as displacement
        position += total_force * 0.01 * this_filter.gravitational_constant;
        
        // Chaotic coloring
        float chaos = length(total_force);
        color.rgb = vec3(chaos, 1.0 - chaos * 0.5, sin(chaos * PI));
    }
    
    // Add perturbations if enabled
    if (this_filter.perturbation_strength > 0.0) {
        vec3 perturbation = (orbit_hash3(particle_id + animated_time * 0.1) - 0.5) * this_filter.perturbation_strength * 0.1;
        position += perturbation;
    }
    
    // Trail effect (simplified)
    if (this_filter.show_trails) {
        vec3 trail_offset = (orbit_hash3(particle_id + floor(animated_time * 10.0)) - 0.5) * 0.05;
        position += trail_offset;
        color.a *= 0.7; // Make trails more transparent
    }
}