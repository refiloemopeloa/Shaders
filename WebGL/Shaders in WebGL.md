# Shaders in WebGL

This guide will focus solely on implementing and using shaders for WebGL using JavaScript. For a more comprehensive guide of what shaders are, how to create them, and using them for OpenGL in C, refer to this document: [A Guide to Shaders](https://github.com/refiloemopeloa/Shaders/blob/main/A%20Guide%20to%20Shaders.md).

Before we get started, please have a look at the following guide to get a basic understanding of how WebGL works and how to set up a WebGL project: [A Guide to WebGL](https://github.com/refiloemopeloa/WebGL/blob/main/A%20Guide%20to%20WebGL.md).
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
async function readFile(fileName) {  
    const response = await fetch(fileName);  
    return response.text();  
}
  
// Load shader sources  

async function setShaders() {
const vertexShaderSource = await readFile("./shaders/vertexShader.glsl");  
const fragmentShaderSource = await readFile("./shaders/fragmentShader.glsl");
}
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

### Cleaner code

We can clean everything above up by using the following functions. Let's add these functions to the file `shader-program.js`:

```js
//  
// Initialize a shader program, so WebGL knows how to draw our data  
//  
function initShaderProgram(gl, vertexShaderSource, fragmentShaderSource) {  
    const vertexShader = loadShader(gl, gl.VERTEX_SHADER, vertexShaderSource);  
    const fragmentShader = loadShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);  
  
    // Create the shader program  
  
    const shaderProgram = gl.createProgram();  
    gl.attachShader(shaderProgram, vertexShader);  
    gl.attachShader(shaderProgram, fragmentShader);  
    gl.linkProgram(shaderProgram);  
  
    // If creating the shader program failed, alert  
  
    if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {  
        alert(  
            `Unable to initialize the shader program: ${gl.getProgramInfoLog(  
                shaderProgram,  
            )}`,  
        );        return null;  
    }  
    return shaderProgram;  
}  
  
//  
// creates a shader of the given type, uploads the source and  
// compiles it.  
//  
function loadShader(gl, type, source) {  
    const shader = gl.createShader(type);  
  
    // Send the source to the shader object  
  
    gl.shaderSource(shader, source);  
  
    // Compile the shader program  
  
    gl.compileShader(shader);  
  
    // See if it compiled successfully  
  
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {  
        alert(  
            `An error occurred compiling the shaders: ${gl.getShaderInfoLog(shader)}`,  
        );        gl.deleteShader(shader);  
        return null;  
    }  
    return shader;  
}  
  
export {initShaderProgram};
```

Then call the following in your `main()` function:

```js
// Initialize a shader program; this is where all the lighting
// for the vertices and so forth is established.
const shaderProgram = initShaderProgram(gl, vsSource, fsSource);

```

## Passing data to shaders

I recommend reading this section of a guide to shaders first: 

Once you've created your shader program, you can pass data into it as follows:

##### Attribute variables

```js
const attributeLocation = gl.getAttribLocation(shaderProgram, "attributeName");
```

This returns the location to the `attribute` variable if it is found, else returns a `-1`.

##### Uniform variables

```js
const uniformLocation = gl.getAttribLocation(shaderProgram, "uniformName");
```

This returns the location to the `attribute` variable if it is found, else returns a `null`.

## Square demo
### Passing object data

Once we've created our shader, we need to pass our object data to the shaders. We can pass `attribute` variables, `uniform` variables, and `varying` variables. 

* `Attribute` variable
	* Receive values from buffers.
	* Each iteration of the vertex shader receives the next value from the buffer assigned to that attribute.
* `Uniform` variable
	* You can think about `uniform` variables as JavaScript global variables.
	* They stay the same value for all iterations of a shader.

Since the variables are specific to a single shader program, we'll store them together in an object:

```js
// Collect all the info needed to use the shader program.
// Look up which attribute our shader program is using
// for aVertexPosition and look up uniform locations.
const programInfo = {
  program: shaderProgram,
  attribLocations: {
    vertexPosition: gl.getAttribLocation(shaderProgram, "aVertexPosition"),
  },
  uniformLocations: {
    projectionMatrix: gl.getUniformLocation(shaderProgram, "uProjectionMatrix"),
    modelViewMatrix: gl.getUniformLocation(shaderProgram, "uModelViewMatrix"),
  },
};

```

### Initializing buffers

Before we can render any shape, we need to create a buffer that contains the vertex positions of that shape. For good practice, we'll add this to a separate file called `init-buffers.js`. We'll use a square as an example:

```js
function initBuffers(gl) {  
    const positionBuffer = initPositionBuffer(gl);  
  
    return {  
        position: positionBuffer,  
    };}  
  
function initPositionBuffer(gl) {  
    // Create a buffer for the square's positions.  
    const positionBuffer = gl.createBuffer();  
  
    // Select the positionBuffer as the one to apply buffer  
    // operations to from here out.    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);  
  
    // Now create an array of positions for the square.  
    const positions = [1.0, 1.0, -1.0, 1.0, 1.0, -1.0, -1.0, -1.0];  
  
    // Now pass the list of positions into WebGL to build the  
    // shape. We do this by creating a Float32Array from the    // JavaScript array, then use it to fill the current buffer.    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);  
  
    return positionBuffer;  
}  
  
export { initBuffers };
```

### Creating shaders

Create a directory called `shaders/` and add `vertexShader.glsl` and `fragmentShader.glsl` files to it.

In your `vertexShader.glsl` file, add the following code:

```c
attribute vec4 aVertexPosition;
uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;
void main() {
    gl_Position = uProjectionMatrix * uModelViewMatrix * aVertexPosition;
    }
```

In your `fragmentShader.glsl` file, add the following:

```C
void main() {
	gl_FragColor = vec4(0.0, 1.0, 1.0, 1.0);
}
```

### Rendering a scene

Once the shaders are ready, the variables have been passed to the shaders, and the square's vertex positions have been added to a buffer, we can render the scene.

First, let's create another module, called `draw-scene.js` and add the following contents to it:

```js
function drawScene(gl, programInfo, buffers) {  
    gl.clearColor(0.0, 0.0, 0.0, 1.0); // Clear to black, fully opaque  
    gl.clearDepth(1.0); // Clear everything  
    gl.enable(gl.DEPTH_TEST); // Enable depth testing  
    gl.depthFunc(gl.LEQUAL); // Near things obscure far things  
  
    // Clear the canvas before we start drawing on it.  
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);  
  
    // Create a perspective matrix, a special matrix that is  
    // used to simulate the distortion of perspective in a camera.    // Our field of view is 45 degrees, with a width/height    // ratio that matches the display size of the canvas    // and we only want to see objects between 0.1 units    // and 100 units away from the camera.  
    const fieldOfView = (45 * Math.PI) / 180; // in radians  
    const aspect = gl.canvas.clientWidth / gl.canvas.clientHeight;  
    const zNear = 0.1;  
    const zFar = 100.0;  
    const projectionMatrix = mat4.create();  
  
    // note: glmatrix.js always has the first argument  
    // as the destination to receive the result.    mat4.perspective(projectionMatrix, fieldOfView, aspect, zNear, zFar);  
  
    // Set the drawing position to the "identity" point, which is  
    // the center of the scene.    const modelViewMatrix = mat4.create();  
  
    // Now move the drawing position a bit to where we want to  
    // start drawing the square.    mat4.translate(  
        modelViewMatrix, // destination matrix  
        modelViewMatrix, // matrix to translate  
        [-0.0, 0.0, -6.0],  
    ); // amount to translate  
  
    // Tell WebGL how to pull out the positions from the position    // buffer into the vertexPosition attribute.    setPositionAttribute(gl, buffers, programInfo);  
  
    // Tell WebGL to use our program when drawing  
    gl.useProgram(programInfo.program);  
  
    // Set the shader uniforms  
    gl.uniformMatrix4fv(  
        programInfo.uniformLocations.projectionMatrix,  
        false,  
        projectionMatrix,  
    );    gl.uniformMatrix4fv(  
        programInfo.uniformLocations.modelViewMatrix,  
        false,  
        modelViewMatrix,  
    );  
    {        const offset = 0;  
        const vertexCount = 4;  
        gl.drawArrays(gl.TRIANGLE_STRIP, offset, vertexCount);  
    }}  
  
// Tell WebGL how to pull out the positions from the position  
// buffer into the vertexPosition attribute.  
function setPositionAttribute(gl, buffers, programInfo) {  
    const numComponents = 2; // pull out 2 values per iteration  
    const type = gl.FLOAT; // the data in the buffer is 32bit floats  
    const normalize = false; // don't normalize  
    const stride = 0; // how many bytes to get from one set of values to the next  
    // 0 = use type and numComponents above    const offset = 0; // how many bytes inside the buffer to start from  
    gl.bindBuffer(gl.ARRAY_BUFFER, buffers.position);  
    gl.vertexAttribPointer(  
        programInfo.attribLocations.vertexPosition,  
        numComponents,  
        type,  
        normalize,  
        stride,  
        offset,  
    );    gl.enableVertexAttribArray(programInfo.attribLocations.vertexPosition);  
}  
  
  
export { drawScene };
```

We'll have a look at the individual functions later. For now, let's get our square up and rendering.

In your `square.js`, add the following code to it:

```js
import { initBuffers } from "./init-buffers.js";  
import { drawScene } from "./draw-scene.js";  
import { initShaderProgram } from "./shader-program.js";  
  
async function readFile(fileName) {  
    const response = await fetch(fileName);  
    return response.text();  
}  
  
async function display(gl) {  
    // Load shader sources  
    const vertexShaderSource = await readFile("./shaders/vertexShader.glsl");  
    const fragmentShaderSource = await readFile("./shaders/fragmentShader.glsl");  
  
    // Initialize shader program  
    let shaderProgram = initShaderProgram(gl, vertexShaderSource, fragmentShaderSource);  
  
    // Rest of the function remains the same  
    const buffers = initBuffers(gl);  
  
    const programInfo = {  
        program: shaderProgram,  
        attribLocations: {  
            vertexPosition: gl.getAttribLocation(shaderProgram, "aVertexPosition"),  
        },        uniformLocations: {  
            projectionMatrix: gl.getUniformLocation(shaderProgram, "uProjectionMatrix"),  
            modelViewMatrix: gl.getUniformLocation(shaderProgram, "uModelViewMatrix"),  
        },    };  
    drawScene(gl, programInfo, buffers);  
}  
  
  
export {display};
```

Finally, in your `main.js` file, add the following code:

```js
import { display } from "./square.js"  
  
const initCanvas = () => {  
    const canvas = document.querySelector("#glCanvas");  
  
    const gl = canvas.getContext("webgl");  
  
    if (gl === null) {  
        alert("Unable to initialize WebGL. Your browser or machine may not support it.");  
        return;  
    }  
    gl.clearColor(0.0, 0.0, 0.0, 1.0);  
  
    gl.clear(gl.COLOR_BUFFER_BIT);  
  
    return gl;  
}  
  
function main() {  
    let gl = initCanvas();  
    display(gl);  
}  
  
main();
```

And add the following to your `index.html` file:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>WebGL Demo</title>
    <link rel="stylesheet" href="./webgl.css" type="text/css" />
    <script
      src="https://cdnjs.cloudflare.com/ajax/libs/gl-matrix/2.8.1/gl-matrix-min.js"
      integrity="sha512-zhHQR0/H5SEBL3Wn6yYSaTTZej12z0hVZKOv3TwCUXT1z5qeqGcXJLLrbERYRScEDDpYIJhPC1fk31gqR783iQ=="
      crossorigin="anonymous"
      defer></script>
    <script src="main.js" type="module"></script>
  </head>

  <body>
    <canvas id="glcanvas" width="640" height="480"></canvas>
  </body>
</html>
```

Now run your page by typing:

```shell
npm start run
```

If this doesn't work, refer to [A Guide to WebGL](https://github.com/refiloemopeloa/WebGL/blob/main/A%20Guide%20to%20WebGL.md). This guide includes steps on setting up `live-server`.

If everything went as planned, you should see the following in your browser:

![shaders-webgl-square](assets/shader-webgl-square.png)

This is all good and well but it's a bit boring. Let's spice it up by applying the colour to the vertexes rather than the shaders.

## Coloring through vertex shader

First, add the following to your `init-buffers.js` file:

```js
function initColorBuffer(gl) {
  const colors = [
    1.0,
    1.0,
    1.0,
    1.0, // white
    1.0,
    0.0,
    0.0,
    1.0, // red
    0.0,
    1.0,
    0.0,
    1.0, // green
    0.0,
    0.0,
    1.0,
    1.0, // blue
  ];

  const colorBuffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, colorBuffer);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW);

  return colorBuffer;
}

