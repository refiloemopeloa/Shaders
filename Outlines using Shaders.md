# Outlines using shaders

## Drawing outlines

Outlines are drawn using the stencil buffer. The first thing we'll need is enable the `GL_STENCIL_TEST`:

```c
glEnable(GL_STENCIL_TEST);
```

Then we need to call `glStencipOp` for what to do when the stencil test passes:

```c
glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
```

Now, lets clear the stencil buffer:

```c
glClear(GL_STENCIL_BUFFER_BIT);
```

After this, we need to make it such that our stencil test always passes:

```c
glStencilFunc(GL_ALWAYS, 1, 0xFF);
glStencilMask(0xFF);
```

Now, draw.

After drawing, call the following:

```c
glStencilFunc(GL_NOTEQUAL, 1, 0xFF);
glStencilMask(0x00);
glDisable(GL_DEPTH_TEST);
```

%% you left off here: [OpenGL Tutorial 15 - Stencil Buffer & Outlining (youtube.com)](https://www.youtube.com/watch?v=ngF9LWWxhd0) %%


* The width for line primitives can be set by calling:
    ```C++
    glLineWidth(width)
    ```
    * The line width is always specified in pixels.
    * It is not subject to scaling by transformations.