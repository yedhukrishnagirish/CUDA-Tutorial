# CUDA Tutorial

Simple CUDA examples using nvcc and CMake on Windows.

## Open Visual Studio CUDA terminal

call "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -arch=x64

## Build with CMake

cd /d C:\Users\ygirish\Downloads\CUDA-Tutorial
rmdir /s /q build
cmake -S . -B build -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CUDA_FLAGS="-lineinfo"
cmake --build build

## Run examples

build\bin\01_hello.exe
build\bin\02_vector_add.exe
build\bin\03_matrix_mul_tiled.exe
build\bin\04_reduction.exe
build\bin\05_streams_async.exe
build\bin\06_unified_memory.exe

## Compile one file with nvcc

cd /d C:\Users\ygirish\Downloads\CUDA-Tutorial\cuda_samples
nvcc 01_hello.cu -o hello.exe
hello.exe
