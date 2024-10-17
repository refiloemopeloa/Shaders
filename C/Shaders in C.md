# Shaders in C

In this guide, we'll focus on using GLSL shaders in C. This method will work on C++ as well. For other languages, such as JavaScript using WebGL, refer to this guide: [[Shaders in WebGL]].

For the theory and details behind shaders, refer to this guide: [A Guide to Shaders](https://github.com/refiloemopeloa/Shaders/blob/main/A%20Guide%20to%20Shaders.md)

## Creating a shader

Creating a shader involves five steps: Declaring, compiling, linking, attaching, and using the shader.

### Declaring a shader

Before we begin, ensure you've imported `GL/glut.h`.

First, we need a variable to point to the code of our shader:

```C
const char *vertex_shader_source;
const char *fragment_shader_source;
```

From here there are two methods you can follow:

#### Internal shaders

Internal shaders is when you type your shaders directly in your program, similar to internal CSS. This reduces the complexity of loading your shaders, but also makes it harder to read. You also lose the support of any support from your IDE if you're using one, since it views it as a string, not actual code.

Let's look at an example:

```C
const char *vertex_shader_source =
//Declare local variables
"    attribute vec4 a_position;\n"
"    attribute vec3 a_color;\n"
"    uniform mat4 u_modelViewMatrix;\n"
"    uniform mat4 u_projectionMatrix;\n"
"    varying vec3 v_color;\n"
//Define a main method
"void main() {\n"
"    v_color = a_color;\n"
"    gl_Position = u_projectionMatrix * u_modelViewMatrix * a_position;\n"
"}\0";
```

#### External shaders

External shaders is when you write your shaders in a different file to your program. Shader files don't really have extensions, so you can use whatever you'd like. However, as good practice, you can give your shader files the extension `.glsl`. If you'd like to be more specific, you can add the type of shader to the extension, like `.vertex.glsl`. Here's an example:

```C
//file: vertex_shader.glsl

//Declare local variables
    attribute vec4 a_position;
    attribute vec3 a_color;
    uniform mat4 u_modelViewMatrix;
    uniform mat4 u_projectionMatrix;
    varying vec3 v_color;
//Define a main method
void main() {
    v_color = a_color;
    gl_Position = u_projectionMatrix * u_modelViewMatrix * a_position;
}
```

To pass this to C, we need to read from the file. You can use this function to read from the file:

```C
char* read_shader_source(const char* file_path) {

    FILE* file = fopen(file_path, "r");

    if (file == NULL) {

        printf("Failed to open file: %s\n", file_path);

        return NULL;

    }



    // Seek to the end of file to determine its size

    fseek(file, 0, SEEK_END);

    long fileSize = ftell(file);

    fseek(file, 0, SEEK_SET);



    // Allocate memory for the file content

    char* content = (char*)malloc(fileSize + 1);

    if (content == NULL) {

        printf("Failed to allocate memory for file content\n");

        fclose(file);

        return NULL;

    }



    // Read the file content

    size_t bytesRead = fread(content, 1, fileSize, file);

    if (bytesRead < fileSize) {

        printf("Failed to read file content\n");

        free(content);

        fclose(file);

        return NULL;

    }



    content[fileSize] = '\0';  // Null-terminate the string

    fclose(file);

    return content;

}
```

Then set your vertex shader pointer to the following:

```C
char *vertex_shader_source = read_shader_source("vertex_shader.glsl");
```

### Compile a shader

To compile a shader, we can call the following function:

```C
GLuint compile_shader(GLenum type, const char *source)

{

    GLuint shader = glCreateShader(type);

    glShaderSource(shader, 1, &source, NULL);

    glCompileShader(shader);



    int success;

    char infoLog[512];

    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);

    if (!success)

    {

        glGetShaderInfoLog(shader, 512, NULL, infoLog);

        printf("ERROR::SHADER::COMPILATION_FAILED\n%s\n", infoLog);

        return 0;

    }

    return shader;

}
```

Then, store the compiled shader in a variable:

```C
GLuint vertex_shader = compile_shader(GL_VERTEX_SHADER, vertex_shader_source);
```

Once you've compiled your shader, you can free the memory buffer holding the code to your shader:

```C
free(vertex_shader_source);
```

### Linking a shader

Once we've compiled, we can link the shader. First we need to create a shader program:

```C
GLuint shader_program = glCreateProgram();
```

Then, we attach our shaders to the program:

```C
glAttachShader(shader_program, vertex_shader);
```

Finally, we link the program to the shader:

```C
glLinkProgram(shader_program);
```

Lastly, we can free our shaders:

```C
glDeleteShader(vertex_shader);
```

It is good practice to check if there are linking errors with your shaders. You can do this as follows:

```C
int success;

char infoLog[512];

glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);

if (!success) {

    glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);

    printf("ERROR::SHADER::PROGRAM::LINKING_FAILED\n%s\n", infoLog);

    exit(1);

}
```

### Using our shaders

The last thing we need to do to actually see the effects of our shaders is to call them in our code. This is usually done in the `display` function:

```C
glUseProgram(shader_program);
```

### Cube demo

Now that we've done everything above, we can make an actual program. Create a directory called `shader-cube`, and create three files in it, one called `cube.c`, one called `vertex_shader.glsl` and one called `fragment_shader.glsl`.

Once that is done, you can add the following code to each of the files:

In `main.c`:

You can find the code here: <a href="https://github.com/refiloemopeloa/Shaders/blob/main/C/shader-cube/cube.c">main.c</a>

In `vertex.glsl`:

```C
#version 330 core
layout (location = 0) in vec3 aPos;

uniform mat4 model;

out vec3 FragPos;

void main() {
    gl_Position = model * vec4(aPos, 2.0);
    FragPos = aPos;
}
```

In `fragment.glsl`:

```C
#version 330 core
out vec4 FragColor;

void main() {
    vec3 color;
    color = vec3(1.0, 0.0, 1.0);
    FragColor = vec4(color, 1.0);
}
```

You should get something like this:

<img src="assets/shader-cube.gif" style="background-color: white">

You now have your cube with shaders determining the vertex positions and the color of the cube.
