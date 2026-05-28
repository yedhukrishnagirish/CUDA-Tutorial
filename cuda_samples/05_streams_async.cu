#include <cuda_runtime.h>
#include <iostream>

__global__ void scale(float* x, int n, float a) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) x[i] *= a;
}

int main() {
    int n = 1 << 20;
    size_t bytes = n * sizeof(float);
    float *h = nullptr, *d = nullptr;
    cudaMallocHost(&h, bytes);       // pinned host memory enables async copies
    cudaMalloc(&d, bytes);
    for (int i = 0; i < n; ++i) h[i] = 1.0f;

    cudaStream_t stream;
    cudaStreamCreate(&stream);
    cudaMemcpyAsync(d, h, bytes, cudaMemcpyHostToDevice, stream);
    scale<<<(n + 255) / 256, 256, 0, stream>>>(d, n, 3.0f);
    cudaMemcpyAsync(h, d, bytes, cudaMemcpyDeviceToHost, stream);
    cudaStreamSynchronize(stream);

    std::cout << "h[0] = " << h[0] << "\n";
    cudaStreamDestroy(stream);
    cudaFree(d);
    cudaFreeHost(h);
    return 0;
}
