#version 330 core
layout (location = 0) in vec3 aPos;

uniform mat4 model;

out vec3 FragPos;

void main() {
    gl_Position = model * vec4(aPos, 2.0);
    FragPos = aPos;
}
