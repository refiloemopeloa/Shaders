cmake_minimum_required(VERSION 3.22.1)

project(shaders-cube C)

set(CMAKE_C_STANDARD 11)


add_executable(cube cube.c)

target_link_libraries(cube -lGL -lglut -lGLU -lm -lGLEW)
