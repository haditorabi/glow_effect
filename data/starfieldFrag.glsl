precision highp float;

uniform float time;
uniform float a;
uniform float slide;
uniform vec2 resolution;
uniform vec3 particles[200];
uniform vec3 colors[200];

void main() {
  vec2 st = gl_FragCoord.xy / resolution.xy;
  
  // Center coordinates
  vec2 st_c = 1.0 - 2.0 * st;
  
  // Restore aspect ratio
  st_c.y *= resolution.y/resolution.x;
  float angle = a * 2.0 * 3.1415;
  mat2 R = mat2(cos(angle), sin(angle), -sin(angle), cos(angle));
  st_c *= R;
  float mult = 0.01;
  
  vec3 col = vec3(0.0);
  
  for(int i = 0; i < 200; i++) {
    vec3 particle = particles[i];
    vec2 pos = particle.xy;
    float m = particle.z * 1.1;
    vec3 color = colors[i] / 255.0;
    col += color / distance(st_c, pos) * m * mult;
  }
  
  vec3 output_color = col;
  vec3 contr = output_color * output_color;
  output_color = mix(output_color, contr, slide);
  gl_FragColor = vec4(output_color, 1.0);
}
