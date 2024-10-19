# A Guide to Shaders

## What is a Shader?

A shader is just a program that runs on your GPU instead of your CPU. Shaders allow us to customize the visual output of a graphics application.

There are many languages to write shaders in, but for this guide, we will be using the OpenGL Shader Language for Embedded Systems, version 1.0, or GLSL ES 1.0.

Before we get into programming, let us lay a bit of theory on the table.

There are many kinds of shaders, but for now, we'll focus on two. The **vertex** shader and the **fragment** shader.

## Vertex shader

The vertex shader is the first programmable stage in the graphics pipeline. This is because it processes each vertex of the geometry, and it does so individually. Its main responsibilities include:

-   Transforming vertex coordinates from model space to clip space. In clip space coordinate system, each axis has a range from -1.0 to 1.0, regardless of aspect ratio, actual size, or any other factors.
-   Passing per-vertex data like colour, texture coordinates, and normals to the next stage in the pipeline.

After performing all needed transformations, the vertex shader returns the transformed vertex by saving it in a special variable called `glPosition`. 

The vertex shader can do the following:
* determine the coordinates within the face's texture of the texel ( a texel is just a single pixel within a texture  to apply to the vertex.)
* apply normals to determine the lighting factor to apply to the vertex.  

The information is stored in the `varying` or `attribute` variables to be shared with the fragment shader.

## Fragment shader

The fragment shader operates on each fragment that will potentially form part of the final pixel colour in the rendered image. This basically means that it is called once for every pixel on each shape to be drawn. It is also called the pixel shader. It is responsible for:

-   Setting the colour of pixels based on various inputs, including data passed from the vertex shader
-   Performing complex computations to create effects like texturing, shading, and lighting.

The results of the computation are stored in the variable `gl_FragColor`.

Here is a picture to encapsulate this pipeline:

<img src = "assets/webgl-dataflow.png" style = "background-color: white">

## Variables

While shaders change how our renders look, they don't have the ability to generate new renders. For this reason, we have to pass all the information about our renders to the shaders. We use variables to do this. There are two types, attribute variables and uniform variables.

### Attribute variables

Attribute variables are used in the vertex shader. They are used to receive per-vertex data from the application on the CPU. This could include vertex coordinates, normals, colours, and texture coordinates. Each vertex processed by the vertex shader gets its set of attribute values.

Examples include:

```c
attribute vec4 a_position;
attribute vec3 a_color;
```

### Uniform variables

Uniform variables provide a way to pass information to either the vertex or fragment shader. Uniform variables are kind of like constants in the sense that they keep the same value across the execution of all vertices or fragments in a single draw call. They are commonly used to pass transformation matrices, light information, or global settings to the shaders.

Examples include:

```C
uniform mat4 u_modelViewMatrix;
uniform mat4 u_projectionMatrix;
```

### Varying variable

Varying variables allow us to pass interpolated data from the vertex shaders to the fragment shaders. This typically includes texture coordinates, per-vertex colours, and transformed normals. The rasterizer, for example, interpolates the values output by the vertex shader for each vertex of a primitive to generate the corresponding input for the fragment shader.

To use a varying variable, it should be declared in bother shaders, with the same name and type.

Examples include:

```C
varying vec3 v_color;
```

### Vectors

Vectors in GLSL are 2, 3, or 4 tuples. They can take the following forms:

- `vecn`: the default vector of `n` floats.
- `bvecn`: a vector of `n` boolean values.
- `ivecn`: a vector of `n` integers.
- `uvecn`: a vector of `n` unsigned integers.
- `dvecn`: a vector of `n` double components.

You can declare vectors as follows:

```c
vec2 twoD;
vec3 threeD = vec3(0.0,0.1,0.2);
vec4 fourD = vec4(threeD, 0.3);
```

Components of a vector can b accessed via `vec.m`, where `vec` is some vector, and `m` is one of the components of the vector. The components of the vector are as follows:

* `x`: first component
* `y`: second component
* `z`: third component
* `w`: last component

You can also call the components in any order and any number of times:

```c
vec2 someVec;
vec4 biggerVec = someVec.yzxx;
vec3 smallerVec = biggerVec.zzw;
```

## Accessing data

There are three things you can do with data in shaders; receive it, send it, or process it.

### Input

There are two types of input. Input from the program to the shaders, and input from one shader to another.
#### Input from program

Once you've created your shader program, you can pass data into it as follows:

##### Attribute variables

```js
glGetAttribLocation(shaderProgram, "attributeName");
```

This returns the location to the `attribute` variable if it is found, else returns a `-1`.

##### Uniform variables

```js
glGetUniformLocation(shaderProgram, "uniformName");
```

This returns the location to the `attribute` variable if it is found, else returns a `null`.

##### Layouts

You can also pass data to a program without using the `getLocation` functions. All you need to do is bind your buffer data, then add the following to your vertex shader:

```c
layout (location = 0) in vec4 variableName;
```

`location` simply refers to the position of the data in the buffer.

#### Input from shaders

There are two ways you can receive input from other shaders. 

##### In variable

If there exists an `out` variable in another shader that matches the name of the `in` variable in your current shader, then the data from the `out` variable will be passed to the `in` variable in your  shader.

