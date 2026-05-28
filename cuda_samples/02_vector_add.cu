#include <cuda_runtime.h>
#include <iostream>
#include <vector>

#define CUDA_CHECK(call) do {                                      \
    cudaError_t err = call;                                        \
    if (err != cudaSuccess) {                                      \
        std::cerr << "CUDA error: " << cudaGetErrorString(err)     \
                  << " at " << __FILE__ << ":" << __LINE__ << "\n"; \
        std::exit(1);                                              \
    }                                                              \
} while (0)

__global__ void vector_add(const float* a, const float* b, float* c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) c[i] = a[i] + b[i];
}

int main() {
    int n = 1 << 20;
    size_t bytes = n * sizeof(float);
    std::vector<float> h_a(n, 1.0f), h_b(n, 2.0f), h_c(n);
    float *d_a = nullptr, *d_b = nullptr, *d_c = nullptr;

    CUDA_CHECK(cudaMalloc(&d_a, bytes));
    CUDA_CHECK(cudaMalloc(&d_b, bytes));
    CUDA_CHECK(cudaMalloc(&d_c, bytes));
    CUDA_CHECK(cudaMemcpy(d_a, h_a.data(), bytes, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d_b, h_b.data(), bytes, cudaMemcpyHostToDevice));

    int threads = 256;
    int blocks = (n + threads - 1) / threads;
    vector_add<<<blocks, threads>>>(d_a, d_b, d_c, n);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaMemcpy(h_c.data(), d_c, bytes, cudaMemcpyDeviceToHost));

    std::cout << "c[123] = " << h_c[123] << "\n";
    cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
    return 0;
}
