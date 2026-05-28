#include <cuda_runtime.h>
#include <iostream>
#include <numeric>
#include <vector>

__global__ void reduce_sum(const float* in, float* block_sums, int n) {
    extern __shared__ float s[];
    unsigned int tid = threadIdx.x;
    unsigned int i = blockIdx.x * blockDim.x * 2 + threadIdx.x;
    float x = 0.0f;
    if (i < n) x += in[i];
    if (i + blockDim.x < n) x += in[i + blockDim.x];
    s[tid] = x;
    __syncthreads();

    for (unsigned int stride = blockDim.x / 2; stride > 0; stride >>= 1) {
        if (tid < stride) s[tid] += s[tid + stride];
        __syncthreads();
    }
    if (tid == 0) block_sums[blockIdx.x] = s[0];
}

int main() {
    int n = 1 << 20;
    std::vector<float> h(n, 1.0f);
    int threads = 256;
    int blocks = (n + threads * 2 - 1) / (threads * 2);
    float *d_in, *d_sums;
    cudaMalloc(&d_in, n * sizeof(float));
    cudaMalloc(&d_sums, blocks * sizeof(float));
    cudaMemcpy(d_in, h.data(), n * sizeof(float), cudaMemcpyHostToDevice);
    reduce_sum<<<blocks, threads, threads * sizeof(float)>>>(d_in, d_sums, n);
    std::vector<float> partial(blocks);
    cudaMemcpy(partial.data(), d_sums, blocks * sizeof(float), cudaMemcpyDeviceToHost);
    float total = std::accumulate(partial.begin(), partial.end(), 0.0f);
    std::cout << "sum = " << total << "\n";
    cudaFree(d_in); cudaFree(d_sums);
    return 0;
}
