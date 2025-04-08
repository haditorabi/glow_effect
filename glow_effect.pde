// Starfield
// Adapted from Alessandro Valentino's p5.js code
// Converted to Processing 4 Java

final int MAX_NUMBER = 100;
PShader starfieldShader;
PGraphics buffer, bufferB;
String[] palette = {"#231942", "#5E548E", "#9F86C0", "#BE95C4", "#8A430A"};
float[][] particles = new float[MAX_NUMBER][3];
float[][] colors = new float[MAX_NUMBER][3];
float time = 0.0;
int w;

void setup() {
  size(1200, 900, P2D);
  background(0);
  w = max(width, height);
  
  // Create shader files
  createShaderFiles();
  
  // Load the shader files
  starfieldShader = loadShader("starfieldFrag.glsl", "starfieldVert.glsl");
  
  // Setup graphics buffers
  buffer = createGraphics(w, w, P2D);
  bufferB = createGraphics(w, w, P2D);
  
  // Initialize particles and colors
  for (int i = 0; i < MAX_NUMBER; i++) {
    particles[i][0] = random(-1f, 1f);
    particles[i][1] = random(-1f, 1f);
    particles[i][2] = random(0.7f, 0.8f);
    
    color col = unhex(palette[int(random(1, 1))].substring(1)); // Convert hex to color
    colors[i][0] = red(col);
    colors[i][1] = green(col);
    colors[i][2] = blue(col);
  }
  noLoop();
}

void draw() {
  background(0);
    
  // Prepare and set shader uniforms
  float[] particleData = flattenParticles();
  float[] colorData = flattenColors();
  
  starfieldShader.set("slide", 0.9f);
  starfieldShader.set("resolution", (float)w, (float)w);
  starfieldShader.set("particles", particleData, 3);
  starfieldShader.set("colors", colorData, 3);
  
  // Apply shader to buffer
  buffer.beginDraw();
  buffer.shader(starfieldShader);
  buffer.rect(0, 0, w, w);
  buffer.endDraw();
  
  
  // Display the result
  image(buffer, (width - w) * 0.5, (height - w) * 0.5, w, w);
  

}

// Flatten particle data for shader
float[] flattenParticles() {
  float[] flat = new float[MAX_NUMBER * 3];
  for (int i = 0; i < MAX_NUMBER; i++) {
    flat[i * 3] = particles[i][0];
    flat[i * 3 + 1] = particles[i][1];
    flat[i * 3 + 2] = particles[i][2];
  }
  return flat;
}

// Flatten color data for shader
float[] flattenColors() {
  float[] flat = new float[MAX_NUMBER * 3];
  for (int i = 0; i < MAX_NUMBER; i++) {
    flat[i * 3] = colors[i][0];
    flat[i * 3 + 1] = colors[i][1];
    flat[i * 3 + 2] = colors[i][2];
  }
  return flat;
}

// Create shader files in the data directory
void createShaderFiles() {
  File dataFolder = new File(sketchPath("data"));
  if (!dataFolder.exists()) {
    dataFolder.mkdir();
  }
  
  // Create vertex shader file
  String vertShaderContent = 
    "precision highp float;\n" +
    "attribute vec3 position;\n" +
    "void main() {\n" +
    "  vec4 positionVec4 = vec4(position, 1.0);\n" +
    "  positionVec4.xy = positionVec4.xy * 2.0 - 1.0;\n" +
    "  gl_Position = positionVec4;\n" +
    "}";
  
  saveStrings("data/starfieldVert.glsl", vertShaderContent.split("\n"));
  
  // Create fragment shader file
  String fragShaderContent = 
    "precision highp float;\n" +
    "\n" +
    "uniform float time;\n" +
    "uniform float a;\n" +
    "uniform float slide;\n" +
    "uniform vec2 resolution;\n" +
    "uniform vec3 particles[" + MAX_NUMBER + "];\n" +
    "uniform vec3 colors[" + MAX_NUMBER + "];\n" +
    "\n" +
    "void main() {\n" +
    "  vec2 st = gl_FragCoord.xy / resolution.xy;\n" +
    "  \n" +
    "  // Center coordinates\n" +
    "  vec2 st_c = 1.0 - 2.0 * st;\n" +
    "  \n" +
    "  // Restore aspect ratio\n" +
    "  st_c.y *= resolution.y/resolution.x;\n" +
    "  float angle = a * 2.0 * 3.1415;\n" +
    "  mat2 R = mat2(cos(angle), sin(angle), -sin(angle), cos(angle));\n" +
    "  st_c *= R;\n" +
    "  float mult = 0.01;\n" +
    "  \n" +
    "  vec3 col = vec3(0.0);\n" +
    "  \n" +
    "  for(int i = 0; i < " + MAX_NUMBER + "; i++) {\n" +
    "    vec3 particle = particles[i];\n" +
    "    vec2 pos = particle.xy;\n" +
    "    float m = particle.z * 1.1;\n" +
    "    vec3 color = colors[i] / 255.0;\n" +
    "    col += color / distance(st_c, pos) * m * mult;\n" +
    "  }\n" +
    "  \n" +
    "  vec3 output_color = col;\n" +
    "  vec3 contr = output_color * output_color;\n" +
    "  output_color = mix(output_color, contr, slide);\n" +
    "  gl_FragColor = vec4(output_color, 1.0);\n" +
    "}";
  
  saveStrings("data/starfieldFrag.glsl", fragShaderContent.split("\n"));
}