```

Then, update your `vertexShader.glsl` file:

```c
attribute vec4 aVertexPosition;  
attribute vec4 aVertexColor;  
  
uniform mat4 uModelViewMatrix;  
uniform mat4 uProjectionMatrix;  
  
varying lowp vec4 vColor;  
  
void main(void) {  
    gl_Position = uProjectionMatrix * uModelViewMatrix * aVertexPosition;  
    vColor = aVertexColor;  
}
```

And update your `fragmentShader.glsl` file:

```c
varying lowp vec4 vColor;  
  
void main(void) {  
    gl_FragColor = vColor;  
}
```

Now, update your `programInfo` object in your `square.js` function:

```c
const programInfo = {  
    program: shaderProgram,  
    attribLocations: {  
        vertexPosition: gl.getAttribLocation(shaderProgram, "aVertexPosition"),  
        vertexColor: gl.getAttribLocation(shaderProgram, "aVertexColor"),  
    },    uniformLocations: {  
        projectionMatrix: gl.getUniformLocation(shaderProgram, "uProjectionMatrix"),  
        modelViewMatrix: gl.getUniformLocation(shaderProgram, "uModelViewMatrix"),  
    },};
```

Then, add the following function to your `draw-scene.js` file:

```js
// Tell WebGL how to pull out the colors from the color buffer
// into the vertexColor attribute.
function setColorAttribute(gl, buffers, programInfo) {
  const numComponents = 4;
  const type = gl.FLOAT;
  const normalize = false;
  const stride = 0;
  const offset = 0;
  gl.bindBuffer(gl.ARRAY_BUFFER, buffers.color);
  gl.vertexAttribPointer(
    programInfo.attribLocations.vertexColor,
    numComponents,
    type,
    normalize,
    stride,
    offset,
  );
  gl.enableVertexAttribArray(programInfo.attribLocations.vertexColor);
}
```

Now, call it in your `drawScene()` function, before the `gl.useProgram()` call.

### What do you see?

If everything went well, you should see the following:

![vertex-shader-coloring](assets/vertex-shader-coloring.png)

## Animating objects

Our scene is still a bit boring. Let's make things more interesting by adding animation.

First, add this to your `main.js` file:

```js
let squareRotation = 0.0;
let deltaTime = 0;
```

Now, update the `draw-scene.js` file in your `drawScene` function, after the `mat4.translate`:

```js
mat4.rotate(
  modelViewMatrix, // destination matrix
  modelViewMatrix, // matrix to rotate
  squareRotation, // amount to rotate in radians
  [0, 0, 1],
); // axis to rotate around
```

Finally, update your `main` function:

```js
let then = 0;

// Draw the scene repeatedly
function render(now) {
  now *= 0.001; // convert to seconds
  deltaTime = now - then;
  then = now;

  drawScene(gl, programInfo, buffers, squareRotation);
  squareRotation += deltaTime;

  requestAnimationFrame(render);
}
requestAnimationFrame(render);
```


You should see the following:

![vertex-shader-rotation](assets/vertex-shader-rotation.gif)

## Cube Demo


# References

1. [Chapter 10 The Programmable Pipeline | Computer Graphics and Visualisation (wits.ac.za)](https://courses.ms.wits.ac.za/~branden/CGV/_book/pipe.html#creating-a-shader)
2. [Adding 2D content to a WebGL context - Web APIs | MDN (mozilla.org)](https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Tutorial/Adding_2D_content_to_a_WebGL_context)
3. 