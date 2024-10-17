# Shaders in WebGL

This guide will focus solely on implementing and using shaders for WebGL using JavaScript. For a more comprehensive guide of what shaders are, how to create them, and using them for OpenGL in C, refer to this document: [A Guide to Shaders](https://github.com/refiloemopeloa/Shaders/blob/main/A%20Guide%20to%20Shaders.md).

## Data Structures

Let's start with the data structures we can us in WebGL.
### glMatrix

`glMatrix` is a popular library for handling matrix and vector operations in WebGL. It is optimized for high performance in graphics computations.

Here's an example:

```js
const projection = mat4.create();    // projection matrix
const modelview = mat4.create();     // modelview matrix
const modelviewProj = mat4.create(); // combined transformation matrix
const normalMatrix = mat3.create(); // matrix, derived from modelview matrix, for transforming normal vectors

mat4.multiply( modelviewProj, projection, modelview ); //Multiply the modelview and projection transforms to get the combined transform
```

### Vertex Buffer Object

A vertex buffer object is basically block of memory that can hold the coordinates or other attributes for a set of vertices. You can read more on vertex buffer objects in [A Guide to Shaders](https://github.com/refiloemopeloa/Shaders/blob/main/A%20Guide%20to%20Shaders.md).

Here's some code showing to enable and use VBOs:

```js
function drawPrimitive( primitiveType, color, vertices ) {
     gl.enableVertexAttribArray(a_coords_loc);
     gl.bindBuffer(gl.ARRAY_BUFFER,a_coords_buffer);
     gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STREAM_DRAW);
     gl.uniform4fv(u_color, color);
     gl.vertexAttribPointer(a_coords_loc, 3, gl.FLOAT, false, 0, 0);
     gl.drawArrays(primitiveType, 0, vertices.length/3);
}
```

## Creating a shader

In [A Guide to Shaders](https://github.com/refiloemopeloa/Shaders/blob/main/A%20Guide%20to%20Shaders.md), we go over the details of how to create a shader, but here we'll be very brief. There are four steps to creating a shader. Declaring, compiling, linking and attaching the shader to the WebGL context for rendering.

### Declaring a shader

First, we create variables to hold the code of our shaders:

```js
let vertexShaderSource;
let fragmentShaderSource;
```

Then set our variables to our shader code. You can do this internally, or externally, but I recommend externally as this makes your code more readable:

```js

fetch("shaders/vertexShader.glsl")
.then(response => response.text())
.then(data => {
vertexShaderSource = data
})

fetch("shaders/fragmentShader.glsl")
.then(response => response.text())
.then(data => {
fragmentShaderSource = data
})
```

### Compiling a shader

Now, let's compile our shader:

```js
function compileShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        console.error('An error occurred compiling the shaders: ' + gl.getShaderInfoLog(shader));
        gl.deleteShader(shader);
        return null;
    }
    return shader;
}
```

### Create a shader program

A shader program will combine the compiled shaders into a program object.
Let's create a program object:

```js
const shaderProgram = createProgram(gl, vertexShaderSource, fragmentShaderSource);

function createProgram(gl, vertexShaderSource, fragmentShaderSource) {
    let  vsh = gl.createShader( gl.VERTEX_SHADER );
    gl.shaderSource( vsh, vertexShaderSource );
    gl.compileShader( vsh );
    if ( ! gl.getShaderParameter(vsh, gl.COMPILE_STATUS) ) {
        throw new Error("Error in vertex shader:  " + gl.getShaderInfoLog(vsh));
    }
    let  fsh = gl.createShader( gl.FRAGMENT_SHADER );
    gl.shaderSource( fsh, fragmentShaderSource );
    gl.compileShader( fsh );
    if ( ! gl.getShaderParameter(fsh, gl.COMPILE_STATUS) ) {
        throw new Error("Error in fragment shader:  " + gl.getShaderInfoLog(fsh));
    }
    let  prog = gl.createProgram();
    gl.attachShader( prog, vsh );
    gl.attachShader( prog, fsh );
    gl.linkProgram( prog );
    if ( ! gl.getProgramParameter( prog, gl.LINK_STATUS) ) {
        throw new Error("Link error in program:  " + gl.getProgramInfoLog(prog));
    }
    return prog;
}
```

### Linking a shader

Next, lets link our shader to the GL context. To do this, first we need to attach the shaders to the WebGL program object:

```js
gl.attachShader(prog,vsh);
gl.attachShader(prog,fsh);
```

Then, we can link the program to the WebGL context, allowing the GPU to process vertexes and fragments during rendering:

```js
gl.linkProgram(prog);
```

### Using a shader

Finally, to see the effects of the shader, call:

```js
gl.useProgram(prog);
```


# References

1. [Chapter 10 The Programmable Pipeline | Computer Graphics and Visualisation (wits.ac.za)](https://courses.ms.wits.ac.za/~branden/CGV/_book/pipe.html#creating-a-shader)