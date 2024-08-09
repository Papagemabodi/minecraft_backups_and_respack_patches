#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main() {
    gl_Position = projection * view * model * vec4(aPos, 1.0);
    TexCoord = aTexCoord;
}

// Fragment shader
#version 330 core

in vec2 TexCoord;

out vec4 FragColor;

uniform sampler2D screenTexture;
uniform float curvatureAmount; // Adjustable setting

void main() {
    // Apply curvature to the UV coordinates
    vec2 uv = TexCoord;
    uv.x += curvatureAmount * sin(uv.y * 10.0); // Adjust the frequency as needed

    // Sample the color from the original texture
    vec4 originalColor = texture(screenTexture, uv);

    FragColor = originalColor;
}
