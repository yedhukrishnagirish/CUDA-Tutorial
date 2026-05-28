#include <cuda_runtime.h>
#include <iostream>

__global__ void add_one(float* x, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) x[i] += 1.0f;
}

int main() {
    int n = 1 << 20;
    float* x = nullptr;
    cudaMallocManaged(&x, n * sizeof(float));
    for (int i = 0; i < n; ++i) x[i] = 41.0f;

    add_one<<<(n + 255) / 256, 256>>>(x, n);
    cudaDeviceSynchronize();         // required before CPU reads managed data
    std::cout << "x[0] = " << x[0] << "\n";
    cudaFree(x);
    return 0;
}
