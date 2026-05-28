cmake_minimum_required(VERSION 3.24)

project(CudaSamples LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_ARCHITECTURES 75)

set(CUDA_SAMPLE_SOURCES
    cuda_samples/01_hello.cu
    cuda_samples/02_vector_add.cu
    cuda_samples/03_matrix_mul_tiled.cu
    cuda_samples/04_reduction.cu
    cuda_samples/05_streams_async.cu
    cuda_samples/06_unified_memory.cu
)

foreach(sample_source IN LISTS CUDA_SAMPLE_SOURCES)
    get_filename_component(sample_name "${sample_source}" NAME_WE)

    add_executable("${sample_name}" "${sample_source}")

    set_target_properties("${sample_name}" PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    )
endforeach()