```c
// fragment shader
in vec4 aColor;

// vertex shader
out vec4 aColor;
```

##### Varying variable

If there exists a `varying` variable in both shaders, then the value from another shader will carry over to your current shader.

```c
// vertex shader
varying vec4 vColor;

// fragment shader
varying vec4 vColor;
```

### Processing

Any processing that you want to be rendered should be done in the `main` function. However, since GLSL is basically C code, you can create functions and call them in the `main` function to make your code cleaner - so long as everything needed to be rendered is in the `main` function.

### Output

Technically there are two forms of output from shaders. What gets passed back to the program and what gets passed to other programs. However, what gets passed to the program is more implicit while passing things to other shaders is very explicit.

#### Passing output to program

For each shader, there are a list of special variables that you use to pass results from the shader to the GPU.

##### Vertex shader

You pass your results to the GPU from the vertex shader using the following special variables:

* `gl_Position`
	* The clip space output position of the current vertex.
* `gl_PointSize`
	* The pixel width/height of the point being rasterized. 
	* It only has a meaning when rendering point primitives, i.e. `GL_POINTS`.
	* It will be clamped to the `GL_POINT_SIZE_RANGE`.
* `gl_ClipDistance`
	* Allows the shader to set the distance from the vertex to each user-defined clipping half-space. 
	* A non-negative distance means that the vertex is inside/behind the clip plane. 
	* A negative distance means it is outside/in front of the clip plane. 
	* Each element in the array is one clip plane. 
	* In order to use this variable, the user must manually redeclare it with an explicit size. 

##### Fragment shader

You pass your results to the GPU from the vertex shader using the special variable 

* `gl_FragColor`
	* The final colour that the pixel viewing this fragment will have
* `gl_FragDepth`
	* This output is the fragment's depth. 
	* If the shader does not statically write this value, then it will take the value of `gl_FragCoord.z`.

#### Passing output to another shader

There are two ways you can send output from other shaders. 

##### Out variable

If there exists an `in` variable in another shader that matches the name of the `out` variable in your current shader, then the data from the `out` variable in your current program will be passed to the `in` variable in the other  shader.

```c
// fragment shader
in vec4 aColor;

// vertex shader
out vec4 aColor;
```

##### Varying variable

If there exists a `varying` variable in both shaders, then the value from another shader will carry over to your current shader.

```c
// vertex shader
varying vec4 vColor;

// fragment shader
varying vec4 vColor;
```

## Creating a shader

Now that we've gotten some theory out of the way, we can start getting into the fun part. Creating a shader involves declaring your shaders, compiling them, linking them to your program, and attaching them to the OpenGL context for rendering.

Because of how widely used OpenGL is, it is available on different languages. This means that while the process of loading shaders is the same, the syntax and procedures , may be different.

Below, i have included guides to using OpenGL with different languages:

* [Shaders in C](https://github.com/refiloemopeloa/Shaders/blob/main/C/Shaders%20in%20C.md)
* [Shaders in WebGL](https://github.com/refiloemopeloa/Shaders/blob/main/WebGL/Shaders%20in%20WebGL.md)

Let's go over the steps for creating a shader. There will be some variation per language but the fundamental ideas are the same.

### Declaring a shader

First you'll need to declare the variables that will hold your shader code. Then you need to decide if you are adding your code in-line, internally, or externally.

#### Internal shaders

Internal shaders is when you type your shaders directly in your program, similar to internal CSS. This reduces the complexity of loading your shaders, but also makes it harder to read. You also lose the support of any support from your IDE if you're using one, since it views it as a string, not actual code.

#### External shaders

External shaders is when you write your shaders in a different file to your program. Shader files don't really have extensions, so you can use whatever you'd like. However, as good practice, you can give your shader files the extension `.glsl`. If you'd like to be more specific, you can add the type of shader to the extension, like `.vertex.glsl`.

If you use this method, you'll need some way of reading the file into your program.

### Compile a shader

Compiling your shader involves passing your code to the GLSL compiler. It will return some integer value, which you can use to check if the compilation was successful or not. After you've compiled your shader, you can free the variable storing your code.

### Creating a shader program

This step involves creating a program that will combine the compiled shaders into a program object.

### Linking a shader

Once you've created the shader program, you attach the shaders to the program, then link the program.

### Using a shader

Finally, you call a function to use the shader program. 



# References

1. [Chapter 10 The Programmable Pipeline | Computer Graphics and Visualisation (wits.ac.za)](https://courses.ms.wits.ac.za/~branden/CGV/_book/pipe.html)
2. [glDrawArrays - OpenGL 4 Reference Pages (khronos.org)](https://registry.khronos.org/OpenGL-Refpages/gl4/html/glDrawArrays.xhtml)
3. [Adding 2D content to a WebGL context - Web APIs | MDN (mozilla.org)](https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Tutorial/Adding_2D_content_to_a_WebGL_context)
3. [Built-in Variable (GLSL) - OpenGL Wiki](https://www.khronos.org/opengl/wiki/Built-in_Variable_(GLSL))
4. [LearnOpenGL - Shaders](https://learnopengl.com/Getting-started/Shaders)